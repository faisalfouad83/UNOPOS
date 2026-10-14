import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/inventory/domain/stock_overlay.dart';

OutboxOp _insert(String id, String table, Map<String, dynamic> row) =>
    OutboxOp(id: id, kind: OutboxKind.insert, createdAt: DateTime(2026), table: table, row: row);

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
}

Future<Outbox> _reload() async {
  final o = Outbox();
  await o.load();
  return o;
}
