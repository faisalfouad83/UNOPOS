import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unopos/core/offline/connectivity.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/core/offline/sync_service.dart';

/// A stand-in for the backend: records what it is sent and answers like
/// PostgREST. [refuse] makes a path answer with a server refusal.
class _FakeServer {
  late HttpServer _server;
  final requests = <(String, Object?)>[];
  final refuse = <String>{};
  var _nextId = 0;

  String get url => 'http://${_server.address.host}:${_server.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((req) async {
      final body = await utf8.decodeStream(req);
      final json = body.isEmpty ? null : jsonDecode(body);
      final path = req.uri.path.replaceFirst('/rest/v1/', '');
      requests.add((path, json));
      req.response.headers.contentType = ContentType.json;
      if (refuse.contains(path) || (json is Map && refuse.contains('$path:${json['p_rpc']}'))) {
        req.response.statusCode = 400;
        req.response.write(jsonEncode({'code': 'P0001', 'message': 'refused', 'details': null, 'hint': null}));
      } else if (path == 'rpc/run_client_op') {
        final params = (json as Map)['p_params'] as Map;
        req.response.write(jsonEncode({
          'result': {'id': 'server-${_nextId++}', 'echo': params},
        }));
      } else if (path.startsWith('rpc/')) {
        req.response.write(jsonEncode({'ok': true}));
      } else {
        // Insert/update: return the rows as written.
        req.response.write(jsonEncode(json is List ? json : [json]));
      }
      await req.response.close();
    });
  }

  Future<void> stop() => _server.close(force: true);
}

void main() {
  late _FakeServer server;
  late SupabaseClient client;
  late Outbox outbox;
  late ConnectivityMonitor connectivity;
  late OfflineWriter writer;
  late SyncService sync;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OfflineCache.resetMemory();
    server = _FakeServer();
    await server.start();
    client = SupabaseClient(server.url, 'anon-key');
    outbox = Outbox();
    connectivity = ConnectivityMonitor(null);
    writer = OfflineWriter(client, outbox, connectivity);
    sync = SyncService(outbox, client, connectivity, interval: const Duration(hours: 1));
  });

  tearDown(() async {
    sync.dispose();
    connectivity.dispose();
    await client.dispose();
    await server.stop();
  });

  test('offline, changes are kept in order and sent when the connection is back', () async {
    connectivity.markOffline();
    final shift = await writer.insert('shifts', {'store_id': 's', 'status': 'open'});
    await writer.checkout('sale-1', {'p_shift_id': shift['id']});
    await writer.update('shifts', {'status': 'closed'}, value: shift['id'] as String);

    expect(server.requests, isEmpty);
    expect(outbox.pending.map((o) => o.kind), [OutboxKind.insert, OutboxKind.checkout, OutboxKind.update]);
    // Shown straight away as made.
    expect(outbox.applyTo('shifts', const []).single['status'], 'closed');

    connectivity.markOnline();
    await sync.syncNow();

    expect(server.requests.map((r) => r.$1), ['shifts', 'rpc/checkout_sale_once', 'shifts']);
    expect(outbox.ops, isEmpty);
    expect(sync.state.pending, 0);
  });

  test('online with nothing waiting, a change is sent at once', () async {
    final row = await writer.insert('customers', {'store_id': 's', 'name': 'Ali'});
    expect(server.requests.single.$1, 'customers');
    expect(row['name'], 'Ali');
    expect(outbox.ops, isEmpty);
  });

  test('a change made while older ones wait goes after them, not before', () async {
    connectivity.markOffline();
    await writer.insert('customers', {'store_id': 's', 'name': 'First'});
    connectivity.markOnline();
    await writer.insert('customers', {'store_id': 's', 'name': 'Second'});
    expect(server.requests, isEmpty);
    await sync.syncNow();
    expect(server.requests.map((r) => (r.$2 as Map)['name']), ['First', 'Second']);
  });

  test('the connection dropping while sending keeps the change', () async {
    await server.stop();
    final row = await writer.insert('customers', {'store_id': 's', 'name': 'Ali'});
    expect(row['id'], isNotNull);
    expect(outbox.pending, hasLength(1));
    expect(connectivity.isOnline, isFalse);
  });

  test('a refusal is kept apart and does not hold up the rest', () async {
    connectivity.markOffline();
    await writer.rpc('record_stock_movement', {'p_quantity': 1}, offline: () => 0);
    await writer.insert('customers', {'store_id': 's', 'name': 'Ali'});
    server.refuse.add('rpc/run_client_op:record_stock_movement');
    connectivity.markOnline();
    await sync.syncNow();

    expect(outbox.failed.single.rpc, 'record_stock_movement');
    expect(outbox.failed.single.lastError, 'refused');
    expect(outbox.pending, isEmpty);
    expect(sync.state.failed, 1);

    server.refuse.clear();
    await sync.retryFailed();
    expect(outbox.ops, isEmpty);
  });

  test('a later change can use what the server returns for an earlier one', () async {
    connectivity.markOffline();
    final opId = 'op-1';
    await writer.rpc('post_journal_entry', {'p_memo': 'rent'}, offline: () => null, opId: opId);
    await writer.insert('expense_details', {'journal_entry_id': Outbox.ref(opId), 'store_id': 's'},
        key: 'journal_entry_id');
    connectivity.markOnline();
    await sync.syncNow();

    final sent = server.requests.last;
    expect(sent.$1, 'expense_details');
    expect((sent.$2 as Map)['journal_entry_id'], 'server-0');
  });

  test('server functions run through the exactly-once wrapper', () async {
    final result = await writer.rpc('record_debt_payment', {'p_amount_minor_units': 5}, offline: () => 'local');
    final (path, body) = server.requests.single;
    expect(path, 'rpc/run_client_op');
    expect((body as Map)['p_rpc'], 'record_debt_payment');
    expect(body['p_op_id'], isNotEmpty);
    expect((result as Map)['id'], 'server-0');
  });

  test('a function that cannot wait says so when offline', () async {
    connectivity.markOffline();
    expect(() => writer.rpc('post_reversing_entry', const {}), throwsA(isA<NeedsConnectionException>()));
  });
}
