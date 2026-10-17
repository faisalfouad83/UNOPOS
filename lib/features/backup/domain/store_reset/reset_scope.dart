import '../../../../core/offline/outbox.dart';

/// A part of the store's data that can be reset on its own (Settings →
/// Reset store data). The server function `reset_store_data` (migration
/// 0029) defines exactly what each removes; this mirrors it for the app's
/// side: what to back up first, which queued changes and saved copies to
/// drop afterwards.
///
/// Invoices and sales are the same records here, so [sales] covers both.
enum ResetScope {
  /// Sales/invoices (held ones too), their lines and returns, the debts
  /// they created, loyalty points earned or spent on them, and their
  /// journal entries. Stock quantities and stock history are kept.
  sales,

  /// Customer debts and payments, with the payments' journal entries.
  debts,

  /// Expenses with their journal entries.
  expenses,

  /// Every journal entry and line (expenses included); the chart of
  /// accounts is kept.
  accounting,

  /// Customers with their loyalty history and debts.
  customers,

  /// Products, stock, stock history, categories, product/category
  /// discounts, purchase orders and stock transfers.
  inventory,

  /// Suppliers, their transactions and purchase orders.
  suppliers,

  /// Closed shifts and finished breaks.
  shifts,

  /// Everything above, and every discount: the store as new.
  full;

  /// The name the server knows it by.
  String get wire => name;

  static ResetScope? fromWire(String value) {
    for (final s in values) {
      if (s.name == value) return s;
    }
    return null;
  }
}

/// What resetting a set of [ResetScope]s involves.
class ResetPlan {
  const ResetPlan._();

  /// The parts, without [ResetScope.full].
  static const parts = [
    ResetScope.sales,
    ResetScope.debts,
    ResetScope.expenses,
    ResetScope.accounting,
    ResetScope.customers,
    ResetScope.inventory,
    ResetScope.suppliers,
    ResetScope.shifts,
  ];

  /// Parts that can't be removed without another, and the one they bring:
  /// a debt needs its customer, a sale line its product, and expenses are
  /// journal entries.
  static const implied = {
    ResetScope.customers: ResetScope.debts,
    ResetScope.inventory: ResetScope.sales,
    ResetScope.accounting: ResetScope.expenses,
  };

  /// What [chosen] really covers (same rule as the server's
  /// `store_reset_scopes`): [ResetScope.full] is every part, and a part
  /// brings the one it can't do without ([implied]). In a fixed order.
  static List<ResetScope> expand(Iterable<ResetScope> chosen) {
    final set = chosen.toSet();
    if (set.contains(ResetScope.full)) return ResetScope.values.toList();
    for (final e in implied.entries) {
      if (set.contains(e.key)) set.add(e.value);
    }
    return ResetScope.values.where(set.contains).toList();
  }

  /// Every store table, in an order where a table follows the tables it
  /// refers to (as in a backup).
  static const tablesInOrder = [
    'branches',
    'categories',
    'tax_rates',
    'products',
    'users',
    'stock_items',
    'stock_movements',
    'suppliers',
    'supplier_transactions',
    'customers',
    'discounts',
    'chart_of_accounts',
    'journal_entries',
    'journal_lines',
    'expense_details',
    'sales',
    'sale_lines',
    'sale_returns',
    'sale_return_lines',
    'debt_ledger_entries',
    'debt_payments',
    'loyalty_transactions',
    'purchase_orders',
    'purchase_order_lines',
    'stock_transfers',
    'stock_transfer_lines',
    'shifts',
    'employee_breaks',
    'app_settings',
    'audit_logs',
  ];

  static const _journal = {'journal_entries', 'journal_lines'};

  /// Tables whose rows a part removes or changes (a link cleared, points
  /// taken back): what its backup holds.
  static const _tables = <ResetScope, Set<String>>{
    ResetScope.sales: {
      'sales',
      'sale_lines',
      'sale_returns',
      'sale_return_lines',
      'debt_ledger_entries',
      'debt_payments',
      'loyalty_transactions',
      'customers',
      ..._journal,
    },
    ResetScope.debts: {'debt_ledger_entries', 'debt_payments', ..._journal},
    ResetScope.expenses: {'expense_details', ..._journal},
    ResetScope.accounting: {
      'expense_details',
      ..._journal,
      // Their links to the removed entries are cleared.
      'sales',
      'sale_returns',
      'debt_ledger_entries',
      'debt_payments',
      'supplier_transactions',
    },
    ResetScope.customers: {'customers', 'loyalty_transactions', 'debt_ledger_entries', 'debt_payments', 'sales'},
    ResetScope.inventory: {
      'products',
      'stock_items',
      'stock_movements',
      'categories',
      'discounts',
      'purchase_orders',
      'purchase_order_lines',
      'stock_transfers',
      'stock_transfer_lines',
      'supplier_transactions',
      ..._journal,
    },
    ResetScope.suppliers: {
      'suppliers',
      'supplier_transactions',
      'purchase_orders',
      'purchase_order_lines',
      ..._journal
    },
    ResetScope.shifts: {'shifts', 'employee_breaks', 'sales'},
    ResetScope.full: {},
  };

  /// The tables a reset of [chosen] removes or changes rows of, in
  /// [tablesInOrder] order.
  static List<String> tablesOf(Iterable<ResetScope> chosen) {
    final scopes = expand(chosen);
    final wanted = {for (final s in scopes) ..._tables[s]!};
    if (scopes.contains(ResetScope.full)) wanted.add('discounts');
    return tablesInOrder.where(wanted.contains).toList();
  }

  static const _journalCaches = ['journal_entries.', 'journal_lines.', 'trial_balance.', 'reverse.'];

  /// The beginnings of the keys of the copies kept for offline use
  /// (`OfflineCache`) that may hold rows a part removes.
  static const _caches = <ResetScope, List<String>>{
    ResetScope.sales: [
      'sale.',
      'sales.',
      'sales_totals_by_customer.',
      'debt.',
      'debts.',
      'debt_payments.',
      'customers.',
      'shift_cash.',
      ..._journalCaches,
    ],
    ResetScope.debts: ['debt.', 'debts.', 'debt_payments.', ..._journalCaches],
    ResetScope.expenses: ['expense_details.', 'shift_cash.', ..._journalCaches],
    ResetScope.accounting: ['expense_details.', 'shift_cash.', ..._journalCaches],
    ResetScope.customers: [
      'customers.',
      'debt.',
      'debts.',
      'debt_payments.',
      'sales_totals_by_customer.',
      'sale.',
      'sales.',
    ],
    ResetScope.inventory: [
      'products.',
      'product.',
      'stock.',
      'stock_item.',
      'low_stock.',
      'categories.',
      'discounts.',
      'purchase_orders.',
      'stock_transfers.',
      'stock_transfer_lines.',
      ..._journalCaches,
    ],
    ResetScope.suppliers: [
      'suppliers.',
      'supplier_transactions.',
      'supplier_balance.',
      'purchase_orders.',
      ..._journalCaches,
    ],
    ResetScope.shifts: ['shifts.', 'open_shift.', 'shift_cash.', 'breaks.', 'break.', 'open_break.'],
    ResetScope.full: ['discounts.'],
  };

  /// Saved-copy key beginnings to drop after a reset of [chosen].
  static Set<String> cachePrefixesOf(Iterable<ResetScope> chosen) => {
        for (final s in expand(chosen)) ..._caches[s]!,
      };

  /// Which part each table belongs to, for queued changes.
  static const _tableScopes = <String, Set<ResetScope>>{
    'sales': {ResetScope.sales},
    'sale_lines': {ResetScope.sales},
    'sale_returns': {ResetScope.sales},
    'sale_return_lines': {ResetScope.sales},
    'loyalty_transactions': {ResetScope.sales, ResetScope.customers},
    'debt_ledger_entries': {ResetScope.debts},
    'debt_payments': {ResetScope.debts},
    'expense_details': {ResetScope.expenses},
    'journal_entries': {ResetScope.accounting},
    'journal_lines': {ResetScope.accounting},
    'customers': {ResetScope.customers},
    'products': {ResetScope.inventory},
    'stock_items': {ResetScope.inventory},
    'stock_movements': {ResetScope.inventory},
    'categories': {ResetScope.inventory},
    'discounts': {ResetScope.inventory},
    'stock_transfers': {ResetScope.inventory},
    'stock_transfer_lines': {ResetScope.inventory},
    'purchase_orders': {ResetScope.inventory, ResetScope.suppliers},
    'purchase_order_lines': {ResetScope.inventory, ResetScope.suppliers},
    'suppliers': {ResetScope.suppliers},
    'supplier_transactions': {ResetScope.suppliers},
    'shifts': {ResetScope.shifts},
    'employee_breaks': {ResetScope.shifts},
  };

  /// Which part each server function queued offline works on.
  static const _rpcScopes = <String, Set<ResetScope>>{
    'process_sale_return': {ResetScope.sales},
    'rehold_sale': {ResetScope.sales},
    'record_debt_payment': {ResetScope.debts},
    'reduce_debt_original_amount': {ResetScope.debts},
    'post_journal_entry': {ResetScope.accounting},
    'post_reversing_entry': {ResetScope.accounting},
    'receive_purchase_order': {ResetScope.inventory, ResetScope.suppliers},
    'receive_stock_transfer': {ResetScope.inventory},
    'record_stock_movement': {ResetScope.inventory},
    'start_break': {ResetScope.shifts},
    'end_break': {ResetScope.shifts},
  };

  /// A journal entry posted for one of these belongs to that part too.
  static const _journalReferenceScopes = <String, ResetScope>{
    'SALE': ResetScope.sales,
    'RETURN': ResetScope.sales,
    'DEBT_PAYMENT': ResetScope.debts,
    'EXPENSE': ResetScope.expenses,
    'PURCHASE': ResetScope.suppliers,
    'SUPPLIER_PAYMENT': ResetScope.suppliers,
  };

  /// The parts a queued change works on (empty: none of them, e.g. an
  /// employee or a setting).
  static Set<ResetScope> scopesOfOp(OutboxOp op) {
    switch (op.kind) {
      case OutboxKind.checkout:
        return {ResetScope.sales};
      case OutboxKind.insert || OutboxKind.update:
        return _tableScopes[op.table] ?? const {};
      case OutboxKind.rpc:
        final scopes = {...?_rpcScopes[op.rpc]};
        final reference = _journalReferenceScopes[op.params?['p_reference_type']];
        if (reference != null) scopes.add(reference);
        return scopes;
    }
  }

  /// Whether a reset of [chosen] removes what queued change [op] works on
  /// (it must then be dropped, not sent).
  static bool affectsOp(OutboxOp op, Iterable<ResetScope> chosen) {
    final scopes = expand(chosen).toSet();
    return scopesOfOp(op).any(scopes.contains);
  }
}
