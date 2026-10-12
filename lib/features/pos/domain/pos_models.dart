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
    this.quantityReturned = 0,
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

  /// How many of [quantity] have since been returned.
  final int quantityReturned;

  int get remainingQuantity => quantity - quantityReturned;

  /// What one unit refunds: the line total spread evenly per unit (same
  /// whole-unit division the server's return uses).
  int get unitRefundMinorUnits => quantity == 0 ? 0 : lineTotalMinorUnits ~/ quantity;

  int get refundedMinorUnits => unitRefundMinorUnits * quantityReturned;

  /// The line after returns: what it still counts for in sales and profit.
  int get netTotalMinorUnits => lineTotalMinorUnits - refundedMinorUnits;
  int get netTaxMinorUnits => quantity == 0 ? 0 : taxAmountMinorUnits * remainingQuantity ~/ quantity;
  int get netCostMinorUnits => costPriceSnapshotMinorUnits * remainingQuantity;
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

  int get refundedMinorUnits => lines.fold(0, (s, l) => s + l.refundedMinorUnits);

  /// The invoice total after any returns.
  int get netTotalMinorUnits => grandTotalMinorUnits - refundedMinorUnits;
  int get netTaxMinorUnits => refundedMinorUnits == 0 ? taxTotalMinorUnits : lines.fold(0, (s, l) => s + l.netTaxMinorUnits);
  bool get hasReturns => lines.any((l) => l.quantityReturned > 0);
  bool get canReturn =>
      (status == SaleStatus.completed || status == SaleStatus.partiallyRefunded) &&
      lines.any((l) => l.remainingQuantity > 0);
}
