import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/shifts_models.dart';
import '../domain/shifts_repository.dart';

class DriftShiftsRepository implements ShiftsRepository {
  DriftShiftsRepository(this._db);

  final AppDatabase _db;

  ShiftRecord _mapRow(Shift row) => ShiftRecord(
        id: row.id,
        storeId: row.storeId,
        branchId: row.branchId,
        cashierId: row.cashierId,
        openedAt: row.openedAt,
        closedAt: row.closedAt,
        openingCashFloatMinorUnits: row.openingCashFloatMinorUnits,
        expectedCashAtCloseMinorUnits: row.expectedCashAtCloseMinorUnits,
        countedCashAtCloseMinorUnits: row.countedCashAtCloseMinorUnits,
        discrepancyMinorUnits: row.discrepancyMinorUnits,
        status: row.status == 'closed' ? ShiftStatus.closed : ShiftStatus.open,
      );

  @override
  Future<ShiftRecord> openShift({
    required String storeId,
    required String branchId,
    required String cashierId,
    required int openingCashFloatMinorUnits,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _db.into(_db.shifts).insert(
          ShiftsCompanion.insert(
            id: id,
            storeId: storeId,
            branchId: branchId,
            cashierId: cashierId,
            openedAt: now,
            openingCashFloatMinorUnits: Value(openingCashFloatMinorUnits),
          ),
        );
    return ShiftRecord(
      id: id,
      storeId: storeId,
      branchId: branchId,
      cashierId: cashierId,
      openedAt: now,
      openingCashFloatMinorUnits: openingCashFloatMinorUnits,
    );
  }

  @override
  Future<ShiftRecord?> getOpenShift(String storeId, String cashierId) async {
    final row = await (_db.select(_db.shifts)
          ..where((t) => t.storeId.equals(storeId) & t.cashierId.equals(cashierId) & t.status.equals('open')))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> closeShift({
    required String shiftId,
    required int expectedCashAtCloseMinorUnits,
    required int countedCashAtCloseMinorUnits,
  }) async {
    await (_db.update(_db.shifts)..where((t) => t.id.equals(shiftId))).write(
      ShiftsCompanion(
        status: const Value('closed'),
        closedAt: Value(DateTime.now()),
        expectedCashAtCloseMinorUnits: Value(expectedCashAtCloseMinorUnits),
        countedCashAtCloseMinorUnits: Value(countedCashAtCloseMinorUnits),
        discrepancyMinorUnits: Value(countedCashAtCloseMinorUnits - expectedCashAtCloseMinorUnits),
      ),
    );
  }

  @override
  Stream<List<ShiftRecord>> watchShiftHistory(String storeId, {String? branchId}) {
    final query = _db.select(_db.shifts)..where((t) => t.storeId.equals(storeId));
    if (branchId != null) {
      query.where((t) => t.branchId.equals(branchId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.openedAt)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }
}
