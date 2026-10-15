import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/shift_cash_summary.dart';
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
  Future<ShiftCashSummary> cashSummary(ShiftRecord shift) async {
    final to = shift.closedAt ?? DateTime.now();
    var sales = 0;
    final foreign = <String, int>{};
    final shiftSales = await (_db.select(_db.sales)
          ..where((t) =>
              t.shiftId.equals(shift.id) &
              t.paymentMethod.equals('cash') &
              t.status.isIn(const ['completed', 'partiallyRefunded', 'refunded'])))
        .get();
    for (final s in shiftSales) {
      final tendered = s.amountTenderedMinorUnits;
      sales += tendered == null ? s.grandTotalMinorUnits : tendered - (s.changeGivenMinorUnits ?? 0);
    }

    final payments = await (_db.select(_db.debtPayments)
          ..where((t) =>
              t.paymentMethod.equals('cash') &
              t.receivedByUserId.equals(shift.cashierId) &
              t.paidAt.isBetweenValues(shift.openedAt, to)))
        .get();
    final debts = payments.fold<int>(0, (sum, p) => sum + p.amountMinorUnits);

    final cash = await (_db.select(_db.chartOfAccounts)
          ..where((t) => t.storeId.equals(shift.storeId) & t.code.equals('1000')))
        .getSingleOrNull();
    Future<int> cashOut(String referenceType, Expression<bool> Function($JournalEntriesTable t) also) async {
      if (cash == null) return 0;
      final query = _db.select(_db.journalLines).join([
        innerJoin(_db.journalEntries, _db.journalEntries.id.equalsExp(_db.journalLines.journalEntryId)),
      ])
        ..where(_db.journalLines.accountId.equals(cash.id) &
            _db.journalEntries.referenceType.equals(referenceType) &
            _db.journalEntries.isReversal.equals(false) &
            _db.journalEntries.branchId.equals(shift.branchId) &
            also(_db.journalEntries));
      final rows = await query.get();
      return rows.fold<int>(0, (sum, r) {
        final line = r.readTable(_db.journalLines);
        return sum + line.creditMinorUnits - line.debitMinorUnits;
      });
    }

    final reversed = (await (_db.select(_db.journalEntries)..where((t) => t.reversalOfEntryId.isNotNull())).get())
        .map((e) => e.reversalOfEntryId!)
        .toSet();
    final expenses = await cashOut(
      'EXPENSE',
      (t) =>
          t.createdByUserId.equals(shift.cashierId) &
          t.entryDate.isBetweenValues(shift.openedAt, to) &
          t.id.isNotIn(reversed),
    );
    final refunds = await cashOut(
      'RETURN',
      (t) => t.createdByUserId.equals(shift.cashierId) & t.entryDate.isBetweenValues(shift.openedAt, to),
    );

    return ShiftCashSummary(
      openingMinorUnits: shift.openingCashFloatMinorUnits,
      cashSalesMinorUnits: sales,
      debtPaymentsMinorUnits: debts,
      refundsMinorUnits: refunds,
      expensesMinorUnits: expenses,
      foreign: foreign,
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
