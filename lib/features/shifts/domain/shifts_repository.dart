import 'shift_cash_summary.dart';
import 'shifts_models.dart';

abstract class ShiftsRepository {
  Future<ShiftRecord> openShift({
    required String storeId,
    required String branchId,
    required String cashierId,
    required int openingCashFloatMinorUnits,
  });

  Future<ShiftRecord?> getOpenShift(String storeId, String cashierId);

  /// [expectedCashAtCloseMinorUnits] is [cashSummary]'s expected cash as the
  /// till saw it; discrepancy = counted - expected. (The shared backend works
  /// both out again from everything recorded for the shift once the close
  /// reaches it.)
  Future<void> closeShift({
    required String shiftId,
    required int expectedCashAtCloseMinorUnits,
    required int countedCashAtCloseMinorUnits,
  });

  /// What should be in [shift]'s cash drawer now.
  Future<ShiftCashSummary> cashSummary(ShiftRecord shift);

  Stream<List<ShiftRecord>> watchShiftHistory(String storeId, {String? branchId});
}
