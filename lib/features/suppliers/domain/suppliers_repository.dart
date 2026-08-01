import 'suppliers_models.dart';

abstract class SuppliersRepository {
  Future<SupplierRecord> createSupplier({
    required String storeId,
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
  });

  Stream<List<SupplierRecord>> watchSuppliers(String storeId);

  Future<String> recordTransaction({
    required String storeId,
    required String supplierId,
    required SupplierTransactionType type,
    required int amountMinorUnits,
    String? relatedPurchaseOrderId,
    DateTime? deliveryDate,
    required String createdByUserId,
  });

  Future<void> attachJournalEntry(String transactionId, String journalEntryId);

  Stream<List<SupplierTransactionRecord>> watchTransactions(String supplierId);

  /// sum(purchase) + sum(adjustment) - sum(payment), in minor units.
  Future<int> balanceOwed(String supplierId);
}
