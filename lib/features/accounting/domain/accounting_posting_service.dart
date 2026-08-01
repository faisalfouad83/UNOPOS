import '../../../core/constants/default_chart_of_accounts.dart';
import 'accounting_models.dart';
import 'accounting_repository.dart';

/// Translates real-world business events into balanced double-entry journal
/// postings. This is the only place in the app that should know which
/// accounts a given kind of transaction touches — POS/Debts/Suppliers/etc.
/// call these methods rather than constructing [JournalLineInput]s themselves.
class AccountingPostingService {
  AccountingPostingService(this._repo);

  final AccountingRepository _repo;

  Future<JournalEntryRecord> postCashSale({
    required String storeId,
    required String branchId,
    required String saleId,
    required String createdByUserId,
    required int revenueMinorUnits,
    required int cogsMinorUnits,
    required int taxMinorUnits,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.sale,
      referenceId: saleId,
      memo: 'Cash sale',
      createdByUserId: createdByUserId,
      lines: _saleLines(
        settlementAccount: SystemAccountCodes.cash,
        revenueMinorUnits: revenueMinorUnits,
        cogsMinorUnits: cogsMinorUnits,
        taxMinorUnits: taxMinorUnits,
      ),
    );
  }

  Future<JournalEntryRecord> postCardSale({
    required String storeId,
    required String branchId,
    required String saleId,
    required String createdByUserId,
    required int revenueMinorUnits,
    required int cogsMinorUnits,
    required int taxMinorUnits,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.sale,
      referenceId: saleId,
      memo: 'Card sale',
      createdByUserId: createdByUserId,
      lines: _saleLines(
        settlementAccount: SystemAccountCodes.bank,
        revenueMinorUnits: revenueMinorUnits,
        cogsMinorUnits: cogsMinorUnits,
        taxMinorUnits: taxMinorUnits,
      ),
    );
  }

  Future<JournalEntryRecord> postPayLaterSale({
    required String storeId,
    required String branchId,
    required String saleId,
    required String createdByUserId,
    required int revenueMinorUnits,
    required int cogsMinorUnits,
    required int taxMinorUnits,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.sale,
      referenceId: saleId,
      memo: 'Pay-later sale (on account)',
      createdByUserId: createdByUserId,
      lines: _saleLines(
        settlementAccount: SystemAccountCodes.accountsReceivable,
        revenueMinorUnits: revenueMinorUnits,
        cogsMinorUnits: cogsMinorUnits,
        taxMinorUnits: taxMinorUnits,
      ),
    );
  }

  List<JournalLineInput> _saleLines({
    required String settlementAccount,
    required int revenueMinorUnits,
    required int cogsMinorUnits,
    required int taxMinorUnits,
  }) {
    final totalSettlement = revenueMinorUnits + taxMinorUnits;
    return [
      JournalLineInput(accountCode: settlementAccount, debitMinorUnits: totalSettlement, description: 'Settlement'),
      JournalLineInput(accountCode: SystemAccountCodes.salesRevenue, creditMinorUnits: revenueMinorUnits, description: 'Revenue'),
      if (taxMinorUnits > 0)
        JournalLineInput(accountCode: SystemAccountCodes.vatPayable, creditMinorUnits: taxMinorUnits, description: 'Tax collected'),
      if (cogsMinorUnits > 0) ...[
        JournalLineInput(accountCode: SystemAccountCodes.costOfGoodsSold, debitMinorUnits: cogsMinorUnits, description: 'COGS'),
        JournalLineInput(accountCode: SystemAccountCodes.inventory, creditMinorUnits: cogsMinorUnits, description: 'Inventory reduction'),
      ],
    ];
  }

  Future<JournalEntryRecord> postDebtPaymentReceived({
    required String storeId,
    required String branchId,
    required String debtPaymentId,
    required String createdByUserId,
    required int amountMinorUnits,
    required bool isCash,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.debtPayment,
      referenceId: debtPaymentId,
      memo: 'Customer debt payment received',
      createdByUserId: createdByUserId,
      lines: [
        JournalLineInput(
          accountCode: isCash ? SystemAccountCodes.cash : SystemAccountCodes.bank,
          debitMinorUnits: amountMinorUnits,
        ),
        JournalLineInput(accountCode: SystemAccountCodes.accountsReceivable, creditMinorUnits: amountMinorUnits),
      ],
    );
  }

  Future<JournalEntryRecord> postSupplierPurchase({
    required String storeId,
    required String branchId,
    required String purchaseOrderId,
    required String createdByUserId,
    required int amountMinorUnits,
    required bool paidImmediately,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.purchase,
      referenceId: purchaseOrderId,
      memo: paidImmediately ? 'Supplier purchase (paid)' : 'Supplier purchase (on credit)',
      createdByUserId: createdByUserId,
      lines: [
        JournalLineInput(accountCode: SystemAccountCodes.inventory, debitMinorUnits: amountMinorUnits),
        JournalLineInput(
          accountCode: paidImmediately ? SystemAccountCodes.cash : SystemAccountCodes.accountsPayable,
          creditMinorUnits: amountMinorUnits,
        ),
      ],
    );
  }

  Future<JournalEntryRecord> postSupplierPayment({
    required String storeId,
    required String branchId,
    required String supplierTransactionId,
    required String createdByUserId,
    required int amountMinorUnits,
    required bool isCash,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.supplierPayment,
      referenceId: supplierTransactionId,
      memo: 'Payment to supplier',
      createdByUserId: createdByUserId,
      lines: [
        JournalLineInput(accountCode: SystemAccountCodes.accountsPayable, debitMinorUnits: amountMinorUnits),
        JournalLineInput(
          accountCode: isCash ? SystemAccountCodes.cash : SystemAccountCodes.bank,
          creditMinorUnits: amountMinorUnits,
        ),
      ],
    );
  }

  Future<JournalEntryRecord> postExpense({
    required String storeId,
    required String branchId,
    required String expenseAccountCode,
    required String createdByUserId,
    required int amountMinorUnits,
    required bool isCash,
    String memo = 'Expense',
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.expense,
      memo: memo,
      createdByUserId: createdByUserId,
      lines: [
        JournalLineInput(accountCode: expenseAccountCode, debitMinorUnits: amountMinorUnits),
        JournalLineInput(
          accountCode: isCash ? SystemAccountCodes.cash : SystemAccountCodes.bank,
          creditMinorUnits: amountMinorUnits,
        ),
      ],
    );
  }

  Future<JournalEntryRecord> postSaleReturn({
    required String storeId,
    required String branchId,
    required String saleReturnId,
    required String createdByUserId,
    required int refundMinorUnits,
    required int restockedCogsMinorUnits,
    required bool refundToCash,
    required bool wasPayLater,
  }) {
    final settlementAccount = wasPayLater
        ? SystemAccountCodes.accountsReceivable
        : (refundToCash ? SystemAccountCodes.cash : SystemAccountCodes.bank);
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.returnEntry,
      referenceId: saleReturnId,
      memo: 'Sale return / refund',
      createdByUserId: createdByUserId,
      lines: [
        JournalLineInput(accountCode: SystemAccountCodes.salesReturns, debitMinorUnits: refundMinorUnits),
        JournalLineInput(accountCode: settlementAccount, creditMinorUnits: refundMinorUnits),
        if (restockedCogsMinorUnits > 0) ...[
          JournalLineInput(accountCode: SystemAccountCodes.inventory, debitMinorUnits: restockedCogsMinorUnits),
          JournalLineInput(accountCode: SystemAccountCodes.costOfGoodsSold, creditMinorUnits: restockedCogsMinorUnits),
        ],
      ],
    );
  }

  Future<JournalEntryRecord> postStockShrinkage({
    required String storeId,
    required String branchId,
    required String stockMovementId,
    required String createdByUserId,
    required int amountMinorUnits,
  }) {
    return _repo.postJournalEntry(
      storeId: storeId,
      branchId: branchId,
      referenceType: JournalReferenceType.adjustment,
      referenceId: stockMovementId,
      memo: 'Stock shrinkage / adjustment',
      createdByUserId: createdByUserId,
      lines: [
        JournalLineInput(accountCode: SystemAccountCodes.shrinkageExpense, debitMinorUnits: amountMinorUnits),
        JournalLineInput(accountCode: SystemAccountCodes.inventory, creditMinorUnits: amountMinorUnits),
      ],
    );
  }
}
