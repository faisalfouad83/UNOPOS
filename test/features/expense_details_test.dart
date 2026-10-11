import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/accounting/data/expense_details_repository.dart';
import 'package:unopos/features/accounting/domain/expense_categories.dart';

void main() {
  test('every built-in category belongs to the right group', () {
    expect(ExpenseCategory.of(ExpenseGroup.fixed).length, 8);
    expect(ExpenseCategory.of(ExpenseGroup.variable).length, 5);
    expect(ExpenseCategory.of(ExpenseGroup.negligible).length, 5);
    expect(ExpenseCategory.of(ExpenseGroup.custom), isEmpty);
  });

  test('expense types are saved, re-typed later, and summed by group and category', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftExpenseDetailsRepository(db);
    ExpenseDetailRecord detail(String id, ExpenseGroup g, String c, int amount, DateTime at) =>
        ExpenseDetailRecord(journalEntryId: id, storeId: 's', group: g, category: c, amountMinorUnits: amount, entryDate: at);

    await repo.save(detail('1', ExpenseGroup.fixed, 'rent', 50000000, DateTime(2026, 10, 1)));
    await repo.save(detail('2', ExpenseGroup.variable, 'transport', 2000000, DateTime(2026, 10, 5)));
    await repo.save(detail('3', ExpenseGroup.custom, 'Camera repair', 3000000, DateTime(2026, 10, 6)));
    await repo.save(detail('old', ExpenseGroup.fixed, 'rent', 50000000, DateTime(2026, 9, 1)));

    await repo.updateType('2', ExpenseGroup.negligible, 'maintenance');

    final october = await repo.watch('s', from: DateTime(2026, 10)).first;
    final breakdown = ExpenseBreakdown(october);
    expect(breakdown.total, 55000000);
    expect(breakdown.byGroup, {
      ExpenseGroup.fixed: 50000000,
      ExpenseGroup.negligible: 2000000,
      ExpenseGroup.custom: 3000000,
    });
    expect(breakdown.byCategory[(ExpenseGroup.custom, 'Camera repair')], 3000000);
  });
}
