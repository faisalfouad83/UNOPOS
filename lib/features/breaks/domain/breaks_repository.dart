import 'break_models.dart';

abstract class BreaksRepository {
  /// Starts a break for [userId] (limits checked by the server).
  Future<EmployeeBreakRecord> startBreak({
    required String storeId,
    required String userId,
    String? branchId,
    String? shiftId,
  });

  /// Ends [breakId]. Only the employee who took it, with their own PIN.
  Future<EmployeeBreakRecord> endBreak({required String breakId, required String pin, bool reconciled = false});

  /// The break [userId] is on right now, if any.
  Future<EmployeeBreakRecord?> openBreakFor(String storeId, String userId);

  /// Breaks started from [from] (inclusive) to [to] (exclusive), newest first.
  Future<List<EmployeeBreakRecord>> breaksBetween(String storeId, DateTime from, DateTime to);
}
