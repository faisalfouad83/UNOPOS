class CustomerRecord {
  const CustomerRecord({
    required this.id,
    required this.storeId,
    required this.name,
    this.phone,
    this.address,
  });
  final String id;
  final String storeId;
  final String name;
  final String? phone;
  final String? address;
}

enum DebtStatus { open, partiallyPaid, paid }

class DebtLedgerEntryRecord {
  const DebtLedgerEntryRecord({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.customerId,
    this.saleId,
    this.journalEntryId,
    required this.originalAmountMinorUnits,
    this.amountPaidMinorUnits = 0,
    this.receiptRef,
    this.status = DebtStatus.open,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String branchId;
  final String customerId;
  final String? saleId;
  final String? journalEntryId;
  final int originalAmountMinorUnits;
  final int amountPaidMinorUnits;
  final String? receiptRef;
  final DebtStatus status;
  final DateTime createdAt;

  int get balanceRemainingMinorUnits => originalAmountMinorUnits - amountPaidMinorUnits;
}

class DebtPaymentRecord {
  const DebtPaymentRecord({
    required this.id,
    required this.debtLedgerEntryId,
    required this.amountMinorUnits,
    required this.paymentMethod,
    required this.receivedByUserId,
    this.journalEntryId,
    required this.paidAt,
  });

  final String id;
  final String debtLedgerEntryId;
  final int amountMinorUnits;
  final String paymentMethod;
  final String receivedByUserId;
  final String? journalEntryId;
  final DateTime paidAt;
}
