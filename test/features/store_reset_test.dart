import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/features/backup/data/store_reset_drift.dart';
import 'package:unopos/features/backup/domain/store_reset/reset_archive.dart';
import 'package:unopos/features/backup/domain/store_reset/reset_scope.dart';
import 'package:unopos/features/backup/domain/store_reset/store_reset_service.dart';

// ---------------------------------------------------------------------------
// Fakes

/// A server that keeps rows per table and records what it was asked.
class _FakeServer implements StoreResetBackend {
  final tables = <String, List<Map<String, dynamic>>>{
    'sales': [
      {'id': 's1', 'store_id': 'A', 'grand_total_minor_units': 1000},
      {'id': 's2', 'store_id': 'A', 'grand_total_minor_units': 2.5},
    ],
    'sale_lines': [
      {'id': 'l1', 'sale_id': 's1'},
    ],
    'customers': [
      {'id': 'c1', 'name': 'Ali – علي'},
    ],
  };
  final applied = <String, StoreResetResult>{};
  int applyCalls = 0;
  Object? applyError;
  final resets = <StoreResetResult>[];

  @override
  bool get isServer => true;

  @override
  Future<Map<String, int>> preview(List<ResetScope> scopes) async => {'sales': 2};

  @override
  Future<List<Map<String, dynamic>>> rows(String table) async => tables[table] ?? const [];

  @override
  Future<StoreResetResult> apply(String resetId, List<ResetScope> scopes, String actorId) async {
    applyCalls++;
    final error = applyError;
    if (error != null) throw error;
    return applied[resetId] ??= StoreResetResult(
      resetId: resetId,
      generation: applied.length + 1,
      scopes: scopes,
      counts: const {'sales': 2},
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<StoreResetResult?> status(String resetId) async => applied[resetId];

  @override
  Future<List<StoreResetResult>> resetsSince(int generation) async =>
      resets.where((r) => r.generation > generation).toList();
}

/// Saves into memory; can fail to write, or hand back other bytes.
class _MemorySink implements BackupSink {
  _MemorySink({this.failWrite = false, this.corrupt = false, this.cancel = false});

  final bool failWrite;
  final bool corrupt;
  final bool cancel;
  Uint8List? saved;

  @override
  Future<SavedBackup?> save(String fileName, Uint8List bytes) async {
    if (cancel) return null;
    if (failWrite) throw const FileSystemException('disk full');
    saved = bytes;
    return SavedBackup(location: '/backups/$fileName');
  }

  @override
  Future<Uint8List> readBack(SavedBackup saved) async {
    final bytes = Uint8List.fromList(this.saved!);
    if (corrupt) bytes[bytes.length ~/ 2] ^= 0x01;
    return bytes;
  }
}

OutboxOp _op(String id,
        {OutboxKind kind = OutboxKind.insert,
        String? table,
        Map<String, dynamic>? row,
        String? rpc,
        Map<String, dynamic>? params,
        DateTime? at,
        String store = 'A'}) =>
    OutboxOp(
      id: id,
      kind: kind,
      createdAt: at ?? DateTime(2026, 1, 1),
      table: table,
      row: row,
      rpc: rpc,
      params: params,
      storeId: store,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OfflineCache.resetMemory();
  });

  group('scope → table mapping', () {
    test('full covers every part; parts bring the ones they need', () {
      expect(ResetPlan.expand([ResetScope.full]), ResetScope.values);
      expect(ResetPlan.expand([ResetScope.customers]), [ResetScope.debts, ResetScope.customers]);
      expect(ResetPlan.expand([ResetScope.inventory]), [ResetScope.sales, ResetScope.inventory]);
      expect(ResetPlan.expand([ResetScope.accounting]), [ResetScope.expenses, ResetScope.accounting]);
      expect(ResetPlan.expand([ResetScope.shifts]), [ResetScope.shifts]);
    });

    test('each part backs up exactly the tables it removes or changes', () {
      expect(ResetPlan.tablesOf([ResetScope.sales]), [
        'customers',
        'journal_entries',
        'journal_lines',
        'sales',
        'sale_lines',
        'sale_returns',
        'sale_return_lines',
        'debt_ledger_entries',
        'debt_payments',
        'loyalty_transactions',
      ]);
      expect(ResetPlan.tablesOf([ResetScope.expenses]), ['journal_entries', 'journal_lines', 'expense_details']);
      expect(ResetPlan.tablesOf([ResetScope.shifts]), ['sales', 'shifts', 'employee_breaks']);
      final full = ResetPlan.tablesOf([ResetScope.full]);
      // Never: the store's people, branches, settings, accounts, audit log.
      for (final kept in ['users', 'branches', 'app_settings', 'chart_of_accounts', 'tax_rates', 'audit_logs']) {
        expect(full, isNot(contains(kept)));
      }
      expect(full, containsAll(['products', 'suppliers', 'discounts', 'employee_breaks', 'loyalty_transactions']));
    });

    test('queued changes are matched to the parts they work on', () {
      bool hit(OutboxOp op, ResetScope s) => ResetPlan.affectsOp(op, [s]);
      final sale = _op('1', kind: OutboxKind.checkout);
      final customer = _op('2', table: 'customers');
      final expense =
          _op('3', kind: OutboxKind.rpc, rpc: 'post_journal_entry', params: {'p_reference_type': 'EXPENSE'});
      final manual = _op('4', kind: OutboxKind.rpc, rpc: 'post_journal_entry', params: {'p_reference_type': 'MANUAL'});
      final setting = _op('5', kind: OutboxKind.update, table: 'app_settings');
      final receive = _op('6', kind: OutboxKind.rpc, rpc: 'receive_purchase_order');
      expect(hit(sale, ResetScope.sales), isTrue);
      expect(hit(sale, ResetScope.customers), isFalse);
      expect(hit(sale, ResetScope.inventory), isTrue); // inventory brings sales
      expect(hit(customer, ResetScope.customers), isTrue);
      expect(hit(customer, ResetScope.sales), isFalse);
      expect(hit(expense, ResetScope.expenses), isTrue);
      expect(hit(expense, ResetScope.accounting), isTrue);
      expect(hit(manual, ResetScope.expenses), isFalse);
      expect(hit(manual, ResetScope.accounting), isTrue);
      expect(hit(receive, ResetScope.suppliers), isTrue);
      expect(hit(setting, ResetScope.full), isFalse);
    });

    test('saved copies dropped per part', () {
      expect(ResetPlan.cachePrefixesOf([ResetScope.shifts]), containsAll(['shifts.', 'open_shift.', 'break.']));
      expect(ResetPlan.cachePrefixesOf([ResetScope.shifts]), isNot(contains('products.')));
      expect(ResetPlan.cachePrefixesOf([ResetScope.inventory]), containsAll(['products.', 'sales.', 'stock.']));
    });
  });

  group('backup file', () {
    ResetArchiveFile build() => ResetArchive.build(
          storeId: 'A',
          resetId: 'r1',
          scopes: const ['sales'],
          tables: {
            'sales': [
              {'id': 's1', 'total': 1000, 'rate': 1.5, 'note': 'علي'},
            ],
            'sale_lines': const [],
          },
          device: {
            'outbox': [_op('x').toJson()]
          },
          exportedAt: DateTime.utc(2026, 10, 17),
        );

    test('has a manifest with version, store, counts and hash, and checks out', () {
      final file = build();
      final doc = jsonDecode(utf8.decode(file.bytes)) as Map<String, dynamic>;
      final manifest = doc['manifest'] as Map<String, dynamic>;
      expect(manifest['format'], ResetArchive.format);
      expect(manifest['format_version'], 1);
      expect(manifest['schema_version'], '0029');
      expect(manifest['store_id'], 'A');
      expect(manifest['counts'], {'sales': 1, 'sale_lines': 0});
      expect(manifest['device_ops'], 1);
      expect(manifest['data_sha256'], file.sha256);
      expect(() => ResetArchive.verify(file.bytes, file, storeId: 'A'), returnsNormally);
    });

    test('a changed byte, another store or missing rows fail the check', () {
      final file = build();
      final text = utf8.decode(file.bytes);
      Uint8List bytes(String s) => Uint8List.fromList(utf8.encode(s));
      expect(() => ResetArchive.verify(bytes(text.replaceFirst('1000', '1001')), file, storeId: 'A'),
          throwsA(isA<ResetArchiveInvalid>()));
      expect(() => ResetArchive.verify(file.bytes, file, storeId: 'B'), throwsA(isA<ResetArchiveInvalid>()));
      expect(() => ResetArchive.verify(bytes(text.substring(0, text.length - 5)), file, storeId: 'A'),
          throwsA(isA<ResetArchiveInvalid>()));
    });
  });

  group('reset run', () {
    test('a backup that cannot be written stops the reset before anything changes', () async {
      final server = _FakeServer();
      final service = StoreResetService(backend: server, storeId: 'A', outbox: Outbox(), isOnline: () => true);
      final stages = <ResetStage>[];
      await expectLater(
        service
            .run(chosen: [ResetScope.sales], actorId: 'owner', sink: _MemorySink(failWrite: true), onStage: stages.add),
        throwsA(isA<StoreResetFailure>()
            .having((e) => e.stage, 'stage', ResetStage.backup)
            .having((e) => e.reason, 'reason', StoreResetFailureReason.backupFailed)),
      );
      expect(server.applyCalls, 0);
      expect(stages, [ResetStage.backup]);
      expect(await StoreResetService.hasPending(), isFalse);
    });

    test('a backup that reads back wrong stops the reset', () async {
      final server = _FakeServer();
      final service = StoreResetService(backend: server, storeId: 'A', outbox: Outbox(), isOnline: () => true);
      await expectLater(
        service.run(chosen: [ResetScope.sales], actorId: 'owner', sink: _MemorySink(corrupt: true)),
        throwsA(isA<StoreResetFailure>().having((e) => e.stage, 'stage', ResetStage.verify)),
      );
      expect(server.applyCalls, 0);
    });

    test('closing the save dialog cancels; offline nothing starts', () async {
      final server = _FakeServer();
      await expectLater(
        StoreResetService(backend: server, storeId: 'A', outbox: Outbox(), isOnline: () => true)
            .run(chosen: [ResetScope.sales], actorId: 'owner', sink: _MemorySink(cancel: true)),
        throwsA(isA<StoreResetCancelled>()),
      );
      final sink = _MemorySink();
      await expectLater(
        StoreResetService(backend: server, storeId: 'A', outbox: Outbox(), isOnline: () => false)
            .run(chosen: [ResetScope.sales], actorId: 'owner', sink: sink),
        throwsA(isA<StoreResetFailure>().having((e) => e.reason, 'reason', StoreResetFailureReason.offline)),
      );
      expect(sink.saved, isNull);
      expect(server.applyCalls, 0);
    });

    test('changes that could not be sent block the reset', () async {
      final server = _FakeServer();
      final outbox = Outbox();
      await outbox.setStore('A');
      await outbox.add(_op('c', table: 'customers', row: {'id': 'c9'}));
      final service = StoreResetService(backend: server, storeId: 'A', outbox: outbox, isOnline: () => true);
      await expectLater(
        service.run(chosen: [ResetScope.shifts], actorId: 'owner', sink: _MemorySink()),
        throwsA(isA<StoreResetFailure>().having((e) => e.reason, 'reason', StoreResetFailureReason.unsentChanges)),
      );
      expect(server.applyCalls, 0);
    });

    test('a full run backs up (with this device\'s queue), resets, and drops queued work for the erased parts',
        () async {
      final server = _FakeServer();
      final outbox = Outbox();
      await outbox.setStore('A');
      // Refused changes: they don't block (nothing waits to be sent) but
      // are dropped when their part is reset.
      await outbox.add(_op('sale', kind: OutboxKind.checkout, params: {'p_client_sale_id': 'x'}));
      await outbox.replace(outbox.ops.last.copyWith(failed: true));
      await outbox.add(_op('emp', kind: OutboxKind.update, table: 'users'));
      await outbox.replace(outbox.ops.last.copyWith(failed: true));
      await outbox.add(_op('other-store', kind: OutboxKind.checkout, store: 'B'));
      final sink = _MemorySink();
      final service = StoreResetService(backend: server, storeId: 'A', outbox: outbox, isOnline: () => true);
      final stages = <ResetStage>[];
      final outcome = await service.run(chosen: [ResetScope.sales], actorId: 'owner', sink: sink, onStage: stages.add);

      expect(stages, ResetStage.values);
      expect(server.applyCalls, 1);
      expect(outcome.result.counts, {'sales': 2});
      expect(outcome.backup!.location, startsWith('/backups/unopos_reset_backup_'));
      expect(outcome.backupCounts['sales'], 2);
      expect(outcome.droppedChanges, 1);
      expect(outbox.ops.map((o) => o.id), ['emp', 'other-store']);
      final doc = jsonDecode(utf8.decode(sink.saved!)) as Map<String, dynamic>;
      expect(((doc['data'] as Map)['device'] as Map)['outbox'], hasLength(2)); // this store's only
      expect(await StoreResetService.hasPending(), isFalse);
    });
  });

  group('resuming', () {
    test('a reset whose reply was lost is finished on the next start, once', () async {
      final server = _FakeServer()..applyError = const SocketException('Connection reset');
      final outbox = Outbox();
      await outbox.setStore('A');
      await outbox.add(_op('old-sale', kind: OutboxKind.checkout));
      await outbox.replace(outbox.ops.last.copyWith(failed: true));
      final service = StoreResetService(backend: server, storeId: 'A', outbox: outbox, isOnline: () => true);
      await expectLater(
        service.run(chosen: [ResetScope.sales], actorId: 'owner', sink: _MemorySink()),
        throwsA(isA<StoreResetFailure>().having((e) => e.reason, 'reason', StoreResetFailureReason.unknown)),
      );
      expect(await StoreResetService.hasPending(), isTrue);

      // It did run on the server.
      final raw = (await SharedPreferences.getInstance()).getString('store_reset.pending.v1')!;
      final id = (jsonDecode(raw) as Map)['reset_id'] as String;
      server.applied[id] = StoreResetResult(
          resetId: id, generation: 1, scopes: const [ResetScope.sales], counts: const {}, createdAt: DateTime.now());

      // Offline: wait.
      final offline = StoreResetService(backend: server, storeId: 'A', outbox: outbox, isOnline: () => false);
      expect(await offline.resumePending(), isNull);
      expect(await StoreResetService.hasPending(), isTrue);

      final resumed = await service.resumePending();
      expect(resumed?.resetId, id);
      expect(outbox.ops, isEmpty);
      expect(await StoreResetService.hasPending(), isFalse);
      expect(await service.resumePending(), isNull);
      expect(server.applyCalls, 1); // never sent again
    });

    test('a reset that never reached the server is forgotten', () async {
      final server = _FakeServer()..applyError = _UnreachableError();
      final service = StoreResetService(backend: server, storeId: 'A', outbox: Outbox(), isOnline: () => true);
      await expectLater(service.run(chosen: [ResetScope.shifts], actorId: 'owner', sink: _MemorySink()),
          throwsA(isA<StoreResetFailure>()));
      expect(await StoreResetService.hasPending(), isTrue);
      expect(await service.resumePending(), isNull);
      expect(await StoreResetService.hasPending(), isFalse);
    });

    test('resets made on another device drop older queued work for their parts only', () async {
      final server = _FakeServer();
      final at = DateTime(2026, 5, 1);
      server.resets.add(StoreResetResult(
          resetId: 'r',
          generation: 3,
          scopes: const [ResetScope.customers, ResetScope.debts],
          counts: const {},
          createdAt: at));
      final outbox = Outbox();
      await outbox.setStore('A');
      await outbox.add(_op('before', table: 'customers', at: DateTime(2026, 4, 30)));
      await outbox.add(_op('after', table: 'customers', at: DateTime(2026, 5, 2)));
      await outbox.add(_op('product', table: 'products', at: DateTime(2026, 4, 30)));
      final service = StoreResetService(backend: server, storeId: 'A', outbox: outbox, isOnline: () => true);
      expect(await service.reconcile(), 1);
      expect(outbox.ops.map((o) => o.id), ['after', 'product']);
      expect((await SharedPreferences.getInstance()).getInt('store_reset.generation.A'), 3);
      expect(await service.reconcile(), 0); // already seen
    });
  });

  group('device clean-up helpers', () {
    test('Outbox.purge drops the picked changes and those building on them, for one store', () async {
      final outbox = Outbox();
      await outbox.setStore('A');
      await outbox.add(_op('c1', table: 'customers', row: {'id': 'cust-1', 'name': 'A'}));
      await outbox.add(OutboxOp(
          id: 'pay',
          kind: OutboxKind.rpc,
          createdAt: DateTime(2026),
          rpc: 'record_debt_payment',
          params: {'p_customer_id': 'cust-1'},
          storeId: 'A'));
      await outbox.add(_op('p1', table: 'products', row: {'id': 'prod-1'}));
      await outbox.add(_op('b-c', table: 'customers', row: {'id': 'cust-b'}, store: 'B'));
      final dropped = await outbox.purge((op) => op.table == 'customers', storeId: 'A');
      expect(dropped.map((o) => o.id), ['c1', 'pay']);
      expect(outbox.ops.map((o) => o.id), ['p1', 'b-c']);
      expect((await _reloaded()).ops.map((o) => o.id), ['p1', 'b-c']);
    });

    test('OfflineCache.removeByPrefixes drops matching copies only', () async {
      await OfflineCache.write('sales.completed.A', [
        {'id': 's'}
      ]);
      await OfflineCache.write('sale.s1', {'id': 's1'});
      await OfflineCache.write('products.A', [
        {'id': 'p'}
      ]);
      expect(await OfflineCache.removeByPrefixes(['sales.', 'sale.']), greaterThanOrEqualTo(2));
      OfflineCache.resetMemory();
      expect(await OfflineCache.read('sales.completed.A'), isNull);
      expect(await OfflineCache.read('sale.s1'), isNull);
      expect(await OfflineCache.read('products.A'), isNotNull);
    });
  });

  group('local (single-device) reset', () {
    late AppDatabase db;
    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await _seed(db, 'A');
      await _seed(db, 'B');
    });
    tearDown(() => db.close());

    Future<Map<String, int>> left(String store) async {
      Future<int> n(String sql) async =>
          (await db.customSelect(sql, variables: [Variable(store)]).getSingle()).data['n'] as int;
      return {
        'sales': await n('select count(*) n from sales where store_id = ?'),
        'sale_lines':
            await n('select count(*) n from sale_lines where sale_id in (select id from sales where store_id = ?)'),
        'debts': await n('select count(*) n from debt_ledger_entries where store_id = ?'),
        'je': await n('select count(*) n from journal_entries where store_id = ?'),
        'expenses': await n('select count(*) n from expense_details where store_id = ?'),
        'customers': await n('select count(*) n from customers where store_id = ?'),
        'products': await n('select count(*) n from products where store_id = ?'),
        'stock': await n('select coalesce(sum(quantity_on_hand), 0) n from stock_items where store_id = ?'),
        'moves': await n('select count(*) n from stock_movements where store_id = ?'),
        'suppliers': await n('select count(*) n from suppliers where store_id = ?'),
        'po': await n('select count(*) n from purchase_orders where store_id = ?'),
        'shifts': await n('select count(*) n from shifts where store_id = ?'),
        'breaks': await n('select count(*) n from employee_breaks where store_id = ?'),
        'discounts': await n('select count(*) n from discounts where store_id = ?'),
        'users': await n('select count(*) n from users where store_id = ?'),
        'accounts': await n('select count(*) n from chart_of_accounts where store_id = ?'),
        'unbalanced': await n('select count(*) n from (select journal_entry_id from journal_lines where store_id = ? '
            'group by journal_entry_id having sum(debit_minor_units) <> sum(credit_minor_units))'),
        'orphan_lines': await n('select count(*) n from journal_lines l where store_id = ? '
            'and not exists (select 1 from journal_entries j where j.id = l.journal_entry_id)'),
        'dangling_links':
            await n('select (select count(*) from sales s where store_id = ?1 and journal_entry_id is not null '
                'and not exists (select 1 from journal_entries j where j.id = s.journal_entry_id)) + '
                '(select count(*) from sales s where store_id = ?1 and customer_id is not null '
                'and not exists (select 1 from customers c where c.id = s.customer_id)) + '
                '(select count(*) from sales s where store_id = ?1 and shift_id is not null '
                'and not exists (select 1 from shifts h where h.id = s.shift_id)) + '
                '(select count(*) from debt_ledger_entries d where store_id = ?1 '
                'and not exists (select 1 from customers c where c.id = d.customer_id)) n'),
      };
    }

    const before = {
      'sales': 3,
      'sale_lines': 3,
      'debts': 1,
      'je': 11,
      'expenses': 1,
      'customers': 2,
      'products': 2,
      'stock': 12,
      'moves': 5,
      'suppliers': 1,
      'po': 1,
      'shifts': 2,
      'breaks': 2,
      'discounts': 2,
      'users': 2,
      'accounts': 6,
      'unbalanced': 0,
      'orphan_lines': 0,
      'dangling_links': 0,
    };

    Future<Map<String, int>> reset(List<ResetScope> scopes) async {
      final backend = DriftStoreResetBackend(db, 'A');
      final preview = await backend.preview(ResetPlan.expand(scopes));
      expect(await left('A'), before, reason: 'a preview changes nothing');
      final result = await backend.apply('reset-${scopes.map((s) => s.name).join()}', scopes, 'A-owner');
      expect(result.counts, preview, reason: 'the preview counts what the reset does');
      expect(await left('B'), before, reason: 'other stores are untouched');
      final after = await left('A');
      expect(after['unbalanced'], 0);
      expect(after['orphan_lines'], 0);
      expect(after['dangling_links'], 0);
      expect(after['users'], 2);
      expect(after['accounts'], 6);
      return after;
    }

    Map<String, int> only(Map<String, int> changes) => {...before, ...changes};

    test('sales: invoices, their debts and entries go; stock stays', () async {
      expect(await reset([ResetScope.sales]), only({'sales': 0, 'sale_lines': 0, 'debts': 0, 'je': 6}));
    });
    test('debts: debts and payment entries go', () async {
      expect(await reset([ResetScope.debts]), only({'debts': 0, 'je': 10}));
    });
    test('expenses: expense and its reclassification entry go', () async {
      expect(await reset([ResetScope.expenses]), only({'expenses': 0, 'je': 9}));
    });
    test('accounting: every entry goes, expenses with them', () async {
      expect(await reset([ResetScope.accounting]), only({'expenses': 0, 'je': 0}));
    });
    test('customers: customers and their debts go; invoices stay unlinked', () async {
      expect(await reset([ResetScope.customers]), only({'customers': 0, 'debts': 0, 'je': 10}));
    });
    test('inventory: products, stock, purchase orders and the invoices go', () async {
      expect(
        await reset([ResetScope.inventory]),
        only({
          'sales': 0,
          'sale_lines': 0,
          'debts': 0,
          'je': 4,
          'products': 0,
          'stock': 0,
          'moves': 0,
          'po': 0,
          'discounts': 1,
        }),
      );
    });
    test('suppliers: suppliers, purchases and payments go', () async {
      expect(await reset([ResetScope.suppliers]), only({'suppliers': 0, 'po': 0, 'je': 9}));
    });
    test('shifts: closed shifts and finished breaks go; open ones stay', () async {
      expect(await reset([ResetScope.shifts]), only({'shifts': 1, 'breaks': 1}));
    });
    test('full: every business record goes; people, accounts and open shift stay', () async {
      expect(
        await reset([ResetScope.full]),
        only({
          'sales': 0,
          'sale_lines': 0,
          'debts': 0,
          'je': 0,
          'expenses': 0,
          'customers': 0,
          'products': 0,
          'stock': 0,
          'moves': 0,
          'suppliers': 0,
          'po': 0,
          'shifts': 1,
          'breaks': 1,
          'discounts': 0,
        }),
      );
    });

    test('the same reset id runs once; only the owner may run it', () async {
      final backend = DriftStoreResetBackend(db, 'A');
      await expectLater(backend.apply('r', [ResetScope.customers], 'A-cash'), throwsA(isA<StateError>()));
      final first = await backend.apply('r', [ResetScope.customers], 'A-owner');
      await _insert(
          db, 'customers', {'id': 'A-new', 'store_id': 'A', 'name': 'New', 'created_at': 0, 'loyalty_points': 0});
      final again = await backend.apply('r', [ResetScope.customers], 'A-owner');
      expect(again.generation, first.generation);
      expect((await left('A'))['customers'], 1, reason: 'the repeat removed nothing');
      expect((await backend.status('r'))?.resetId, 'r');
      final second = await backend.apply('r2', [ResetScope.customers], 'A-owner');
      expect(second.generation, first.generation + 1);
    });

    test('a local run backs up from the device database and resets it', () async {
      final service = StoreResetService(backend: DriftStoreResetBackend(db, 'A'), storeId: 'A');
      final sink = _MemorySink();
      final outcome = await service.run(chosen: [ResetScope.shifts], actorId: 'A-owner', sink: sink);
      expect(outcome.backupCounts, {'sales': 3, 'shifts': 2, 'employee_breaks': 2});
      expect(outcome.result.counts, {'shifts': 1, 'employee_breaks': 1});
      expect((await left('A'))['shifts'], 1);
    });
  });
}

class _UnreachableError implements Exception {
  @override
  String toString() => 'SocketException: Failed host lookup';
}

Future<Outbox> _reloaded() async {
  final o = Outbox();
  await o.load();
  return o;
}

Future<void> _insert(AppDatabase db, String table, Map<String, Object?> row) => db.customStatement(
      'insert into $table (${row.keys.join(', ')}) values (${List.filled(row.length, '?').join(', ')})',
      row.values.toList(),
    );

/// One store's worth of every kind of record (the same set as the server
/// test data used for migration 0029).
Future<void> _seed(AppDatabase db, String s) async {
  Future<void> ins(String t, Map<String, Object?> r) => _insert(db, t, r);
  await ins('stores', {
    'id': s,
    'store_login_id': s,
    'password_hash': 'x',
    'display_name': s,
    'created_at': 0,
    'is_active': 1,
  });
  await ins('branches', {
    'id': '$s-b1',
    'store_id': s,
    'name': 'Main',
    'address': '',
    'phone': '',
    'is_main_branch': 1,
    'is_active': 1,
    'created_at': 0,
  });
  for (final (id, role) in [('$s-owner', 'owner'), ('$s-cash', 'cashier')]) {
    await ins('users', {
      'id': id,
      'store_id': s,
      'name': id,
      'role': role,
      'pin_hash': 'x',
      'phone': '',
      'address': '',
      'salary_minor_units': 0,
      'allowances_minor_units': 0,
      'avatar_color_hex': '#000000',
      'is_active': 1,
      'created_at': 0,
    });
  }
  for (final (id, code) in [
    ('cash', '1000'),
    ('ar', '1100'),
    ('rev', '4000'),
    ('exp', '6000'),
    ('ap', '2000'),
    ('inv', '1200')
  ]) {
    await ins('chart_of_accounts', {
      'id': '$s-$id',
      'store_id': s,
      'code': code,
      'name': id,
      'type': 'asset',
      'is_system_account': 1,
      'is_active': 1,
    });
  }
  await ins('categories', {'id': '$s-cat', 'store_id': s, 'name': 'Cat'});
  for (final p in ['p1', 'p2']) {
    await ins('products', {
      'id': '$s-$p',
      'store_id': s,
      'category_id': p == 'p1' ? '$s-cat' : null,
      'sku': p,
      'name': p,
      'unit': 'pc',
      'cost_price_minor_units': 100,
      'sell_price_minor_units': 200,
      'reorder_level': 0,
      'is_active': 1,
      'created_at': 0,
    });
  }
  await ins('stock_items', {
    'id': '$s-si1',
    'store_id': s,
    'product_id': '$s-p1',
    'branch_id': '$s-b1',
    'quantity_on_hand': 7,
    'reserved_quantity': 0,
  });
  await ins('stock_items', {
    'id': '$s-si2',
    'store_id': s,
    'product_id': '$s-p2',
    'branch_id': '$s-b1',
    'quantity_on_hand': 5,
    'reserved_quantity': 0,
  });
  for (final c in ['c1', 'c2']) {
    await ins('customers', {'id': '$s-$c', 'store_id': s, 'name': c, 'created_at': 0, 'loyalty_points': 5});
  }
  await ins('suppliers', {'id': '$s-sup', 'store_id': s, 'name': 'Sup', 'created_at': 0});
  await ins('discounts', {
    'id': '$s-d1',
    'store_id': s,
    'name': 'd1',
    'type': 'percentOff',
    'value': 10,
    'applied_scope': 'product',
    'scope_target_id': '$s-p1',
    'is_active': 1,
  });
  await ins('discounts', {
    'id': '$s-d2',
    'store_id': s,
    'name': 'd2',
    'type': 'amountOff',
    'value': 100,
    'applied_scope': 'cart',
    'is_active': 1,
  });
  for (final (id, status) in [('sh1', 'closed'), ('sh2', 'open')]) {
    await ins('shifts', {
      'id': '$s-$id',
      'store_id': s,
      'branch_id': '$s-b1',
      'cashier_id': '$s-cash',
      'opened_at': 0,
      'opening_cash_float_minor_units': 0,
      'status': status,
    });
  }
  await ins('employee_breaks', {
    'id': '$s-br1',
    'store_id': s,
    'user_id': '$s-cash',
    'shift_id': '$s-sh1',
    'started_at': 0,
    'ended_at': 300,
    'allowed_minutes': 15,
    'exceeded_minutes': 0,
  });
  await ins('employee_breaks', {
    'id': '$s-br2',
    'store_id': s,
    'user_id': '$s-cash',
    'shift_id': '$s-sh2',
    'started_at': 0,
    'allowed_minutes': 15,
    'exceeded_minutes': 0,
  });
  Future<void> je(String id, String type, String? ref, String dr, String cr, int amount, [String? reverses]) async {
    await ins('journal_entries', {
      'id': '$s-$id',
      'store_id': s,
      'branch_id': '$s-b1',
      'entry_date': 0,
      'reference_type': type,
      'reference_id': ref,
      'memo': '',
      'created_by_user_id': '$s-owner',
      'is_reversal': reverses == null ? 0 : 1,
      'reversal_of_entry_id': reverses,
      'created_at': 0,
    });
    for (final (side, account, debit, credit) in [('d', dr, amount, 0), ('c', cr, 0, amount)]) {
      await ins('journal_lines', {
        'id': '$s-$id-$side',
        'store_id': s,
        'journal_entry_id': '$s-$id',
        'account_id': '$s-$account',
        'debit_minor_units': debit,
        'credit_minor_units': credit,
        'description': '',
      });
    }
  }

  await je('je-sale1', 'SALE', '$s-sale1', 'cash', 'rev', 400);
  await je('je-sale2', 'SALE', '$s-sale2', 'ar', 'rev', 200);
  await je('je-sale1-rev', 'SALE', '$s-sale1', 'rev', 'cash', 400, '$s-je-sale1');
  await je('je-ret', 'RETURN', '$s-ret1', 'rev', 'cash', 200);
  await je('je-pay', 'DEBT_PAYMENT', '$s-pay1', 'cash', 'ar', 50);
  await je('je-exp', 'EXPENSE', null, 'exp', 'cash', 30);
  await je('je-exp-adj', 'ADJUSTMENT', '$s-je-exp', 'exp', 'exp', 30);
  await je('je-po', 'PURCHASE', '$s-po1', 'inv', 'ap', 1000);
  await je('je-sp', 'SUPPLIER_PAYMENT', '$s-st2', 'ap', 'cash', 500);
  await je('je-shrink', 'ADJUSTMENT', '$s-sm-adj', 'exp', 'inv', 100);
  await je('je-manual', 'MANUAL', null, 'cash', 'rev', 10);
  await ins('expense_details', {
    'journal_entry_id': '$s-je-exp',
    'store_id': s,
    'expense_group': 'fixed',
    'category': 'rent',
    'amount_minor_units': 30,
    'entry_date': 0,
  });
  for (final (id, number, status, customer, method, shift, entry) in [
    ('sale1', '1', 'partiallyRefunded', '$s-c1', 'cash', '$s-sh1', '$s-je-sale1'),
    ('sale2', '2', 'completed', '$s-c2', 'payLater', '$s-sh2', '$s-je-sale2'),
    ('held', '3', 'held', null, 'cash', null, null),
  ]) {
    await ins('sales', {
      'id': '$s-$id',
      'store_id': s,
      'branch_id': '$s-b1',
      'sale_number': number,
      'status': status,
      'customer_id': customer,
      'subtotal_minor_units': 400,
      'discount_total_minor_units': 0,
      'tax_total_minor_units': 0,
      'grand_total_minor_units': 400,
      'payment_method': method,
      'shift_id': shift,
      'cashier_id': '$s-cash',
      'journal_entry_id': entry,
      'created_at': 0,
    });
  }
  for (final (id, sale, product) in [('sl1', 'sale1', 'p1'), ('sl2', 'sale2', 'p2'), ('sl3', 'held', 'p2')]) {
    await ins('sale_lines', {
      'id': '$s-$id',
      'sale_id': '$s-$sale',
      'product_id': '$s-$product',
      'quantity': 1,
      'unit_price_minor_units': 200,
      'discount_amount_minor_units': 0,
      'tax_amount_minor_units': 0,
      'line_total_minor_units': 200,
      'cost_price_snapshot_minor_units': 100,
      'quantity_returned': 0,
    });
  }
  await ins('sale_returns', {
    'id': '$s-ret1',
    'store_id': s,
    'branch_id': '$s-b1',
    'original_sale_id': '$s-sale1',
    'refund_method': 'cash',
    'journal_entry_id': '$s-je-ret',
    'processed_by_user_id': '$s-owner',
    'created_at': 0,
  });
  await ins('sale_return_lines', {
    'id': '$s-srl1',
    'sale_return_id': '$s-ret1',
    'sale_line_id': '$s-sl1',
    'quantity_returned': 1,
    'refund_amount_minor_units': 200,
  });
  await ins('debt_ledger_entries', {
    'id': '$s-debt1',
    'store_id': s,
    'branch_id': '$s-b1',
    'customer_id': '$s-c2',
    'sale_id': '$s-sale2',
    'journal_entry_id': '$s-je-sale2',
    'original_amount_minor_units': 200,
    'amount_paid_minor_units': 50,
    'status': 'partiallyPaid',
    'created_at': 0,
  });
  await ins('debt_payments', {
    'id': '$s-pay1',
    'debt_ledger_entry_id': '$s-debt1',
    'amount_minor_units': 50,
    'payment_method': 'cash',
    'received_by_user_id': '$s-cash',
    'journal_entry_id': '$s-je-pay',
    'paid_at': 0,
  });
  await ins('purchase_orders', {
    'id': '$s-po1',
    'store_id': s,
    'branch_id': '$s-b1',
    'supplier_id': '$s-sup',
    'status': 'received',
    'order_date': 0,
    'total_cost_minor_units': 1000,
    'paid_immediately': 0,
  });
  await ins('purchase_order_lines', {
    'id': '$s-pol1',
    'purchase_order_id': '$s-po1',
    'product_id': '$s-p1',
    'quantity_ordered': 10,
    'quantity_received': 10,
    'unit_cost_minor_units': 100,
  });
  for (final (id, type, amount, po, entry) in [
    ('st1', 'purchase', 1000, '$s-po1', '$s-je-po'),
    ('st2', 'payment', 500, null, '$s-je-sp'),
  ]) {
    await ins('supplier_transactions', {
      'id': '$s-$id',
      'store_id': s,
      'supplier_id': '$s-sup',
      'type': type,
      'amount_minor_units': amount,
      'related_purchase_order_id': po,
      'journal_entry_id': entry,
      'created_by_user_id': '$s-owner',
      'created_at': 0,
    });
  }
  for (final (id, product, type, qty, refType, ref) in [
    ('sm-po', 'p1', 'purchaseIn', 10, 'PURCHASE_ORDER', '$s-po1'),
    ('sm-sale', 'p1', 'saleOut', 2, 'SALE', '$s-sale1'),
    ('sm-ret', 'p1', 'returnIn', 1, 'SALE_RETURN', '$s-ret1'),
    ('sm-adj', 'p1', 'adjustmentOut', 2, 'ADJUSTMENT', null),
    ('sm-open', 'p2', 'adjustmentIn', 6, 'OPENING_STOCK', null),
  ]) {
    await ins('stock_movements', {
      'id': '$s-$id',
      'store_id': s,
      'product_id': '$s-$product',
      'branch_id': '$s-b1',
      'type': type,
      'quantity': qty,
      'unit_cost_minor_units': 0,
      'reference_type': refType,
      'reference_id': ref,
      'created_by_user_id': '$s-owner',
      'created_at': 0,
    });
  }
  await ins('stock_transfers', {
    'id': '$s-tr1',
    'store_id': s,
    'from_branch_id': '$s-b1',
    'to_branch_id': '$s-b1',
    'status': 'pending',
    'requested_by_user_id': '$s-owner',
    'created_at': 0,
  });
  await ins('stock_transfer_lines', {
    'id': '$s-trl1',
    'stock_transfer_id': '$s-tr1',
    'product_id': '$s-p2',
    'quantity': 1,
  });
}
