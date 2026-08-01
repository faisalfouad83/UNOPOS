enum ShiftStatus { open, closed }

class ShiftRecord {
  const ShiftRecord({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.cashierId,
    required this.openedAt,
    this.closedAt,
    this.openingCashFloatMinorUnits = 0,
    this.expectedCashAtCloseMinorUnits,
    this.countedCashAtCloseMinorUnits,
    this.discrepancyMinorUnits,
    this.status = ShiftStatus.open,
  });

  final String id;
  final String storeId;
  final String branchId;
  final String cashierId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int openingCashFloatMinorUnits;
  final int? expectedCashAtCloseMinorUnits;
  final int? countedCashAtCloseMinorUnits;
  final int? discrepancyMinorUnits;
  final ShiftStatus status;
}
