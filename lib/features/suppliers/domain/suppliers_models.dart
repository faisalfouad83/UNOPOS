class SupplierRecord {
  const SupplierRecord({
    required this.id,
    required this.storeId,
    required this.name,
    this.contactPhone,
    this.contactPerson,
    this.address,
  });
  final String id;
  final String storeId;
  final String name;
  final String? contactPhone;
  final String? contactPerson;
  final String? address;
}

enum SupplierTransactionType { purchase, payment, adjustment }

class SupplierTransactionRecord {
  const SupplierTransactionRecord({
    required this.id,
    required this.storeId,
    required this.supplierId,
    required this.type,
    required this.amountMinorUnits,
    this.relatedPurchaseOrderId,
    this.deliveryDate,
    this.journalEntryId,
    required this.createdByUserId,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String supplierId;
  final SupplierTransactionType type;
  final int amountMinorUnits;
  final String? relatedPurchaseOrderId;
  final DateTime? deliveryDate;
  final String? journalEntryId;
  final String createdByUserId;
  final DateTime createdAt;
}
