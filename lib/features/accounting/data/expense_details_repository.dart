import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/sync_service.dart';
import '../domain/expense_categories.dart';

class DriftExpenseDetailsRepository implements ExpenseDetailsRepository {
  DriftExpenseDetailsRepository(this._db);
  final AppDatabase _db;

  @override
  Future<void> save(ExpenseDetailRecord d) async {
    await _db.into(_db.expenseDetails).insertOnConflictUpdate(ExpenseDetailsCompanion.insert(
          journalEntryId: d.journalEntryId,
          storeId: d.storeId,
          expenseGroup: d.group.name,
          category: d.category,
          amountMinorUnits: d.amountMinorUnits,
          entryDate: d.entryDate,
        ));
  }

  @override
  Future<void> updateType(String journalEntryId, ExpenseGroup group, String category) async {
    await (_db.update(_db.expenseDetails)..where((t) => t.journalEntryId.equals(journalEntryId)))
        .write(ExpenseDetailsCompanion(expenseGroup: Value(group.name), category: Value(category)));
  }

  @override
  Stream<List<ExpenseDetailRecord>> watch(String storeId, {required DateTime from}) {
    return (_db.select(_db.expenseDetails)
          ..where((t) => t.storeId.equals(storeId) & t.entryDate.isBiggerOrEqualValue(from)))
        .watch()
        .map((rows) => [
              for (final r in rows)
                ExpenseDetailRecord(
                  journalEntryId: r.journalEntryId,
                  storeId: r.storeId,
                  group: ExpenseGroup.values
                      .firstWhere((g) => g.name == r.expenseGroup, orElse: () => ExpenseGroup.custom),
                  category: r.category,
                  amountMinorUnits: r.amountMinorUnits,
                  entryDate: r.entryDate,
                ),
            ]);
  }
}

class SupabaseExpenseDetailsRepository implements ExpenseDetailsRepository {
  SupabaseExpenseDetailsRepository(this._client, this._writer);
  final SupabaseClient _client;
  final OfflineWriter _writer;

  ExpenseDetailRecord _map(Map<String, dynamic> r) => ExpenseDetailRecord(
        journalEntryId: r['journal_entry_id'] as String,
        storeId: r['store_id'] as String,
        group: ExpenseGroup.values.firstWhere((g) => g.name == r['expense_group'], orElse: () => ExpenseGroup.custom),
        category: r['category'] as String,
        amountMinorUnits: (r['amount_minor_units'] as num).toInt(),
        entryDate: DateTime.parse(r['entry_date'] as String).toLocal(),
      );

  @override
  Future<void> save(ExpenseDetailRecord d) async {
    await _writer.insert(
      'expense_details',
      {
        'journal_entry_id': d.journalEntryId,
        'store_id': d.storeId,
        'expense_group': d.group.name,
        'category': d.category,
        'amount_minor_units': d.amountMinorUnits,
        'entry_date': d.entryDate.toUtc().toIso8601String(),
      },
      key: 'journal_entry_id',
    );
  }

  @override
  Future<void> updateType(String journalEntryId, ExpenseGroup group, String category) async {
    await _writer.update(
      'expense_details',
      {'expense_group': group.name, 'category': category},
      column: 'journal_entry_id',
      value: journalEntryId,
    );
  }

  @override
  Stream<List<ExpenseDetailRecord>> watch(String storeId, {required DateTime from}) {
    return resilientRows(
      'expense_details.$storeId',
      () => _client.from('expense_details').stream(primaryKey: ['journal_entry_id']).eq('store_id', storeId),
      table: 'expense_details',
      where: (r) => r['store_id'] == storeId,
    ).map((rows) => rows.map(_map).where((d) => !d.entryDate.isBefore(from)).toList());
  }
}
