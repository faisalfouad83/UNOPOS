import 'package:supabase_flutter/supabase_flutter.dart';

import '../../accounting/domain/accounting_posting_service.dart';
import '../../debts/domain/debts_repository.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../inventory/domain/inventory_repository.dart';
import 'pos_models.dart';
import 'pos_repository.dart';

class CheckoutResult {
  const CheckoutResult({required this.sale, this.debtEntryId});
  final SaleRecord sale;
  final String? debtEntryId;
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
  });

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
  }) {
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
  }) async {
    final sale = resumingHeldSale ??
        await _posRepository.createSale(
          storeId: storeId,
          branchId: branchId,
          cashierId: cashierId,
          shiftId: shiftId,
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
      var customer = name.isEmpty ? null : await _debtsRepository.findCustomerByName(storeId, name);
      customer ??= await _debtsRepository.createCustomer(storeId, name.isEmpty ? 'Walk-in customer' : name);
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
    }

    await _posRepository.completeSale(
      saleId: sale.id,
      paymentMethod: paymentMethod,
      amountTenderedMinorUnits: amountTenderedMinorUnits,
      changeGivenMinorUnits: changeGivenMinorUnits,
      journalEntryId: journalEntry.id,
    );

    final finalSale = await _posRepository.getSale(sale.id);
    return CheckoutResult(sale: finalSale ?? sale, debtEntryId: debtEntryId);
  }
}

/// Runs the entire checkout as one Postgres transaction via the
/// `checkout_sale` RPC — sale + lines, stock deduction, the journal entry,
/// and (for pay-later) the debt entry either all commit together or none of
/// them do. This is strictly more atomicity than the Drift version ever
/// had; worth it here since Postgres offers it "for free" and this is the
/// money/stock-critical path of a commercial product.
class SupabaseAtomicCompleteSaleUseCase implements CompleteSaleUseCase {
  SupabaseAtomicCompleteSaleUseCase({required SupabaseClient client, required PosRepository posRepository})
      : _client = client,
        _posRepository = posRepository;

  final SupabaseClient _client;
  final PosRepository _posRepository;

  @override
  Future<SaleRecord> holdSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required List<SaleLineInput> lines,
  }) {
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
  }) async {
    final json = await _client.rpc('checkout_sale', params: {
      'p_branch_id': branchId,
      'p_cashier_id': cashierId,
      'p_payment_method': paymentMethod.name,
      'p_shift_id': shiftId,
      'p_lines': resumingHeldSale != null
          ? null
          : lines
              .map((l) => {
                    'product_id': l.productId,
                    'quantity': l.quantity,
                    'unit_price_minor_units': l.unitPriceMinorUnits,
                    'discount_amount_minor_units': l.discountAmountMinorUnits,
                    'tax_amount_minor_units': l.taxAmountMinorUnits,
                    'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
                  })
              .toList(),
      'p_amount_tendered_minor_units': amountTenderedMinorUnits,
      'p_change_given_minor_units': changeGivenMinorUnits,
      'p_customer_name_for_pay_later': customerNameForPayLater,
      'p_resuming_sale_id': resumingHeldSale?.id,
    }) as Map<String, dynamic>;

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
      createdAt: DateTime.parse(saleJson['created_at'] as String),
      completedAt: DateTime.parse(saleJson['completed_at'] as String),
      lines: (saleJson['lines'] as List).cast<Map<String, dynamic>>().map((l) => SaleLineRecord(
            id: l['id'] as String,
            saleId: l['sale_id'] as String,
            productId: l['product_id'] as String,
            quantity: (l['quantity'] as num).toInt(),
            unitPriceMinorUnits: (l['unit_price_minor_units'] as num).toInt(),
            discountAmountMinorUnits: (l['discount_amount_minor_units'] as num).toInt(),
            taxAmountMinorUnits: (l['tax_amount_minor_units'] as num).toInt(),
            lineTotalMinorUnits: (l['line_total_minor_units'] as num).toInt(),
            costPriceSnapshotMinorUnits: (l['cost_price_snapshot_minor_units'] as num).toInt(),
          )).toList(),
    );

    return CheckoutResult(sale: sale, debtEntryId: json['debt_entry_id'] as String?);
  }
}
