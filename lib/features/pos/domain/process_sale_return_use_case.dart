import 'package:supabase_flutter/supabase_flutter.dart';

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

/// Mirrors [CompleteSaleUseCase] for the opposite direction: processing a
/// return restocks inventory, posts the reversing accounting entry, and (for
/// a pay-later sale) shrinks the customer's outstanding debt instead of
/// leaving a stale balance.
///
/// Same two-implementation split as [CompleteSaleUseCase] — see that file's
/// class doc for why.
abstract class ProcessSaleReturnUseCase {
  Future<void> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
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
  Future<void> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
  }) async {
    final lines = returnLines.where((l) => l.quantityReturned > 0).toList();
    if (lines.isEmpty) return;

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
  }
}

/// Runs the entire return as one Postgres transaction via the
/// `process_sale_return` RPC — return + lines, restocking, the reversing
/// journal entry, and (for a pay-later original sale) the debt reduction
/// either all commit together or none of them do.
class SupabaseAtomicProcessSaleReturnUseCase implements ProcessSaleReturnUseCase {
  SupabaseAtomicProcessSaleReturnUseCase({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<void> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
  }) async {
    final lines = returnLines.where((l) => l.quantityReturned > 0).toList();
    if (lines.isEmpty) return;

    await _client.rpc('process_sale_return', params: {
      'p_original_sale_id': originalSale.id,
      'p_return_lines': lines
          .map((l) => {'sale_line_id': l.saleLine.id, 'quantity_returned': l.quantityReturned})
          .toList(),
      'p_processed_by_user_id': processedByUserId,
      'p_refund_to_cash': refundToCash,
    });
  }
}
