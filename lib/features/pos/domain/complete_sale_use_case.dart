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
class CompleteSaleUseCase {
  CompleteSaleUseCase({
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
