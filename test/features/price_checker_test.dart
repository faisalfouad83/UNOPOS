import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/constants/magic_passcodes.dart';
import 'package:unopos/core/constants/roles.dart';
import 'package:unopos/core/routing/route_guard.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/features/auth/domain/auth_models.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/price_checker/application/price_checker_controller.dart';
import 'package:unopos/features/price_checker/application/price_checker_mode.dart';
import 'package:unopos/features/price_checker/data/price_catalog_source.dart';
import 'package:unopos/features/price_checker/data/price_snapshot_store.dart';
import 'package:unopos/features/price_checker/domain/price_snapshot.dart';

PriceProduct _product(String id, {String? barcode, String? sku, int price = 1000, String? image}) => PriceProduct(
      id: id,
      name: 'Product $id',
      sku: sku ?? 'SKU-$id',
      barcode: barcode,
      sellPriceMinorUnits: price,
      imagePath: image,
    );

PriceSnapshot _snapshot(String storeId, List<PriceProduct> products, {int version = 1, String id = 'snap-1'}) =>
    PriceSnapshot(
      storeId: storeId,
      snapshotId: id,
      version: version,
      createdAt: DateTime(2026, 10, 1, 9),
      products: products,
    );

/// Hands out a prepared product list (or throws), counting photo downloads.
class _FakeSource implements PriceCatalogSource {
  List<PriceProduct> products = [];
  Object? error;
  final imageFetches = <String>[];

  @override
  Future<List<PriceProduct>> fetchActiveProducts(String storeId) async {
    if (error != null) throw error!;
    return products;
  }

  @override
  Future<Uint8List?> fetchImage(String imagePath) async {
    imageFetches.add(imagePath);
    return Uint8List.fromList(utf8.encode('img:$imagePath'));
  }
}

const _owner = EmployeeRecord(id: 'e1', storeId: 'store-a', name: 'Owner', role: StoreRole.owner, pinHash: '');

StoreRecord _store(String id) => StoreRecord(
      id: id,
      storeLoginId: id,
      passwordHash: '',
      displayName: 'Store $id',
      createdAt: DateTime(2026),
    );

void main() {
  late Directory tmp;
  late PriceSnapshotStore store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('price_checker_test');
    store = PriceSnapshotStore(baseDir: () async => tmp);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  group('snapshot file', () {
    test('is written, read back and replaced as a whole', () async {
      expect(await store.loadSnapshot('store-a'), isNull);
      await store.replaceSnapshot(_snapshot('store-a', [_product('1', barcode: '111')]));
      final first = await store.loadSnapshot('store-a');
      expect(first!.productCount, 1);
      expect(first.products.single.barcode, '111');

      await store.replaceSnapshot(
        _snapshot('store-a', [_product('1'), _product('2')], version: 2, id: 'snap-2'),
      );
      final second = await store.loadSnapshot('store-a');
      expect(second!.snapshotId, 'snap-2');
      expect(second.version, 2);
      expect(second.productCount, 2);
      // No temporary file left behind.
      final dir = await store.storeDir('store-a');
      expect(dir.listSync().whereType<File>().where((f) => f.path.endsWith('.tmp')), isEmpty);
    });

    test('an invalid snapshot is refused and the previous one is kept', () async {
      await store.replaceSnapshot(_snapshot('store-a', [_product('1')]));
      // Repeated product id.
      await expectLater(
        store.replaceSnapshot(_snapshot('store-a', [_product('1'), _product('1')], version: 2, id: 'bad')),
        throwsFormatException,
      );
      // Negative price.
      await expectLater(
        store.replaceSnapshot(_snapshot('store-a', [_product('9', price: -5)], version: 2, id: 'bad')),
        throwsFormatException,
      );
      final kept = await store.loadSnapshot('store-a');
      expect(kept!.snapshotId, 'snap-1');
      expect(kept.productCount, 1);
    });

    test('a damaged or truncated file is not used', () async {
      await store.replaceSnapshot(_snapshot('store-a', [_product('1')]));
      final file = File(p.join((await store.storeDir('store-a')).path, 'snapshot.json'));
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      json['product_count'] = 5;
      await file.writeAsString(jsonEncode(json));
      expect(await store.loadSnapshot('store-a'), isNull);
      await file.writeAsString('{"format": 1, "store_id": "sto');
      expect(await store.loadSnapshot('store-a'), isNull);
    });

    test("another store never reads this store's snapshot", () async {
      await store.replaceSnapshot(_snapshot('store-a', [_product('1')]));
      expect(await store.loadSnapshot('store-b'), isNull);
      // Even a copied file is refused: it names its own store.
      final a = File(p.join((await store.storeDir('store-a')).path, 'snapshot.json'));
      await a.copy(p.join((await store.storeDir('store-b')).path, 'snapshot.json'));
      expect(await store.loadSnapshot('store-b'), isNull);
    });
  });

  group('price index', () {
    final index = PriceIndex([
      _product('1', barcode: '6260001', sku: 'TEA'),
      _product('2', barcode: '6260002', sku: 'SUGAR'),
      _product('3', barcode: '777', sku: 'A1'),
      _product('4', barcode: '777', sku: 'A2'),
      _product('5', barcode: 'X5', sku: '6260002'),
      const PriceProduct(id: '6', name: 'Green apple', sku: 'APL', sellPriceMinorUnits: 250000),
    ]);

    test('one exact barcode or SKU shows the product', () {
      expect((index.lookup('6260001') as PriceFound).product.id, '1');
      expect((index.lookup(' tea ') as PriceFound).product.id, '1');
    });

    test('a barcode shared by several products asks which one, never picks one', () {
      final r = index.lookup('777');
      expect(r, isA<PriceChoices>());
      expect((r as PriceChoices).exact, isTrue);
      expect(r.products.map((p) => p.id), unorderedEquals(['3', '4']));
    });

    test("a barcode that is also another product's SKU asks which one", () {
      final r = index.lookup('6260002') as PriceChoices;
      expect(r.products.map((p) => p.id), ['2', '5']);
    });

    test('partial name search lists matches; nothing found says so', () {
      final r = index.lookup('apple');
      expect(r, isA<PriceChoices>());
      expect((r as PriceChoices).exact, isFalse);
      expect(r.products.single.id, '6');
      expect(index.lookup('zzz'), isA<PriceNotFound>());
    });

    test('the serial is the barcode, or the SKU without one', () {
      expect(_product('1', barcode: '123', sku: 'S').serial, '123');
      expect(_product('1', sku: 'S').serial, 'S');
      expect(_product('1', sku: 'S').serialIsBarcode, isFalse);
    });
  });

  group('synchronization', () {
    PriceCheckerController controller(_FakeSource source, {bool online = true, bool autoStart = true}) {
      final c = PriceCheckerController(
        storeId: 'store-a',
        store: store,
        source: source,
        online: online,
        period: null,
        autoStart: autoStart,
      );
      addTearDown(c.dispose);
      return c;
    }

    test('downloads a snapshot, saves its photos and marks it current', () async {
      final source = _FakeSource()..products = [_product('1', barcode: '111', image: 'store-a/1.png'), _product('2')];
      final c = controller(source);
      await c.ready;
      final s = c.state;
      expect(s.snapshot!.productCount, 2);
      expect(s.snapshot!.version, 1);
      expect(s.meta.lastResult, PriceSyncResult.success);
      expect(s.status(DateTime.now()), PriceCheckerStatus.current);
      expect(s.isCurrent(DateTime.now()), isTrue);
      expect(await store.loadImage('store-a', 'store-a/1.png'), isNotNull);

      // Unchanged photos are not downloaded again; removed products' are dropped.
      source.products = [_product('2'), _product('3', image: 'store-a/3.png')];
      await c.sync();
      expect(source.imageFetches, ['store-a/1.png', 'store-a/3.png']);
      expect(await store.loadImage('store-a', 'store-a/1.png'), isNull);
      expect(c.state.snapshot!.version, 2);
      expect(c.state.snapshot!.products.map((p) => p.id), ['2', '3']);
    });

    test('a failed download keeps the previous snapshot and says so', () async {
      final source = _FakeSource()..products = [_product('1')];
      final c = controller(source);
      await c.ready;
      source.error = const SocketException('no route');
      await c.sync();
      expect(c.state.snapshot!.productCount, 1);
      expect(c.state.snapshot!.version, 1);
      expect(c.state.meta.lastResult, PriceSyncResult.failed);
      expect(c.state.meta.lastSuccessfulSync, isNotNull);
      expect(c.state.status(DateTime.now()), PriceCheckerStatus.failed);
      expect(c.state.isCurrent(DateTime.now()), isFalse);
      // The failure is noted on disk; the snapshot file is untouched.
      expect((await store.loadMeta('store-a')).lastResult, PriceSyncResult.failed);
      expect((await store.loadSnapshot('store-a'))!.version, 1);
    });

    test('an empty answer never wipes a filled snapshot', () async {
      final source = _FakeSource()..products = [_product('1'), _product('2')];
      final c = controller(source);
      await c.ready;
      source.products = [];
      await c.sync();
      expect(c.state.snapshot!.productCount, 2);
      expect(c.state.meta.lastResult, PriceSyncResult.failed);
    });

    test('offline with nothing saved asks for a first online sync', () async {
      final c = controller(_FakeSource(), online: false);
      await c.ready;
      expect(c.state.hasSnapshot, isFalse);
      expect(c.state.status(DateTime.now()), PriceCheckerStatus.needsInitialSync);
    });

    test('a saved snapshot opened online is not called current until refreshed', () async {
      await store.replaceSnapshot(_snapshot('store-a', [_product('1')]));
      await store.saveMeta(PriceSnapshotMeta(
        storeId: 'store-a',
        version: 1,
        lastSuccessfulSync: DateTime.now(),
        lastResult: PriceSyncResult.success,
      ));
      final c = controller(_FakeSource()..products = [_product('1')], autoStart: false);
      await c.openSaved();
      expect(c.state.hasSnapshot, isTrue);
      expect(c.state.status(DateTime.now()), PriceCheckerStatus.saved);
      expect(c.state.isCurrent(DateTime.now()), isFalse);
      c.setOnline(false);
      expect(c.state.status(DateTime.now()), PriceCheckerStatus.offline);
      // Back online: refreshes by itself.
      c.setOnline(true);
      await c.sync();
      expect(c.state.status(DateTime.now()), PriceCheckerStatus.current);
      expect(c.state.snapshot!.version, 2);
      // A refresh long ago is no longer current.
      expect(c.state.isCurrent(DateTime.now().add(const Duration(hours: 1))), isFalse);
    });
  });

  group('price checker code', () {
    test('1515 is reserved and cannot be an employee PIN', () {
      expect(MagicPasscodes.priceChecker, '1515');
      expect(MagicPasscodes.isReserved('1515'), isTrue);
    });

    test('entering 1515 on the PIN pad turns the mode on; only 1515 turns it off', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final session = container.read(sessionControllerProvider.notifier);

      // No store signed in: not accepted.
      expect(await session.submitPin('1515', selectedEmployee: _owner), PinResult.incorrect);

      session.setStore(_store('store-a'));
      expect(await session.submitPin('1515', selectedEmployee: _owner), PinResult.priceChecker);
      final mode = container.read(priceCheckerModeProvider.notifier);
      expect(mode.isOnFor('store-a'), isTrue);
      expect(container.read(sessionControllerProvider).employee, isNull);
      expect((await SharedPreferences.getInstance()).getString(PriceCheckerModeController.prefsKey), 'store-a');

      expect(await mode.tryExit('1313'), isFalse);
      expect(await mode.tryExit('0000'), isFalse);
      expect(mode.isOnFor('store-a'), isTrue);

      expect(await mode.tryExit('1515'), isTrue);
      expect(mode.isOnFor('store-a'), isFalse);
      expect((await SharedPreferences.getInstance()).getString(PriceCheckerModeController.prefsKey), isNull);
    });

    test('the mode survives a restart, for the same store only', () async {
      final before = ProviderContainer();
      await before.read(priceCheckerModeProvider.notifier).enter('store-a');
      before.dispose();

      final after = ProviderContainer();
      addTearDown(after.dispose);
      expect(after.read(priceCheckerModeProvider), isNull);
      await after.read(priceCheckerModeProvider.notifier).load();
      expect(after.read(priceCheckerModeProvider.notifier).isOnFor('store-a'), isTrue);
      expect(after.read(priceCheckerModeProvider.notifier).isOnFor('store-b'), isFalse);
      expect(after.read(priceCheckerModeProvider.notifier).isOnFor(null), isFalse);
    });
  });

  group('route guard', () {
    String? go(String location, {bool mode = true, bool hasStore = true, SessionState? session}) => RouteGuard.redirect(
          location: location,
          hasValidLicense: true,
          hasStoreOnDisk: hasStore,
          hasEmployees: true,
          session: session ?? SessionState(store: _store('store-a')),
          priceCheckerMode: mode,
        );

    test('locks every screen to the price checker while the mode is on', () {
      for (final location in [
        RoutePaths.home,
        RoutePaths.pos,
        RoutePaths.settings,
        RoutePaths.debts,
        RoutePaths.accounting,
        RoutePaths.customers,
        RoutePaths.tilePicker,
        RoutePaths.pinPad,
        RoutePaths.storeLogin,
        RoutePaths.developerHome,
      ]) {
        expect(go(location), RoutePaths.priceChecker, reason: location);
      }
      expect(go(RoutePaths.priceChecker), isNull);
    });

    test('the price checker is not reachable without the mode', () {
      expect(go(RoutePaths.priceChecker, mode: false), RoutePaths.tilePicker);
      expect(
        go(RoutePaths.priceChecker, mode: false, session: SessionState(store: _store('store-a'), employee: _owner)),
        RoutePaths.home,
      );
    });

    test('with the store signed out, the mode waits for it to sign in again', () {
      expect(
          go(RoutePaths.priceChecker, hasStore: false, session: const SessionState()), isNot(RoutePaths.priceChecker));
    });
  });
}
