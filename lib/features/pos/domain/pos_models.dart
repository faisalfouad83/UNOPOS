enum SaleStatus { held, completed, refunded, partiallyRefunded, voided }

enum SalePaymentMethod { cash, card, payLater }

class SaleLineInput {
  const SaleLineInput({
    required this.productId,
    required this.quantity,
    required this.unitPriceMinorUnits,
    this.discountAmountMinorUnits = 0,
    this.taxAmountMinorUnits = 0,
    required this.costPriceSnapshotMinorUnits,
  });

  final String productId;
  final int quantity;
  final int unitPriceMinorUnits;
  final int discountAmountMinorUnits;
  final int taxAmountMinorUnits;
  final int costPriceSnapshotMinorUnits;

  int get lineTotalMinorUnits => (unitPriceMinorUnits * quantity) - discountAmountMinorUnits + taxAmountMinorUnits;
}

class SaleLineRecord {
  const SaleLineRecord({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinorUnits,
    this.discountAmountMinorUnits = 0,
    this.taxAmountMinorUnits = 0,
    required this.lineTotalMinorUnits,
    this.costPriceSnapshotMinorUnits = 0,
  });

  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final int unitPriceMinorUnits;
  final int discountAmountMinorUnits;
  final int taxAmountMinorUnits;
  final int lineTotalMinorUnits;
  final int costPriceSnapshotMinorUnits;
}

class SaleRecord {
  const SaleRecord({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.saleNumber,
    required this.status,
    this.customerId,
    this.holdLabel,
    this.subtotalMinorUnits = 0,
    this.discountTotalMinorUnits = 0,
    this.taxTotalMinorUnits = 0,
    this.grandTotalMinorUnits = 0,
    this.paymentMethod,
    this.amountTenderedMinorUnits,
    this.changeGivenMinorUnits,
    this.shiftId,
    required this.cashierId,
    this.journalEntryId,
    required this.createdAt,
    this.completedAt,
    this.lines = const [],
  });

  final String id;
  final String storeId;
  final String branchId;
  final String saleNumber;
  final SaleStatus status;
  final String? customerId;
  final String? holdLabel;
  final int subtotalMinorUnits;
  final int discountTotalMinorUnits;
  final int taxTotalMinorUnits;
  final int grandTotalMinorUnits;
  final SalePaymentMethod? paymentMethod;
  final int? amountTenderedMinorUnits;
  final int? changeGivenMinorUnits;
  final String? shiftId;
  final String cashierId;
  final String? journalEntryId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<SaleLineRecord> lines;
}
