import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/store_reset/reset_scope.dart';
import '../domain/store_reset/store_reset_service.dart';

/// Resets the store's data in this device's own database (the
/// single-device build), with the same rules as the server's
/// `reset_store_data` (migration 0029), in one transaction. The local
/// database keeps no loyalty history, so points are left as they are.
///
/// The reset is recorded as an audit log row (`store.reset`, entity = the
/// reset id) in the same transaction: that row is how a reset interrupted
/// by the app closing is known to have happened or not.
class DriftStoreResetBackend implements StoreResetBackend {
  DriftStoreResetBackend(this._db, this._storeId);

  final AppDatabase _db;
  final String _storeId;

  /// Tables without a store column, read through the table they belong to.
  static const _parents = {
    'sale_lines': ('sales', 'sale_id'),
    'sale_return_lines': ('sale_returns', 'sale_return_id'),
    'debt_payments': ('debt_ledger_entries', 'debt_ledger_entry_id'),
    'stock_transfer_lines': ('stock_transfers', 'stock_transfer_id'),
    'purchase_order_lines': ('purchase_orders', 'purchase_order_id'),
  };

  @override
  bool get isServer => false;

  @override
  Future<Map<String, int>> preview(List<ResetScope> scopes) async {
    Map<String, int>? counts;
    try {
      await _db.transaction(() async {
        counts = await _apply(scopes);
        throw const _Undo();
      });
    } on _Undo {
      // Rolled back: nothing changed.
    }
    return counts ?? const {};
  }

  @override
  Future<List<Map<String, dynamic>>> rows(String table) async {
    final exists = await _db.customSelect("select 1 from sqlite_master where type = 'table' and name = ?",
        variables: [Variable(table)]).get();
    if (exists.isEmpty) return const [];
    final parent = _parents[table];
    final sql = parent == null
        ? 'select * from $table where store_id = ?'
        : 'select * from $table where ${parent.$2} in (select id from ${parent.$1} where store_id = ?)';
    final result = await _db.customSelect(sql, variables: [Variable(_storeId)]).get();
    return [for (final r in result) Map<String, dynamic>.of(r.data)];
  }

  @override
  Future<StoreResetResult> apply(String resetId, List<ResetScope> scopes, String actorId) async {
    final existing = await status(resetId);
    if (existing != null) return existing;
    final owner = await _db.customSelect(
      "select 1 from users where id = ? and store_id = ? and role = 'owner' and is_active = 1",
      variables: [Variable(actorId), Variable(_storeId)],
    ).get();
    if (owner.isEmpty) throw StateError('only the store owner can reset store data');
    final expanded = ResetPlan.expand(scopes);
    final result = await _db.transaction(() async {
      final counts = await _apply(expanded);
      final previous = await _db.customSelect(
        "select count(*) as n from audit_logs where store_id = ? and action = 'store.reset'",
        variables: [Variable(_storeId)],
      ).getSingle();
      final now = DateTime.now();
      final r = StoreResetResult(
        resetId: resetId,
        generation: (previous.data['n'] as int) + 1,
        scopes: expanded,
        counts: counts,
        createdAt: now,
      );
      await _db.into(_db.auditLogs).insert(
            AuditLogsCompanion.insert(
              id: IdGenerator.newId(),
              storeId: _storeId,
              userId: actorId,
              action: 'store.reset',
              entityType: 'store',
              entityId: Value(resetId),
              afterValueJson: Value(jsonEncode(_toJson(r))),
              timestamp: now,
            ),
          );
      return r;
    });
    // Every screen reading these tables refreshes.
    _db.markTablesUpdated(_db.allTables);
    return result;
  }

  @override
  Future<StoreResetResult?> status(String resetId) async {
    final rows = await _db.customSelect(
      "select after_value_json from audit_logs where store_id = ? and action = 'store.reset' and entity_id = ?",
      variables: [Variable(_storeId), Variable(resetId)],
    ).get();
    if (rows.isEmpty) return null;
    final json = rows.first.data['after_value_json'] as String?;
    if (json == null) return null;
    return StoreResetResult.fromJson((jsonDecode(json) as Map).cast<String, dynamic>());
  }

  @override
  Future<List<StoreResetResult>> resetsSince(int generation) async => const [];

  static Map<String, dynamic> _toJson(StoreResetResult r) => {
        'reset_id': r.resetId,
        'generation': r.generation,
        'scopes': [for (final s in r.scopes) s.wire],
        'counts': r.counts,
        'created_at': r.createdAt.toUtc().toIso8601String(),
      };

  /// Removes the rows of [scopes] (already expanded); rows removed per table.
  Future<Map<String, int>> _apply(List<ResetScope> scopes) async {
    bool has(ResetScope s) => scopes.contains(s);
    final sales = has(ResetScope.sales);
    final debts = has(ResetScope.debts);
    final expenses = has(ResetScope.expenses);
    final accounting = has(ResetScope.accounting);
    final customers = has(ResetScope.customers);
    final inventory = has(ResetScope.inventory);
    final suppliers = has(ResetScope.suppliers);
    final shifts = has(ResetScope.shifts);
    final full = has(ResetScope.full);
    final s = _storeId;
    final counts = <String, int>{};

    Future<int> run(String sql, [List<Object?> args = const []]) =>
        _db.customUpdate(sql, variables: [for (final a in args) Variable(a)]);
    Future<void> count(String table, String sql, [List<Object?> args = const []]) async {
      final n = await run(sql, args);
      counts[table] = (counts[table] ?? 0) + n;
    }

    // 1. The journal entries that belong to what is being removed.
    await _db.customStatement('drop table if exists temp._reset_je');
    await _db.customStatement('create temp table _reset_je (id text primary key)');
    Future<int> je(String select, [List<Object?> args = const []]) =>
        run('insert or ignore into _reset_je (id) select x from ($select) where x is not null', args);
    if (accounting) {
      await je('select id as x from journal_entries where store_id = ?', [s]);
    } else {
      if (sales) {
        await je(
            "select id as x from journal_entries where store_id = ? and reference_type in ('SALE', 'RETURN')", [s]);
        await je('select journal_entry_id as x from sales where store_id = ?', [s]);
        await je('select journal_entry_id as x from sale_returns where store_id = ?', [s]);
      }
      if (debts || sales) {
        final which = debts ? '' : ' and d.sale_id is not null';
        await je(
          'select p.journal_entry_id as x from debt_payments p join debt_ledger_entries d on d.id = p.debt_ledger_entry_id '
          'where d.store_id = ?$which',
          [s],
        );
        await je(
          'select j.id as x from journal_entries j join debt_payments p on p.id = j.reference_id '
          'join debt_ledger_entries d on d.id = p.debt_ledger_entry_id '
          "where j.store_id = ? and j.reference_type = 'DEBT_PAYMENT'$which",
          [s],
        );
      }
      if (debts) {
        await je("select id as x from journal_entries where store_id = ? and reference_type = 'DEBT_PAYMENT'", [s]);
        await je('select journal_entry_id as x from debt_ledger_entries where store_id = ? and sale_id is null', [s]);
      }
      if (expenses) {
        const own = "select id from journal_entries where store_id = ?1 and reference_type = 'EXPENSE' "
            'union select journal_entry_id from expense_details where store_id = ?1';
        await je('select id as x from ($own)', [s]);
        await je(
          "select id as x from journal_entries where store_id = ?1 and reference_type = 'ADJUSTMENT' "
          'and reference_id in ($own)',
          [s],
        );
      }
      if (suppliers || inventory) {
        await je(
          'select id as x from journal_entries where store_id = ?1 and reference_type = \'PURCHASE\' '
          'and reference_id in (select id from purchase_orders where store_id = ?1)',
          [s],
        );
      }
      if (suppliers) {
        await je(
          "select id as x from journal_entries where store_id = ? and reference_type in ('PURCHASE', 'SUPPLIER_PAYMENT')",
          [s],
        );
        await je('select journal_entry_id as x from supplier_transactions where store_id = ?', [s]);
      }
      if (inventory) {
        await je(
          "select id as x from journal_entries where store_id = ?1 and reference_type = 'ADJUSTMENT' "
          'and reference_id in (select id from stock_movements where store_id = ?1)',
          [s],
        );
      }
      // An entry goes with every entry reversing it.
      while (await je(
            'select id as x from journal_entries where store_id = ? '
            'and reversal_of_entry_id in (select id from _reset_je) and id not in (select id from _reset_je)',
            [s],
          ) >
          0) {}
    }

    // 2. Debts.
    if (debts) {
      await count(
          'debt_payments',
          'delete from debt_payments where debt_ledger_entry_id in (select id from debt_ledger_entries where store_id = ?)',
          [s]);
      await count('debt_ledger_entries', 'delete from debt_ledger_entries where store_id = ?', [s]);
    } else if (sales) {
      await count(
        'debt_payments',
        'delete from debt_payments where debt_ledger_entry_id in '
            '(select id from debt_ledger_entries where store_id = ? and sale_id is not null)',
        [s],
      );
      await count(
          'debt_ledger_entries', 'delete from debt_ledger_entries where store_id = ? and sale_id is not null', [s]);
    }

    // 3. Sales / invoices.
    if (sales) {
      await count(
          'sale_return_lines',
          'delete from sale_return_lines where sale_return_id in (select id from sale_returns where store_id = ?)',
          [s]);
      await count('sale_returns', 'delete from sale_returns where store_id = ?', [s]);
      await count(
          'sale_lines', 'delete from sale_lines where sale_id in (select id from sales where store_id = ?)', [s]);
      await count('sales', 'delete from sales where store_id = ?', [s]);
    }

    // 4. Customers.
    if (customers) {
      if (!sales) {
        await count('sales_unlinked_from_customers',
            'update sales set customer_id = null where store_id = ? and customer_id is not null', [s]);
      }
      await count('customers', 'delete from customers where store_id = ?', [s]);
    }

    // 5. Suppliers, purchase orders, stock transfers, products.
    if (suppliers) {
      await count('supplier_transactions', 'delete from supplier_transactions where store_id = ?', [s]);
    }
    if (suppliers || inventory) {
      await run(
        'update supplier_transactions set related_purchase_order_id = null where store_id = ?1 '
        'and related_purchase_order_id in (select id from purchase_orders where store_id = ?1)',
        [s],
      );
      await count(
          'purchase_order_lines',
          'delete from purchase_order_lines where purchase_order_id in (select id from purchase_orders where store_id = ?)',
          [s]);
      await count('purchase_orders', 'delete from purchase_orders where store_id = ?', [s]);
    }
    if (suppliers) {
      await count('suppliers', 'delete from suppliers where store_id = ?', [s]);
    }
    if (inventory) {
      await count(
          'stock_transfer_lines',
          'delete from stock_transfer_lines where stock_transfer_id in (select id from stock_transfers where store_id = ?)',
          [s]);
      await count('stock_transfers', 'delete from stock_transfers where store_id = ?', [s]);
      await count(
        'discounts',
        full
            ? 'delete from discounts where store_id = ?'
            : "delete from discounts where store_id = ? and applied_scope in ('product', 'category')",
        [s],
      );
      await count('stock_movements', 'delete from stock_movements where store_id = ?', [s]);
      await count('stock_items', 'delete from stock_items where store_id = ?', [s]);
      await count('products', 'delete from products where store_id = ?', [s]);
      await count('categories', 'delete from categories where store_id = ?', [s]);
    }

    // 6. Shifts and breaks (open ones are kept).
    if (shifts) {
      const closed = "select id from shifts where store_id = ?1 and status = 'closed'";
      await run('update sales set shift_id = null where store_id = ?1 and shift_id in ($closed)', [s]);
      await count('employee_breaks', 'delete from employee_breaks where store_id = ? and ended_at is not null', [s]);
      await run('update employee_breaks set shift_id = null where store_id = ?1 and shift_id in ($closed)', [s]);
      await count('shifts', "delete from shifts where store_id = ? and status = 'closed'", [s]);
    }

    // 7. The journal entries, whole; links to them are cleared.
    const gone = 'select id from _reset_je';
    for (final t in ['sales', 'sale_returns', 'debt_ledger_entries', 'supplier_transactions']) {
      await run('update $t set journal_entry_id = null where store_id = ? and journal_entry_id in ($gone)', [s]);
    }
    await run('update debt_payments set journal_entry_id = null where journal_entry_id in ($gone)');
    await run(
        'update journal_entries set reversal_of_entry_id = null where store_id = ? and reversal_of_entry_id in ($gone)',
        [s]);
    await count(
        'expense_details', 'delete from expense_details where store_id = ? and journal_entry_id in ($gone)', [s]);
    await count('journal_lines', 'delete from journal_lines where store_id = ? and journal_entry_id in ($gone)', [s]);
    await count('journal_entries', 'delete from journal_entries where store_id = ? and id in ($gone)', [s]);
    await _db.customStatement('drop table if exists temp._reset_je');

    counts.removeWhere((_, n) => n == 0);
    return counts;
  }
}

class _Undo implements Exception {
  const _Undo();
}
