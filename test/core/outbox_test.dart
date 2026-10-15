import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/inventory/domain/stock_overlay.dart';

OutboxOp _insert(String id, String table, Map<String, dynamic> row) =>
    OutboxOp(id: id, kind: OutboxKind.insert, createdAt: DateTime(2026), table: table, row: row);

OutboxOp _update(String id, String table, Map<String, dynamic> patch, Object value) => OutboxOp(
      id: id,
      kind: OutboxKind.update,
      createdAt: DateTime(2026),
      table: table,
      row: patch,
      matchColumn: 'id',
      matchValue: value,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('changes survive a restart, in order', () async {
    final outbox = Outbox();
    await outbox.add(_insert('1', 'customers', {'id': 'c1', 'name': 'Ali'}));
    await outbox.add(
      OutboxOp(
          id: '2', kind: OutboxKind.rpc, createdAt: DateTime(2026), rpc: 'start_break', params: {'p_user_id': 'u'}),
    );

    final reloaded = Outbox();
    await reloaded.load();
    expect(reloaded.ops.map((o) => o.id), ['1', '2']);
    expect(reloaded.ops.last.params, {'p_user_id': 'u'});

    await reloaded.done('1');
    expect((await _reload()).ops.map((o) => o.id), ['2']);
  });

  test('sales queued by older versions are moved in', () async {
    SharedPreferences.setMockInitialValues({
      'offline_sale_queue.v1': jsonEncode([
        {
          'clientSaleId': 's1',
          'params': {'p_branch_id': 'b1'},
          'queuedAt': DateTime(2026).toIso8601String(),
        },
      ]),
    });
    final outbox = Outbox();
    await outbox.load();
    expect(outbox.pending.single.kind, OutboxKind.checkout);
    expect(outbox.pending.single.id, 's1');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('offline_sale_queue.v1'), isNull);
  });

  test('unsent changes show on top of the last server data', () async {
    final outbox = Outbox();
    await outbox.add(_insert('1', 'customers', {'id': 'c2', 'name': 'New', 'store_id': 's'}));
    await outbox.add(
      OutboxOp(
        id: '2',
        kind: OutboxKind.update,
        createdAt: DateTime(2026),
        table: 'customers',
        row: {'name': 'Renamed'},
        matchColumn: 'id',
        matchValue: 'c1',
      ),
    );
    final server = [
      {'id': 'c1', 'name': 'Old', 'store_id': 's'},
    ];
    final shown = outbox.applyTo('customers', server);
    expect(shown.map((r) => r['name']), ['New', 'Renamed']);
    // The server's own list isn't changed.
    expect(server.single['name'], 'Old');
    // Other tables are untouched; a filter keeps unrelated rows out.
    expect(outbox.applyTo('products', server), server);
    expect(outbox.applyTo('customers', server, where: (r) => r['store_id'] == 'other'), isEmpty);
  });

  test('once sent, an added row stays visible until the server copy arrives', () async {
    final outbox = Outbox();
    await outbox.add(_insert('1', 'customers', {'id': 'c2', 'name': 'New'}));
    await outbox.done('1');
    expect(outbox.applyTo('customers', const []).single['id'], 'c2');
    // ...and isn't doubled when it does.
    expect(
      outbox.applyTo('customers', [
        {'id': 'c2', 'name': 'New'},
      ]),
      hasLength(1),
    );
  });

  test('refused changes are kept apart and can be retried', () async {
    final outbox = Outbox();
    await outbox.add(_insert('1', 't', {'id': 'x'}));
    await outbox.replace(outbox.ops.single.copyWith(failed: true, lastError: 'no'));
    expect(outbox.hasPending, isFalse);
    expect(outbox.failed.single.lastError, 'no');
    await outbox.retryFailed();
    expect(outbox.hasPending, isTrue);
  });

  test('unsent sales and stock movements adjust the stock shown', () {
    final ops = [
      OutboxOp(
        id: 's1',
        kind: OutboxKind.checkout,
        createdAt: DateTime(2026),
        params: {
          'p_branch_id': 'b1',
          'p_lines': [
            {'product_id': 'tea', 'quantity': 2},
          ],
        },
      ),
      OutboxOp(
        id: 'm1',
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026),
        rpc: 'record_stock_movement',
        params: {'p_branch_id': 'b1', 'p_product_id': 'tea', 'p_type': 'purchaseIn', 'p_quantity': 10},
      ),
      OutboxOp(
        id: 'm2',
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026),
        rpc: 'record_stock_movement',
        params: {'p_branch_id': 'b2', 'p_product_id': 'tea', 'p_type': 'adjustmentOut', 'p_quantity': 1},
      ),
    ];
    expect(unsyncedStockOut(ops, 'b1'), {'tea': -8});
    expect(unsyncedStockOut(ops, 'b2'), {'tea': 1});
  });
  test('stock shown includes unsent changes, and products first stocked offline', () {
    final ops = [
      OutboxOp(
        id: 'm1',
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026),
        rpc: 'record_stock_movement',
        params: {'p_branch_id': 'b1', 'p_product_id': 'new', 'p_type': 'purchaseIn', 'p_quantity': 4},
      ),
      OutboxOp(
        id: 's1',
        kind: OutboxKind.checkout,
        createdAt: DateTime(2026),
        params: {
          'p_branch_id': 'b1',
          'p_lines': [
            {'product_id': 'tea', 'quantity': 3},
          ],
        },
      ),
    ];
    const items = [StockItemRecord(id: 'i1', storeId: 's', productId: 'tea', branchId: 'b1', quantityOnHand: 10)];
    final shown = {for (final i in withUnsyncedStock(items, ops, storeId: 's', branchId: 'b1')) i.productId: i};
    expect(shown['tea']!.quantityOnHand, 7);
    expect(shown['new']!.quantityOnHand, 4);
  });

  test('server results outlive the queue, then expire after a week unless still referred to', () async {
    final outbox = Outbox();
    await outbox.add(OutboxOp(id: 'je', kind: OutboxKind.rpc, createdAt: DateTime(2026), rpc: 'post_journal_entry'));
    outbox.recordResult('je', {'id': 'server-je'});
    await outbox.done('je');
    // The queue is empty, but a screen (or a later change) may still hold
    // the reference.
    expect((await _reload()).resolve(Outbox.ref('je')), 'server-je');

    // Saved by an earlier version without times: kept, counted from now.
    final weekAgo = DateTime.now().subtract(const Duration(days: 8)).toUtc().toIso8601String();
    SharedPreferences.setMockInitialValues({
      'outbox.v1': jsonEncode([
        _update('u', 'debt_payments', {'journal_entry_id': 'j'}, Outbox.ref('used', '.')).toJson(),
      ]),
      'outbox.v1.results': jsonEncode({'old': 'x', 'used': 'y'}),
      'outbox.v1.resultTimes': jsonEncode({'old': weekAgo, 'used': weekAgo}),
    });
    final aged = Outbox();
    await aged.load();
    expect(aged.resolve(Outbox.ref('old', '.')), Outbox.ref('old', '.'));
    expect(aged.resolve(Outbox.ref('used', '.')), 'y');

    SharedPreferences.setMockInitialValues({
      'outbox.v1': '[]',
      'outbox.v1.results': jsonEncode({'legacy': 'z'}),
    });
    expect((await _reload()).resolve(Outbox.ref('legacy', '.')), 'z');
  });

  test('an expense sent from the queue shows once when the server copy arrives', () async {
    final outbox = Outbox();
    await outbox.add(OutboxOp(id: 'je', kind: OutboxKind.rpc, createdAt: DateTime(2026), rpc: 'post_journal_entry'));
    await outbox.add(OutboxOp(
      id: 'ex',
      kind: OutboxKind.insert,
      createdAt: DateTime(2026),
      table: 'expense_details',
      row: {'journal_entry_id': Outbox.ref('je'), 'store_id': 's'},
      matchColumn: 'journal_entry_id',
    ));
    outbox.recordResult('je', {'id': 'server-je'});
    await outbox.done('je');
    outbox.recordResult('ex', null);
    await outbox.done('ex');
    final shown = outbox.applyTo('expense_details', [
      {'journal_entry_id': 'server-je', 'store_id': 's'},
    ]);
    expect(shown.single['journal_entry_id'], 'server-je');
  });

  test("changes wait for the store they were made under; older ones join the first store signed in", () async {
    SharedPreferences.setMockInitialValues({
      'outbox.v1': jsonEncode([
        _insert('legacy', 'customers', {'id': 'c0'}).toJson()
      ]),
    });
    final outbox = Outbox();
    await outbox.load();
    await outbox.setStore('A');
    expect(outbox.ops.single.storeId, 'A');
    await outbox.add(_insert('a1', 'customers', {'id': 'c1', 'store_id': 'A'}));
    expect(outbox.pending.map((o) => o.id), ['legacy', 'a1']);

    await outbox.setStore('B');
    expect(outbox.pending, isEmpty);
    expect(outbox.hasPending, isFalse);
    expect(outbox.otherStores, hasLength(2));
    expect(outbox.applyTo('customers', const []), isEmpty);
    await outbox.add(_insert('b1', 'customers', {'id': 'c2', 'store_id': 'B'}));
    expect(outbox.pending.single.id, 'b1');

    final reloaded = await _reload();
    await reloaded.setStore('A');
    expect(reloaded.pending.map((o) => o.id), ['legacy', 'a1']);
    expect(reloaded.otherStores.single.storeId, 'B');

    await outbox.setStore(null);
    expect(outbox.pending, isEmpty);
  });

  test('changes building on a refused one are held back with it, and go with it on retry', () async {
    final outbox = Outbox();
    await outbox.add(_insert('1', 'customers', {'id': 'c1', 'name': 'Ali'}));
    await outbox.add(_update('2', 'customers', {'name': 'Ali B'}, 'c1'));
    await outbox.add(_insert('3', 'debts', {'id': 'd1', 'customer_id': 'c1'}));
    await outbox.add(_update('4', 'debts', {'note': 'x'}, 'd1'));
    await outbox.add(_insert('5', 'customers', {'id': 'c2', 'name': 'Other'}));
    await outbox.add(OutboxOp(
      id: '6',
      kind: OutboxKind.rpc,
      createdAt: DateTime(2026),
      rpc: 'end_break',
      params: {'p_break_id': Outbox.ref('9')},
    ));
    await outbox.replace(outbox.ops.first.copyWith(failed: true, lastError: 'no'));

    expect(outbox.held.map((o) => o.id), ['2', '3', '4']);
    expect(outbox.pending.map((o) => o.id), ['5', '6']);
    expect(outbox.dependentsOf('1').map((o) => o.id), ['2', '3', '4']);
    // Neither shown: they build on something the server refused.
    expect(outbox.applyTo('debts', const []), isEmpty);
    // A new change to the refused row waits with it.
    expect(outbox.buildsOnRefused(_update('7', 'customers', {'name': 'x'}, 'c1')), isTrue);
    expect(outbox.buildsOnRefused(_update('8', 'customers', {'name': 'x'}, 'c2')), isFalse);

    await outbox.retryFailed();
    expect(outbox.held, isEmpty);
    expect(outbox.pending.map((o) => o.id), ['1', '2', '3', '4', '5', '6']);
  });

  test('a refused change can be discarded with the changes held back behind it', () async {
    final outbox = Outbox();
    await outbox.add(OutboxOp(id: 'pay', kind: OutboxKind.rpc, createdAt: DateTime(2026), rpc: 'record_debt_payment'));
    await outbox.add(OutboxOp(
      id: 'je',
      kind: OutboxKind.rpc,
      createdAt: DateTime(2026),
      rpc: 'post_journal_entry',
      params: {'p_reference_id': Outbox.ref('pay', '.')},
    ));
    await outbox.add(_update('link', 'debt_payments', {'journal_entry_id': Outbox.ref('je')}, Outbox.ref('pay', '.')));
    await outbox.add(_insert('other', 'customers', {'id': 'c1'}));
    // Not refused: can't be discarded.
    await outbox.discard('pay');
    expect(outbox.ops, hasLength(4));

    await outbox.replace(outbox.ops.first.copyWith(failed: true, lastError: 'payment is more than what is owed'));
    expect(outbox.held.map((o) => o.id), ['je', 'link']);
    await outbox.discard('pay');
    expect(outbox.ops.map((o) => o.id), ['other']);
    expect((await _reload()).ops.map((o) => o.id), ['other']);
  });

  test('received purchase orders, transfers and returns show on the stock until sent', () {
    final ops = [
      OutboxOp(
        id: 'po',
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026),
        rpc: 'receive_purchase_order',
        params: {'p_purchase_order_id': 'po1'},
        increments: [
          {
            'table': 'purchase_orders',
            'id': 'po1',
            'set': {'status': 'received'}
          },
          stockIncrement('tea', 'b1', 12),
        ],
      ),
      OutboxOp(
        id: 'tr',
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026),
        rpc: 'receive_stock_transfer',
        increments: [stockIncrement('tea', 'b1', -5), stockIncrement('tea', 'b2', 5)],
      ),
      OutboxOp(
        id: 'ret',
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026),
        rpc: 'process_sale_return',
        increments: [stockIncrement('cup', 'b1', 2)],
      ),
    ];
    expect(unsyncedStockOut(ops, 'b1'), {'tea': -7, 'cup': -2});
    expect(unsyncedStockOut(ops, 'b2'), {'tea': -5});
    // Stock entries don't touch other tables' rows.
    final outbox = Outbox();
    expect(
      outbox.applyTo('stock_items', [
        {'id': 'i1', 'product_id': 'tea', 'branch_id': 'b1', 'quantity_on_hand': 1},
      ]).single['quantity_on_hand'],
      1,
    );
  });

  test('a stock change just sent still counts until newer server figures arrive', () async {
    final outbox = Outbox(stockSettle: const Duration(milliseconds: 300));
    await outbox.add(OutboxOp(
      id: 'm1',
      kind: OutboxKind.rpc,
      createdAt: DateTime(2026),
      rpc: 'record_stock_movement',
      params: {'p_branch_id': 'b1', 'p_product_id': 'tea', 'p_type': 'saleOut', 'p_quantity': 2},
    ));
    final before = DateTime.now();
    expect(outbox.stockChanges(asOf: before).single.id, 'm1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await outbox.done('m1');
    // Figures from before the send: still counted.
    expect(outbox.stockChanges(asOf: before).single.id, 'm1');
    expect(outbox.stockChanges().single.id, 'm1');
    // Figures from after it: the server's include it.
    expect(outbox.stockChanges(asOf: DateTime.now().add(const Duration(milliseconds: 1))), isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(outbox.stockChanges(asOf: before), isEmpty);
  });

  test("a function whose reply was lost isn't shown twice once newer server rows arrive", () async {
    final outbox = Outbox();
    final attempted = DateTime.now();
    await outbox.add(OutboxOp(
      id: 'pay',
      kind: OutboxKind.rpc,
      createdAt: DateTime(2026),
      rpc: 'record_debt_payment',
      table: 'debt_payments',
      row: {'id': Outbox.ref('pay', '.'), 'amount_minor_units': 500},
      increments: [
        {'table': 'debt_ledger_entries', 'id': 'd1', 'column': 'amount_paid_minor_units', 'by': 500},
      ],
      attemptedAt: attempted,
    ));
    final debt = [
      {'id': 'd1', 'amount_paid_minor_units': 500},
    ];
    // Rows from before the send (or of unknown age): it is shown.
    expect(
        outbox.applyTo('debt_payments', const [], asOf: attempted.subtract(const Duration(seconds: 1))), hasLength(1));
    expect(outbox.applyTo('debt_ledger_entries', debt).single['amount_paid_minor_units'], 1000);
    // Rows fetched after it: they already include it if it ran.
    final later = attempted.add(const Duration(seconds: 1));
    expect(outbox.applyTo('debt_payments', const [], asOf: later), isEmpty);
    expect(outbox.applyTo('debt_ledger_entries', debt, asOf: later).single['amount_paid_minor_units'], 500);
  });
}

Future<Outbox> _reload() async {
  final o = Outbox();
  await o.load();
  return o;
}
