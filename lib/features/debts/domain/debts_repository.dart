import 'debts_models.dart';

abstract class DebtsRepository {
  Future<CustomerRecord> createCustomer(String storeId, String name, {String? phone, String? address});
  Stream<List<CustomerRecord>> watchCustomers(String storeId);
  Future<CustomerRecord?> findCustomerByName(String storeId, String name);

  Future<DebtLedgerEntryRecord> createDebtEntry({
    required String storeId,
    required String branchId,
    required String customerId,
    String? saleId,
    String? journalEntryId,
    required int originalAmountMinorUnits,
    String? receiptRef,
  });

  Stream<List<DebtLedgerEntryRecord>> watchDebtsForCustomer(String customerId);
  Stream<List<DebtLedgerEntryRecord>> watchOpenDebts(String storeId);
  Future<DebtLedgerEntryRecord?> findBySaleId(String saleId);

  /// Used when a pay-later sale is partially or fully returned — shrinks
  /// what the customer owes instead of leaving a stale balance.
  Future<void> reduceOriginalAmount(String debtLedgerEntryId, int reduceByMinorUnits);

  /// Inserts the payment row and updates the parent entry's amountPaid/status.
  /// Returns the new payment's id. Does not touch accounting — orchestrate
  /// with AccountingPostingService.postDebtPaymentReceived at the call site,
  /// then call [attachJournalEntryToPayment].
  Future<String> recordPayment({
    required String debtLedgerEntryId,
    required int amountMinorUnits,
    required String paymentMethod,
    required String receivedByUserId,
  });

  Future<void> attachJournalEntryToPayment(String paymentId, String journalEntryId);

  Stream<List<DebtPaymentRecord>> watchPaymentHistory(String debtLedgerEntryId);
}
