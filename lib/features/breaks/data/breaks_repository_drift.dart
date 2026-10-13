import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/security/passcode_hasher.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/constants/roles.dart';
import '../../auth/domain/auth_models.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/break_models.dart';
import '../domain/breaks_repository.dart';

/// The local (single-device) build: the same rules as the server's
/// start_break / end_break.
class DriftBreaksRepository implements BreaksRepository {
  DriftBreaksRepository(this._db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  EmployeeBreakRecord _map(EmployeeBreak row) => EmployeeBreakRecord(
        id: row.id,
        storeId: row.storeId,
        branchId: row.branchId,
        userId: row.userId,
        shiftId: row.shiftId,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        allowedMinutes: row.allowedMinutes,
        endKind: BreakEndKind.fromName(row.endKind),
        exceededMinutes: row.exceededMinutes,
      );

  @override
  Future<EmployeeBreakRecord> startBreak({
    required String storeId,
    required String userId,
    String? branchId,
    String? shiftId,
  }) async {
    final user =
        await (_db.select(_db.users)..where((t) => t.id.equals(userId) & t.storeId.equals(storeId))).getSingleOrNull();
    if (user == null) throw const BreakException(refusal: BreakRefusal.roleNotAllowed);
    final settingsRow =
        await (_db.select(_db.appSettingsTable)..where((t) => t.storeId.equals(storeId))).getSingleOrNull();
    final now = _now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final today = await (_db.select(_db.employeeBreaks)
          ..where((t) => t.userId.equals(userId) & t.startedAt.isBiggerOrEqualValue(dayStart)))
        .get();
    final open =
        await (_db.select(_db.employeeBreaks)..where((t) => t.userId.equals(userId) & t.endedAt.isNull())).get();
    final refusal = settingsRow == null
        ? BreakRefusal.off
        : canStartBreak(
            settings: _settings(settingsRow),
            employee: EmployeeRecord(
              id: user.id,
              storeId: user.storeId,
              name: user.name,
              role: StoreRole.fromName(user.role),
              pinHash: '',
            ),
            breaksTakenToday: today.length,
            hasOpenBreak: open.isNotEmpty,
          );
    if (refusal != null) throw BreakException(refusal: refusal);
    final row = EmployeeBreaksCompanion.insert(
      id: IdGenerator.newId(),
      storeId: storeId,
      branchId: Value(branchId),
      userId: userId,
      shiftId: Value(shiftId),
      startedAt: now,
      allowedMinutes: settingsRow!.breakMaxMinutes,
    );
    await _db.into(_db.employeeBreaks).insert(row);
    return _map(await (_db.select(_db.employeeBreaks)..where((t) => t.id.equals(row.id.value))).getSingle());
  }

  @override
  Future<EmployeeBreakRecord> endBreak({required String breakId, required String pin, bool reconciled = false}) async {
    final row = await (_db.select(_db.employeeBreaks)..where((t) => t.id.equals(breakId))).getSingle();
    final record = _map(row);
    if (!record.isOpen) return record;
    final user = await (_db.select(_db.users)..where((t) => t.id.equals(row.userId))).getSingle();
    if (!user.isActive || !PasscodeHasher.verify(pin, user.pinHash)) throw const BreakException(wrongPin: true);
    final now = _now();
    final outcome = breakOutcome(record, now, reconciled: reconciled);
    await (_db.update(_db.employeeBreaks)..where((t) => t.id.equals(breakId))).write(
      EmployeeBreaksCompanion(
        endedAt: Value(now),
        endKind: Value(outcome.kind.name),
        exceededMinutes: Value(outcome.exceededMinutes),
      ),
    );
    return _map(await (_db.select(_db.employeeBreaks)..where((t) => t.id.equals(breakId))).getSingle());
  }

  @override
  Future<EmployeeBreakRecord?> openBreakFor(String storeId, String userId) async {
    final row = await (_db.select(_db.employeeBreaks)
          ..where((t) => t.storeId.equals(storeId) & t.userId.equals(userId) & t.endedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Future<List<EmployeeBreakRecord>> breaksBetween(String storeId, DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.employeeBreaks)
          ..where((t) =>
              t.storeId.equals(storeId) & t.startedAt.isBiggerOrEqualValue(from) & t.startedAt.isSmallerThanValue(to))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    return rows.map(_map).toList();
  }

  static AppSettingsRecord _settings(AppSettingsTableData row) => AppSettingsRecord(
        storeId: row.storeId,
        breakEnabled: row.breakEnabled,
        breakMaxMinutes: row.breakMaxMinutes,
        breakMaxPerDay: row.breakMaxPerDay,
        breakRoles: row.breakRoles,
      );
}
