import '../../auth/domain/auth_models.dart';
import '../../settings/domain/settings_models.dart';

enum BreakEndKind {
  returned,
  early,
  reconciled;

  static BreakEndKind? fromName(String? name) => BreakEndKind.values.where((k) => k.name == name).firstOrNull;
}

class EmployeeBreakRecord {
  const EmployeeBreakRecord({
    required this.id,
    required this.storeId,
    this.branchId,
    required this.userId,
    this.shiftId,
    required this.startedAt,
    this.endedAt,
    required this.allowedMinutes,
    this.endKind,
    this.exceededMinutes = 0,
  });

  final String id;
  final String storeId;
  final String? branchId;
  final String userId;
  final String? shiftId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int allowedMinutes;
  final BreakEndKind? endKind;
  final int exceededMinutes;

  bool get isOpen => endedAt == null;
  DateTime get allowedUntil => startedAt.add(Duration(minutes: allowedMinutes));
  Duration duration([DateTime? now]) => (endedAt ?? now ?? DateTime.now()).difference(startedAt);
}

/// Why a break can't start now.
enum BreakRefusal { off, roleNotAllowed, alreadyOnBreak, noneLeftToday }

/// The same checks the server makes in start_break.
BreakRefusal? canStartBreak({
  required AppSettingsRecord settings,
  required EmployeeRecord employee,
  required int breaksTakenToday,
  required bool hasOpenBreak,
}) {
  if (!settings.breakEnabled) return BreakRefusal.off;
  if (!settings.breakRoleNames.contains(employee.role.name)) return BreakRefusal.roleNotAllowed;
  if (hasOpenBreak) return BreakRefusal.alreadyOnBreak;
  if (breaksTakenToday >= settings.breakMaxPerDay) return BreakRefusal.noneLeftToday;
  return null;
}

/// How a break ended, as the server records it: before its time is up
/// (early), after (returned, with the minutes over), or closed when the
/// employee signed in again after the app was shut (reconciled).
({BreakEndKind kind, int exceededMinutes}) breakOutcome(
  EmployeeBreakRecord b,
  DateTime endedAt, {
  bool reconciled = false,
}) {
  final minutes = (endedAt.difference(b.startedAt).inSeconds / 60).ceil();
  final exceeded = minutes - b.allowedMinutes;
  final kind = reconciled
      ? BreakEndKind.reconciled
      : endedAt.isBefore(b.allowedUntil)
          ? BreakEndKind.early
          : BreakEndKind.returned;
  return (kind: kind, exceededMinutes: exceeded > 0 ? exceeded : 0);
}

/// Thrown when a break can't start or end.
class BreakException implements Exception {
  const BreakException({this.refusal, this.wrongPin = false});
  final BreakRefusal? refusal;
  final bool wrongPin;
}
