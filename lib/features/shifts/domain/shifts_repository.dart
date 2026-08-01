import 'shifts_models.dart';

abstract class ShiftsRepository {
  Future<ShiftRecord> openShift({
    required String storeId,
    required String branchId,
    required String cashierId,
    required int openingCashFloatMinorUnits,
  });

  Future<ShiftRecord?> getOpenShift(String storeId, String cashierId);

  /// [expectedCashAtCloseMinorUnits] is the opening float plus all cash
  /// sales during the shift (computed by the caller from completed sales);
  /// discrepancy = counted - expected.
  Future<void> closeShift({
    required String shiftId,
    required int expectedCashAtCloseMinorUnits,
    required int countedCashAtCloseMinorUnits,
  });

  Stream<List<ShiftRecord>> watchShiftHistory(String storeId, {String? branchId});
}
