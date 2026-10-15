import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unopos/core/offline/connectivity.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/core/offline/sync_service.dart';
import 'package:unopos/features/debts/data/debts_repository_supabase.dart';

/// A stand-in for the backend: records what it is sent and answers like
/// PostgREST. [refuse] makes a path answer with a server refusal,
/// [noRows] makes updates of a table find nothing, [results] gives a
/// function's result and [delay] slows every answer.
class _FakeServer {
  late HttpServer _server;
  final requests = <(String, Object?)>[];
  final queries = <String>[];
  final refuse = <String>{};
  final noRows = <String>{};
  final results = <String, Object?>{};
  var delay = Duration.zero;
  var _nextId = 0;

  String get url => 'http://${_server.address.host}:${_server.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((req) async {
      final body = await utf8.decodeStream(req);
      final json = body.isEmpty ? null : jsonDecode(body);
      final path = req.uri.path.replaceFirst('/rest/v1/', '');
      requests.add((path, json));
      queries.add(Uri.decodeComponent(req.uri.query));
      await Future<void>.delayed(delay);
      req.response.headers.contentType = ContentType.json;
      if (refuse.contains(path) || (json is Map && refuse.contains('$path:${json['p_rpc']}'))) {
        req.response.statusCode = 400;
        req.response.write(jsonEncode({'code': 'P0001', 'message': 'refused', 'details': null, 'hint': null}));
      } else if (path == 'rpc/run_client_op') {
        final params = (json as Map)['p_params'] as Map;
        final rpc = json['p_rpc'];
        req.response.write(jsonEncode({
          'result': results.containsKey(rpc) ? results[rpc] : {'id': 'server-${_nextId++}', 'echo': params},
        }));
      } else if (req.method == 'PATCH' && noRows.contains(path)) {
        req.response.write('[]');
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
    await outbox.load();
    await outbox.setStore('s');
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

  test('a debt payment made offline keeps its journal entry link when the server gives it its own id', () async {
    server.results['record_debt_payment'] = 'pay-server';
    connectivity.markOffline();
    final debts = SupabaseDebtsRepository(client, writer);
    final paymentId = await debts.recordPayment(
      debtLedgerEntryId: 'd1',
      amountMinorUnits: 500,
      paymentMethod: 'cash',
      receivedByUserId: 'u',
    );
    expect(paymentId, Outbox.ref(outbox.ops.single.id, '.'));
    // Shown at once, linked to its entry.
    final je = await writer.rpc('post_journal_entry', {'p_reference_id': paymentId}, offline: () => null, opId: 'je');
    expect(je, isNull);
    await debts.attachJournalEntryToPayment(paymentId, Outbox.ref('je'));
    expect(outbox.applyTo('debt_payments', const []).single['journal_entry_id'], Outbox.ref('je'));

    connectivity.markOnline();
    await sync.syncNow();
    expect(outbox.ops, isEmpty);
    expect(((server.requests[1].$2 as Map)['p_params'] as Map)['p_reference_id'], 'pay-server');
    final (path, body) = server.requests.last;
    expect(path, 'debt_payments');
    expect((body as Map)['journal_entry_id'], 'server-0');
    expect(server.queries.last, contains('id=eq.pay-server'));
  });

  test("another store's changes wait until it signs in again", () async {
    connectivity.markOffline();
    await writer.insert('customers', {'store_id': 's', 'name': 'Ali'});
    await sync.setStore('other');
    await writer.insert('customers', {'store_id': 'other', 'name': 'Sara'});
    connectivity.markOnline();
    await sync.syncNow();
    expect(server.requests.map((r) => (r.$2 as Map)['name']), ['Sara']);
    expect(sync.state.otherStores, 1);

    await sync.setStore(null);
    connectivity.markOffline();
    await writer.insert('customers', {'store_id': 'x', 'name': 'Nobody'});
    connectivity.markOnline();
    await sync.syncNow();
    expect(server.requests, hasLength(1));

    await sync.setStore('s');
    await sync.syncNow();
    expect(server.requests.map((r) => (r.$2 as Map)['name']), ['Sara', 'Ali', 'Nobody']);
    expect(outbox.ops, isEmpty);
  });

  test('an update that finds no row is refused, not counted as saved', () async {
    server.noRows.add('customers');
    connectivity.markOffline();
    await writer.update('customers', {'name': 'X'}, value: 'missing');
    connectivity.markOnline();
    await sync.syncNow();
    expect(outbox.failed.single.lastError, contains('Nothing to change'));
    expect(server.queries.single, contains('select=id'));
    // Sent directly, the caller hears of it.
    expect(() => writer.update('customers', {'name': 'X'}, value: 'missing'), throwsA(isA<NothingToUpdateException>()));
  });

  test('changes building on a refused one wait with it; retry sends them, discard drops them', () async {
    server.refuse.add('customers');
    connectivity.markOffline();
    final customer = await writer.insert('customers', {'store_id': 's', 'name': 'Ali'});
    await writer.update('customers', {'name': 'Ali B'}, value: customer['id'] as String);
    await writer.insert('debts', {'store_id': 's', 'customer_id': customer['id']});
    await writer.insert('notes', {'store_id': 's', 'text': 'unrelated'});
    connectivity.markOnline();
    await sync.syncNow();

    expect(server.requests.map((r) => r.$1), ['customers', 'notes']);
    expect(sync.state.failed, 1);
    expect(sync.state.held, 2);
    // A new change to the refused customer waits too, even online.
    await writer.update('customers', {'phone': '1'}, value: customer['id'] as String);
    expect(server.requests, hasLength(2));
    expect(outbox.held, hasLength(3));

    server.refuse.clear();
    await sync.retryFailed();
    expect(server.requests.map((r) => r.$1), ['customers', 'notes', 'customers', 'customers', 'debts', 'customers']);
    expect(outbox.ops, isEmpty);

    server.refuse.add('customers');
    connectivity.markOffline();
    final other = await writer.insert('customers', {'store_id': 's', 'name': 'Sara'});
    await writer.update('customers', {'name': 'Sara B'}, value: other['id'] as String);
    connectivity.markOnline();
    await sync.syncNow();
    await sync.discard(outbox.failed.single.id);
    expect(outbox.ops, isEmpty);
    expect(sync.state.failed, 0);
  });

  test('changes made while sending are sent in the same run', () async {
    server.delay = const Duration(milliseconds: 150);
    connectivity.markOffline();
    await writer.insert('customers', {'store_id': 's', 'name': 'First'});
    connectivity.markOnline();
    final run = sync.syncNow();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await writer.insert('customers', {'store_id': 's', 'name': 'Second'});
    await run;
    expect(server.requests.map((r) => (r.$2 as Map)['name']), ['First', 'Second']);
    expect(outbox.ops, isEmpty);
  });

  test('busy, restarting or conflicting servers mean "try again later"', () {
    for (final code in [
      'PGRST000', 'PGRST001', 'PGRST002', 'PGRST003', '429', '520', '521', '522', '523', '524', //
      '40001', '40P01', '53300', '57P01', '503',
    ]) {
      expect(isTransientError(PostgrestException(message: 'x', code: code)), isTrue, reason: code);
    }
    for (final code in ['P0001', '23503', '42501', 'PGRST116', '400']) {
      expect(isTransientError(PostgrestException(message: 'x', code: code)), isFalse, reason: code);
    }
    expect(mayHaveRun(TimeoutException('slow')), isTrue);
    expect(mayHaveRun(const SocketException('Failed host lookup: x')), isFalse);
    expect(mayHaveRun(const PostgrestException(message: 'x', code: '503')), isFalse);
  });

  test('a function whose reply was lost is marked as possibly run', () async {
    server.delay = const Duration(seconds: 20);
    connectivity.markOffline();
    await writer.rpc('record_debt_payment', {'p_amount_minor_units': 5}, offline: () => 'local');
    connectivity.markOnline();
    await sync.syncNow();
    expect(outbox.pending.single.attemptedAt, isNotNull);
  }, timeout: const Timeout(Duration(seconds: 40)));
}
