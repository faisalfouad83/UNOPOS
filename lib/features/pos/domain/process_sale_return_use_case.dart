import 'dart:math' as math;

import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/utils/id_generator.dart';

import '../../accounting/domain/accounting_posting_service.dart';
import '../../debts/domain/debts_repository.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../inventory/domain/inventory_repository.dart';
import 'pos_models.dart';
import 'pos_repository.dart';

class ReturnLineInput {
  const ReturnLineInput({required this.saleLine, required this.quantityReturned});
  final SaleLineRecord saleLine;
  final int quantityReturned;
}

/// What a return came to.
class SaleReturnResult {
  const SaleReturnResult({required this.refundMinorUnits, this.handedBackMinorUnits});

  /// What the returned items were worth.
  final int refundMinorUnits;

  /// Of that, the money given back to the customer (cash or card). Less
  /// than [refundMinorUnits] for a sale paid later: the rest comes off what
  /// they still owe. Null when not known yet (the return is sent later).
  final int? handedBackMinorUnits;
}

/// The refund for [lines]: each unit refunds its share of the line total
/// (the same whole-unit division the server uses).
int refundFor(Iterable<ReturnLineInput> lines) =>
    lines.fold(0, (s, l) => s + l.saleLine.unitRefundMinorUnits * l.quantityReturned);

/// More of a line than is left to return was asked for — it was returned
/// meanwhile (on another till, or by a return still waiting to be sent).
class ReturnExceedsRemainingException implements Exception {
  const ReturnExceedsRemainingException();
}

/// The lines actually returned; throws [ReturnExceedsRemainingException]
/// when one asks for more than is left.
List<ReturnLineInput> _checkedLines(List<ReturnLineInput> returnLines) {
  final lines = returnLines.where((l) => l.quantityReturned > 0).toList();
  if (lines.any((l) => l.quantityReturned > l.saleLine.remainingQuantity)) {
    throw const ReturnExceedsRemainingException();
  }
  return lines;
}

/// Mirrors [CompleteSaleUseCase] for the opposite direction: processing a
/// return restocks inventory, posts the reversing accounting entry, and (for
/// a pay-later sale) shrinks the customer's outstanding debt instead of
/// leaving a stale balance.
///
/// Same two-implementation split as [CompleteSaleUseCase] — see that file's
/// class doc for why.
abstract class ProcessSaleReturnUseCase {
  /// [originalSale] must be as it is now (returns already made included,
  /// those still waiting to be sent too): more than what is left of a line
  /// can't be returned. [owedMinorUnits]: what the customer still owed on
  /// a sale paid later, when known — used to tell how much is handed back
  /// while the return waits to be sent.
  Future<SaleReturnResult> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
    int? owedMinorUnits,
  });
}

/// Today's exact orchestration, moved verbatim — used on the local Drift
/// database.
class OrchestratedProcessSaleReturnUseCase implements ProcessSaleReturnUseCase {
  OrchestratedProcessSaleReturnUseCase({
    required PosRepository posRepository,
    required InventoryRepository inventoryRepository,
    required AccountingPostingService accountingPostingService,
    required DebtsRepository debtsRepository,
  })  : _posRepository = posRepository,
        _inventoryRepository = inventoryRepository,
        _accountingPostingService = accountingPostingService,
        _debtsRepository = debtsRepository;

  final PosRepository _posRepository;
  final InventoryRepository _inventoryRepository;
  final AccountingPostingService _accountingPostingService;
  final DebtsRepository _debtsRepository;

  @override
  Future<SaleReturnResult> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
    int? owedMinorUnits,
  }) async {
    final lines = _checkedLines(returnLines);
    if (lines.isEmpty) return const SaleReturnResult(refundMinorUnits: 0, handedBackMinorUnits: 0);

    final returnId = await _posRepository.createSaleReturn(
      storeId: originalSale.storeId,
      branchId: originalSale.branchId,
      originalSaleId: originalSale.id,
      refundMethod: refundToCash ? 'cash' : 'card',
      processedByUserId: processedByUserId,
      saleLineIdToQuantity: lines.map((l) => MapEntry(l.saleLine.id, l.quantityReturned)).toList(),
    );

    var refundMinorUnits = 0;
    var restockedCogsMinorUnits = 0;
    for (final line in lines) {
      final unitTotal = line.saleLine.quantity == 0 ? 0 : line.saleLine.lineTotalMinorUnits ~/ line.saleLine.quantity;
      refundMinorUnits += unitTotal * line.quantityReturned;
      restockedCogsMinorUnits += line.saleLine.costPriceSnapshotMinorUnits * line.quantityReturned;

      await _inventoryRepository.recordStockMovement(
        storeId: originalSale.storeId,
        productId: line.saleLine.productId,
        branchId: originalSale.branchId,
        type: StockMovementType.returnIn,
        quantity: line.quantityReturned,
        referenceType: 'SALE_RETURN',
        referenceId: returnId,
        createdByUserId: processedByUserId,
      );
    }

    final wasPayLater = originalSale.paymentMethod == SalePaymentMethod.payLater;

    await _accountingPostingService.postSaleReturn(
      storeId: originalSale.storeId,
      branchId: originalSale.branchId,
      saleReturnId: returnId,
      createdByUserId: processedByUserId,
      refundMinorUnits: refundMinorUnits,
      restockedCogsMinorUnits: restockedCogsMinorUnits,
      refundToCash: refundToCash,
      wasPayLater: wasPayLater,
    );

    if (wasPayLater) {
      final debtEntry = await _debtsRepository.findBySaleId(originalSale.id);
      if (debtEntry != null) {
        await _debtsRepository.reduceOriginalAmount(debtEntry.id, refundMinorUnits);
      }
    }
    // Paid later, the whole refund comes off the customer's debt here.
    return SaleReturnResult(
        refundMinorUnits: refundMinorUnits, handedBackMinorUnits: wasPayLater ? 0 : refundMinorUnits);
  }
}

/// Runs the entire return as one Postgres transaction via the
/// `process_sale_return` RPC — return + lines, restocking, the reversing
/// journal entry, and (for a pay-later original sale) the debt reduction
/// either all commit together or none of them do.
///
/// Offline, the return is kept on this device and sent (exactly once) when
/// the connection is back. A sale that itself hasn't reached the server
/// yet can't be returned until it has.
class SupabaseAtomicProcessSaleReturnUseCase implements ProcessSaleReturnUseCase {
  SupabaseAtomicProcessSaleReturnUseCase({required OfflineWriter writer, Outbox? outbox})
      : _writer = writer,
        _outbox = outbox ?? Outbox.shared;

  final OfflineWriter _writer;
  final Outbox _outbox;

  @override
  Future<SaleReturnResult> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
    int? owedMinorUnits,
  }) async {
    final lines = _checkedLines(returnLines);
    if (lines.isEmpty) return const SaleReturnResult(refundMinorUnits: 0, handedBackMinorUnits: 0);

    await _outbox.load();
    if (_outbox.pending.any((o) => o.kind == OutboxKind.checkout && o.id == originalSale.id)) {
      throw const SaleNotSyncedException();
    }
    final refund = refundFor(lines);
    final payLater = originalSale.paymentMethod == SalePaymentMethod.payLater;
    // Paid later, the refund first comes off what is still owed; only what
    // was paid beyond that is handed back.
    final owed = owedMinorUnits;
    final int? handedBack = !payLater ? refund : (owed == null ? null : math.max(0, refund - math.max(0, owed)));
    final result = await _writer.rpc(
      'process_sale_return',
      offline: () => null,
      {
        'p_original_sale_id': originalSale.id,
        'p_return_lines':
            lines.map((l) => {'sale_line_id': l.saleLine.id, 'quantity_returned': l.quantityReturned}).toList(),
        'p_processed_by_user_id': processedByUserId,
        'p_refund_to_cash': refundToCash,
      },
      // Until it reaches the server, this device shows the return as made:
      // the lines' returned quantities and the sale's status (so it can't
      // be returned twice), and the refund in the cashier's drawer.
      previewTable: 'sale_returns',
      preview: returnPreview(
        originalSale,
        lines,
        processedByUserId: processedByUserId,
        refundToCash: refundToCash,
        handedBackMinorUnits: handedBack ?? 0,
      ),
      increments: returnIncrements(originalSale, lines),
    );
    if (result is Map && result['refund'] != null) {
      final cash = result['refund_cash'];
      return SaleReturnResult(
        refundMinorUnits: (result['refund'] as num).toInt(),
        handedBackMinorUnits: cash is num ? cash.toInt() : handedBack,
      );
    }
    return SaleReturnResult(refundMinorUnits: refund, handedBackMinorUnits: handedBack);
  }
}

/// The sale was made offline and hasn't reached the server yet.
class SaleNotSyncedException implements Exception {
  const SaleNotSyncedException();
}

/// A return waiting to be sent, as a `sale_returns` row (with what it
/// refunds), shown until the server's copy arrives.
Map<String, dynamic> returnPreview(
  SaleRecord sale,
  List<ReturnLineInput> lines, {
  required String processedByUserId,
  required bool refundToCash,
  required int handedBackMinorUnits,
}) {
  final refund = refundFor(lines);
  return {
    'id': IdGenerator.newId(),
    'store_id': sale.storeId,
    'branch_id': sale.branchId,
    'original_sale_id': sale.id,
    'refund_method': refundToCash ? 'cash' : 'card',
    'processed_by_user_id': processedByUserId,
    'created_at': DateTime.now().toUtc().toIso8601String(),
    'refund_minor_units': refund,
    'refund_cash_minor_units': handedBackMinorUnits,
  };
}

/// What a return does to [sale]'s rows, shown while it waits to be sent:
/// each line's returned quantity goes up, and the sale is (partly) returned.
List<Map<String, dynamic>> returnIncrements(SaleRecord sale, List<ReturnLineInput> lines) {
  final returning = <String, int>{};
  for (final l in lines) {
    returning[l.saleLine.id] = (returning[l.saleLine.id] ?? 0) + l.quantityReturned;
  }
  final allBack = sale.lines.every((l) => l.remainingQuantity - (returning[l.id] ?? 0) <= 0);
  return [
    for (final e in returning.entries)
      {'table': 'sale_lines', 'id': e.key, 'column': 'quantity_returned', 'by': e.value},
    {
      'table': 'sales',
      'id': sale.id,
      'set': {'status': allBack ? 'refunded' : 'partiallyRefunded'},
    },
  ];
}
