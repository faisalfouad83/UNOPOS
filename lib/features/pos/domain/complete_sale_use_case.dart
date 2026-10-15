import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../accounting/domain/accounting_posting_service.dart';
import '../../debts/domain/debts_repository.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../inventory/domain/inventory_repository.dart';
import 'loyalty.dart';
import 'pos_models.dart';
import 'pos_repository.dart';

export 'pos_repository.dart' show HeldSaleClosedException;

class CheckoutResult {
  const CheckoutResult({
    required this.sale,
    this.debtEntryId,
    this.queuedOffline = false,
    this.loyaltyPointsEarned,
    this.loyaltyBalance,
  });
  final SaleRecord sale;
  final String? debtEntryId;

  /// Points the loyalty customer earned on this sale, and their balance
  /// afterwards (balance unknown for a sale queued offline).
  final int? loyaltyPointsEarned;
  final int? loyaltyBalance;

  /// True when there was no connection: the sale is saved on this device
  /// and will be sent to the server automatically once back online.
  final bool queuedOffline;
}

/// Orchestrates everything a completed sale touches: the sale record
/// itself, stock deduction, the double-entry accounting posting, and (for
/// pay-later sales) a new debt ledger entry. This is the one place all of
/// that is wired together — the POS screen just calls [checkout].
///
/// Two implementations: [OrchestratedCompleteSaleUseCase] (Drift — today's
/// behavior, unchanged) and [SupabaseAtomicCompleteSaleUseCase] (calls one
/// Postgres RPC so the whole checkout is a genuine single transaction —
/// see supabase/migrations/0003_checkout_rpcs.sql). Selected in
/// lib/core/providers.dart behind the same kUseSupabaseBackend flag used
/// everywhere else.
abstract class CompleteSaleUseCase {
  Future<SaleRecord> holdSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required List<SaleLineInput> lines,

    /// The held sale this cart was resumed from: holding again updates that
    /// sale (same number, same place in the list) instead of adding a copy.
    SaleRecord? replacing,
  });

  /// [resumingHeldSale] is the held sale this cart was resumed from. The
  /// cart as it is now is what gets sold (anything added or changed after
  /// resuming included), and that held sale is closed with it.
  Future<CheckoutResult> checkout({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    required SalePaymentMethod paymentMethod,
    required List<SaleLineInput> lines,
    int? amountTenderedMinorUnits,
    int? changeGivenMinorUnits,
    String? customerNameForPayLater,
    SaleRecord? resumingHeldSale,
    Map<String, dynamic> extras = const {},
  });
}

/// Today's exact 7-step Dart orchestration, moved verbatim — used when
/// running on the local Drift database. NOT atomic across steps (never was
/// — see the class doc in the Supabase counterpart for what that means in
/// practice); kept exactly as before since this is a non-issue with
/// SQLite's single local writer and changing it isn't in scope here.
class OrchestratedCompleteSaleUseCase implements CompleteSaleUseCase {
  OrchestratedCompleteSaleUseCase({
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
  Future<SaleRecord> holdSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required List<SaleLineInput> lines,
    SaleRecord? replacing,
  }) {
    if (replacing != null) {
      return _posRepository.reholdSale(
        saleId: replacing.id,
        lines: lines,
        customerId: customerId,
        holdLabel: holdLabel ?? replacing.holdLabel,
      );
    }
    return _posRepository.createSale(
      storeId: storeId,
      branchId: branchId,
      cashierId: cashierId,
      shiftId: shiftId,
      customerId: customerId,
      holdLabel: holdLabel,
      status: SaleStatus.held,
      lines: lines,
    );
  }

  @override
  Future<CheckoutResult> checkout({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    required SalePaymentMethod paymentMethod,
    required List<SaleLineInput> lines,
    int? amountTenderedMinorUnits,
    int? changeGivenMinorUnits,
    String? customerNameForPayLater,
    SaleRecord? resumingHeldSale,
    Map<String, dynamic> extras = const {},
  }) async {
    final chosenCustomerId = extras['customer_id'] as String?;
    if (resumingHeldSale != null) {
      final held = await _posRepository.getSale(resumingHeldSale.id);
      if (held == null || held.status != SaleStatus.held) throw const HeldSaleClosedException();
    }
    final sale = await _posRepository.createSale(
      storeId: storeId,
      branchId: branchId,
      cashierId: cashierId,
      shiftId: shiftId,
      customerId: chosenCustomerId,
      status: SaleStatus.completed,
      lines: lines,
    );

    for (final line in sale.lines) {
      await _inventoryRepository.recordStockMovement(
        storeId: storeId,
        productId: line.productId,
        branchId: branchId,
        type: StockMovementType.saleOut,
        quantity: line.quantity,
        referenceType: 'SALE',
        referenceId: sale.id,
        createdByUserId: cashierId,
      );
    }

    final revenueMinorUnits = sale.subtotalMinorUnits - sale.discountTotalMinorUnits;
    final cogsMinorUnits = sale.lines.fold<int>(0, (s, l) => s + l.costPriceSnapshotMinorUnits * l.quantity);

    final journalEntry = switch (paymentMethod) {
      SalePaymentMethod.cash => await _accountingPostingService.postCashSale(
          storeId: storeId,
          branchId: branchId,
          saleId: sale.id,
          createdByUserId: cashierId,
          revenueMinorUnits: revenueMinorUnits,
          cogsMinorUnits: cogsMinorUnits,
          taxMinorUnits: sale.taxTotalMinorUnits,
        ),
      SalePaymentMethod.card => await _accountingPostingService.postCardSale(
          storeId: storeId,
          branchId: branchId,
          saleId: sale.id,
          createdByUserId: cashierId,
          revenueMinorUnits: revenueMinorUnits,
          cogsMinorUnits: cogsMinorUnits,
          taxMinorUnits: sale.taxTotalMinorUnits,
        ),
      SalePaymentMethod.payLater => await _accountingPostingService.postPayLaterSale(
          storeId: storeId,
          branchId: branchId,
          saleId: sale.id,
          createdByUserId: cashierId,
          revenueMinorUnits: revenueMinorUnits,
          cogsMinorUnits: cogsMinorUnits,
          taxMinorUnits: sale.taxTotalMinorUnits,
        ),
    };

    String? debtEntryId;
    if (paymentMethod == SalePaymentMethod.payLater) {
      final name = (customerNameForPayLater ?? '').trim();
      final customers = chosenCustomerId == null ? null : await _debtsRepository.watchCustomers(storeId).first;
      var customer = customers?.where((c) => c.id == chosenCustomerId).firstOrNull;
      customer ??= name.isEmpty ? null : await _debtsRepository.findCustomerByName(storeId, name);
      customer ??= await _debtsRepository.createCustomer(storeId, name.isEmpty ? 'Walk-in customer' : name);
      final phone = (extras['customer_phone'] as String?)?.trim();
      if (phone != null && phone.isNotEmpty) await _debtsRepository.updateCustomerPhone(customer.id, phone);
      final debtEntry = await _debtsRepository.createDebtEntry(
        storeId: storeId,
        branchId: branchId,
        customerId: customer.id,
        saleId: sale.id,
        journalEntryId: journalEntry.id,
        originalAmountMinorUnits: sale.grandTotalMinorUnits,
        receiptRef: sale.saleNumber,
      );
      debtEntryId = debtEntry.id;

      // Money taken up front on a pay-later sale: the debt's first payment.
      final paidNow = (extras['paid_now_minor_units'] as int?) ?? 0;
      if (paidNow > 0) {
        if (paidNow >= sale.grandTotalMinorUnits) throw ArgumentError('paid in full: not a pay-later sale');
        final paymentId = await _debtsRepository.recordPayment(
          debtLedgerEntryId: debtEntry.id,
          amountMinorUnits: paidNow,
          paymentMethod: 'cash',
          receivedByUserId: cashierId,
        );
        final paymentEntry = await _accountingPostingService.postDebtPaymentReceived(
          storeId: storeId,
          branchId: branchId,
          debtPaymentId: paymentId,
          createdByUserId: cashierId,
          amountMinorUnits: paidNow,
          isCash: true,
        );
        await _debtsRepository.attachJournalEntryToPayment(paymentId, paymentEntry.id);
        amountTenderedMinorUnits = paidNow;
      }
    }

    await _posRepository.completeSale(
      saleId: sale.id,
      paymentMethod: paymentMethod,
      amountTenderedMinorUnits: amountTenderedMinorUnits,
      changeGivenMinorUnits: changeGivenMinorUnits,
      journalEntryId: journalEntry.id,
    );

    if (resumingHeldSale != null) await _posRepository.voidSale(resumingHeldSale.id);

    final finalSale = await _posRepository.getSale(sale.id);

    int? earned, balance;
    final loyaltyCustomerId = extras['loyalty_customer_id'] as String?;
    if (loyaltyCustomerId != null) {
      final redeemed = (extras['points_redeemed'] as int?) ?? 0;
      earned = Loyalty.pointsEarned(
        (finalSale ?? sale).grandTotalMinorUnits,
        (extras['loyalty_spend_per_point_minor'] as int?) ?? 0,
      );
      await _debtsRepository.adjustLoyaltyPoints(loyaltyCustomerId, earned - redeemed);
      final customers = await _debtsRepository.watchCustomers(storeId).first;
      balance = customers.where((c) => c.id == loyaltyCustomerId).firstOrNull?.loyaltyPoints;
    }
    return CheckoutResult(
      sale: finalSale ?? sale,
      debtEntryId: debtEntryId,
      loyaltyPointsEarned: earned,
      loyaltyBalance: balance,
    );
  }
}

/// Runs the entire checkout as one Postgres transaction via the
/// `checkout_sale` RPC — sale + lines, stock deduction, the journal entry,
/// and (for pay-later) the debt entry either all commit together or none of
/// them do. This is strictly more atomicity than the Drift version ever
/// had; worth it here since Postgres offers it "for free" and this is the
/// money/stock-critical path of a commercial product.
class SupabaseAtomicCompleteSaleUseCase implements CompleteSaleUseCase {
  SupabaseAtomicCompleteSaleUseCase({
    required PosRepository posRepository,
    required OfflineWriter writer,
  })  : _posRepository = posRepository,
        _writer = writer;

  final PosRepository _posRepository;
  final OfflineWriter _writer;

  @override
  Future<SaleRecord> holdSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required List<SaleLineInput> lines,
    SaleRecord? replacing,
  }) {
    if (replacing != null) {
      return _posRepository.reholdSale(
        saleId: replacing.id,
        lines: lines,
        customerId: customerId,
        holdLabel: holdLabel ?? replacing.holdLabel,
      );
    }
    // Holding has no other side effects to make atomic — it's just a plain
    // sale row with status='held', same in both implementations.
    return _posRepository.createSale(
      storeId: storeId,
      branchId: branchId,
      cashierId: cashierId,
      shiftId: shiftId,
      customerId: customerId,
      holdLabel: holdLabel,
      status: SaleStatus.held,
      lines: lines,
    );
  }

  @override
  Future<CheckoutResult> checkout({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    required SalePaymentMethod paymentMethod,
    required List<SaleLineInput> lines,
    int? amountTenderedMinorUnits,
    int? changeGivenMinorUnits,
    String? customerNameForPayLater,
    SaleRecord? resumingHeldSale,
    Map<String, dynamic> extras = const {},
  }) async {
    final clientSaleId = IdGenerator.newId();
    final soldAt = DateTime.now();
    final params = <String, dynamic>{
      'p_client_sale_id': clientSaleId,
      'p_branch_id': branchId,
      'p_cashier_id': cashierId,
      'p_payment_method': paymentMethod.name,
      'p_shift_id': shiftId,
      'p_lines': lines
          .map(
            (l) => {
              'product_id': l.productId,
              'quantity': l.quantity,
              'unit_price_minor_units': l.unitPriceMinorUnits,
              'discount_amount_minor_units': l.discountAmountMinorUnits,
              'tax_amount_minor_units': l.taxAmountMinorUnits,
              'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
            },
          )
          .toList(),
      'p_amount_tendered_minor_units': amountTenderedMinorUnits,
      'p_change_given_minor_units': changeGivenMinorUnits,
      'p_customer_name_for_pay_later': customerNameForPayLater,
      'p_resuming_sale_id': null,
      'p_sold_at': soldAt.toUtc().toIso8601String(),
      'p_extras': {...extras, if (resumingHeldSale != null) 'release_held_sale_id': resumingHeldSale.id},
    };

    final paidNow = (extras['paid_now_minor_units'] as int?) ?? 0;
    final provisional = _provisionalSale(
      clientSaleId: clientSaleId,
      storeId: storeId,
      branchId: branchId,
      cashierId: cashierId,
      shiftId: shiftId,
      paymentMethod: paymentMethod,
      lines: lines,
      // Money taken up front on a pay-later sale is kept here, as the
      // server does, so the invoice shows what is still owed.
      amountTenderedMinorUnits:
          paymentMethod == SalePaymentMethod.payLater && paidNow > 0 ? paidNow : amountTenderedMinorUnits,
      changeGivenMinorUnits: changeGivenMinorUnits,
      soldAt: soldAt,
    );
    final Map<String, dynamic>? sent;
    try {
      // Sent now when online with nothing older waiting; otherwise kept on
      // this device and sent in order when the connection is back (its
      // client id makes a late duplicate harmless). Until then it shows in
      // the invoices and shift totals as made.
      sent = await _writer.checkout(
        clientSaleId,
        params,
        preview: saleRow(provisional, customerId: extras['customer_id'] as String?, releases: resumingHeldSale?.id),
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('held sale already closed')) throw const HeldSaleClosedException();
      rethrow;
    }
    if (sent == null || (sent['duplicate'] == true && sent['sale_id'] == null)) {
      return CheckoutResult(
        sale: provisional,
        queuedOffline: true,
        // Estimated; the server credits the points when the sale syncs.
        loyaltyPointsEarned: extras['loyalty_customer_id'] == null
            ? null
            : Loyalty.pointsEarned(
                provisional.grandTotalMinorUnits,
                (extras['loyalty_spend_per_point_minor'] as int?) ?? 0,
              ),
      );
    }

    final json = sent;
    if (json['duplicate'] == true) {
      final existing = await _posRepository.getSale(json['sale_id'] as String);
      if (existing != null) return CheckoutResult(sale: existing);
    }
    final loyalty = json['loyalty'] as Map<String, dynamic>?;

    final saleJson = json['sale'] as Map<String, dynamic>;
    final sale = SaleRecord(
      id: saleJson['id'] as String,
      storeId: saleJson['store_id'] as String,
      branchId: saleJson['branch_id'] as String,
      saleNumber: saleJson['sale_number'] as String,
      status: SaleStatus.completed,
      subtotalMinorUnits: (saleJson['subtotal_minor_units'] as num).toInt(),
      discountTotalMinorUnits: (saleJson['discount_total_minor_units'] as num).toInt(),
      taxTotalMinorUnits: (saleJson['tax_total_minor_units'] as num).toInt(),
      grandTotalMinorUnits: (saleJson['grand_total_minor_units'] as num).toInt(),
      paymentMethod: paymentMethod,
      amountTenderedMinorUnits: (saleJson['amount_tendered_minor_units'] as num?)?.toInt(),
      changeGivenMinorUnits: (saleJson['change_given_minor_units'] as num?)?.toInt(),
      shiftId: saleJson['shift_id'] as String?,
      cashierId: saleJson['cashier_id'] as String,
      journalEntryId: saleJson['journal_entry_id'] as String?,
      createdAt: DateTime.parse(saleJson['created_at'] as String).toLocal(),
      completedAt: DateTime.parse(saleJson['completed_at'] as String).toLocal(),
      lines: (saleJson['lines'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (l) => SaleLineRecord(
              id: l['id'] as String,
              saleId: l['sale_id'] as String,
              productId: l['product_id'] as String,
              quantity: (l['quantity'] as num).toInt(),
              unitPriceMinorUnits: (l['unit_price_minor_units'] as num).toInt(),
              discountAmountMinorUnits: (l['discount_amount_minor_units'] as num).toInt(),
              taxAmountMinorUnits: (l['tax_amount_minor_units'] as num).toInt(),
              lineTotalMinorUnits: (l['line_total_minor_units'] as num).toInt(),
              costPriceSnapshotMinorUnits: (l['cost_price_snapshot_minor_units'] as num).toInt(),
            ),
          )
          .toList(),
    );

    return CheckoutResult(
      sale: sale,
      debtEntryId: json['debt_entry_id'] as String?,
      loyaltyPointsEarned: (loyalty?['earned'] as num?)?.toInt(),
      loyaltyBalance: (loyalty?['balance'] as num?)?.toInt(),
    );
  }

  SaleRecord _provisionalSale({
    required String clientSaleId,
    required String storeId,
    required String branchId,
    required String cashierId,
    required String? shiftId,
    required SalePaymentMethod paymentMethod,
    required List<SaleLineInput> lines,
    required int? amountTenderedMinorUnits,
    required int? changeGivenMinorUnits,
    required DateTime soldAt,
  }) {
    var subtotal = 0, discount = 0, tax = 0;
    for (final l in lines) {
      subtotal += l.unitPriceMinorUnits * l.quantity;
      discount += l.discountAmountMinorUnits;
      tax += l.taxAmountMinorUnits;
    }
    return SaleRecord(
      id: clientSaleId,
      storeId: storeId,
      branchId: branchId,
      // A real number is assigned when the sale reaches the server.
      saleNumber: '$offlineSaleNumberPrefix${clientSaleId.substring(0, 6).toUpperCase()}',
      status: SaleStatus.completed,
      subtotalMinorUnits: subtotal,
      discountTotalMinorUnits: discount,
      taxTotalMinorUnits: tax,
      grandTotalMinorUnits: subtotal - discount + tax,
      paymentMethod: paymentMethod,
      amountTenderedMinorUnits: amountTenderedMinorUnits,
      changeGivenMinorUnits: changeGivenMinorUnits,
      shiftId: shiftId,
      cashierId: cashierId,
      createdAt: soldAt,
      completedAt: soldAt,
      lines: [
        for (final l in lines)
          SaleLineRecord(
            id: IdGenerator.newId(),
            saleId: clientSaleId,
            productId: l.productId,
            quantity: l.quantity,
            unitPriceMinorUnits: l.unitPriceMinorUnits,
            discountAmountMinorUnits: l.discountAmountMinorUnits,
            taxAmountMinorUnits: l.taxAmountMinorUnits,
            lineTotalMinorUnits: l.lineTotalMinorUnits,
            costPriceSnapshotMinorUnits: l.costPriceSnapshotMinorUnits,
          ),
      ],
    );
  }
}

/// [sale] as a `sales` row (lines under `_lines`), the shape the
/// invoice lists read — used to show a sale made offline until the server's
/// copy arrives. [releases]: the held sale it closes.
Map<String, dynamic> saleRow(SaleRecord sale, {String? customerId, String? releases}) => {
      'id': sale.id,
      'client_sale_id': sale.id,
      'store_id': sale.storeId,
      'branch_id': sale.branchId,
      'sale_number': sale.saleNumber,
      'status': sale.status.name,
      'customer_id': customerId ?? sale.customerId,
      'hold_label': sale.holdLabel,
      'subtotal_minor_units': sale.subtotalMinorUnits,
      'discount_total_minor_units': sale.discountTotalMinorUnits,
      'tax_total_minor_units': sale.taxTotalMinorUnits,
      'grand_total_minor_units': sale.grandTotalMinorUnits,
      'payment_method': sale.paymentMethod?.name,
      'amount_tendered_minor_units': sale.amountTenderedMinorUnits,
      'change_given_minor_units': sale.changeGivenMinorUnits,
      'shift_id': sale.shiftId,
      'cashier_id': sale.cashierId,
      'created_at': sale.createdAt.toUtc().toIso8601String(),
      'completed_at': sale.completedAt?.toUtc().toIso8601String(),
      if (releases != null) '_releases': releases,
      '_lines': [
        for (final l in sale.lines)
          {
            'id': l.id,
            'sale_id': sale.id,
            'product_id': l.productId,
            'quantity': l.quantity,
            'unit_price_minor_units': l.unitPriceMinorUnits,
            'discount_amount_minor_units': l.discountAmountMinorUnits,
            'tax_amount_minor_units': l.taxAmountMinorUnits,
            'line_total_minor_units': l.lineTotalMinorUnits,
            'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
          },
      ],
    };

/// A sale kept on this device that closes a held sale is refused by the
/// server when that held sale was closed meanwhile (sold on another till
/// while this one was offline). The money was still taken here, so such a
/// sale is sent again as a sale of its own instead of staying refused and
/// out of sight. Returns how many were sent again.
Future<int> resendRefusedHeldSaleCheckouts(Outbox outbox) async {
  var resent = 0;
  for (final op in outbox.failed) {
    if (op.kind != OutboxKind.checkout || !(op.lastError ?? '').contains('held sale already closed')) continue;
    final params = op.params;
    final extras = params?['p_extras'];
    if (params == null || extras is! Map || !extras.containsKey('release_held_sale_id')) continue;
    await outbox.replace(
      OutboxOp(
        id: op.id,
        kind: op.kind,
        createdAt: op.createdAt,
        table: op.table,
        row: op.row == null ? null : (Map<String, dynamic>.of(op.row!)..remove('_releases')),
        params: {
          ...params,
          'p_extras': Map<String, dynamic>.from(extras)..remove('release_held_sale_id'),
        },
        increments: op.increments,
      ),
    );
    resent++;
  }
  return resent;
}
