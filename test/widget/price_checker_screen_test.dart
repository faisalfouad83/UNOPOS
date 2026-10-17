import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/core/routing/route_guard.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/features/auth/data/auth_repository_drift.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/auth/presentation/tile_picker_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/utils/formatters.dart';
import 'package:unopos/features/price_checker/application/price_checker_controller.dart';
import 'package:unopos/features/price_checker/application/price_checker_mode.dart';
import 'package:unopos/features/price_checker/application/price_checker_timing.dart';
import 'package:unopos/features/price_checker/data/price_catalog_source.dart';
import 'package:unopos/features/price_checker/data/price_snapshot_store.dart';
import 'package:unopos/features/price_checker/domain/price_snapshot.dart';
import 'package:unopos/features/price_checker/presentation/price_checker_screen.dart';

/// Keeps everything in memory, so the screen test needs no real files.
class _MemoryStore extends PriceSnapshotStore {
  final snapshots = <String, PriceSnapshot>{};
  final metas = <String, PriceSnapshotMeta>{};

  @override
  Future<PriceSnapshot?> loadSnapshot(String storeId) async => snapshots[storeId];

  @override
  Future<PriceSnapshot> replaceSnapshot(PriceSnapshot candidate) async {
    candidate.validate(expectedStoreId: candidate.storeId);
    return snapshots[candidate.storeId] = candidate;
  }

  @override
  Future<PriceSnapshotMeta> loadMeta(String storeId) async => metas[storeId] ?? PriceSnapshotMeta(storeId: storeId);

  @override
  Future<void> saveMeta(PriceSnapshotMeta meta) async => metas[meta.storeId] = meta;

  @override
  Future<bool> hasImage(String storeId, String imagePath) async => true;

  @override
  Future<Uint8List?> loadImage(String storeId, String imagePath) async => null;

  @override
  Future<void> pruneImages(String storeId, Iterable<String> keepImagePaths) async {}
}

class _Source implements PriceCatalogSource {
  _Source(this.products);
  final List<PriceProduct> products;

  @override
  Future<List<PriceProduct>> fetchActiveProducts(String storeId) async => products;

  @override
  Future<Uint8List?> fetchImage(String imagePath) async => null;
}

const _products = [
  PriceProduct(id: '1', name: 'Mahmoud Tea 500g', sku: 'TEA', barcode: '6260001', sellPriceMinorUnits: 350000),
  PriceProduct(id: '2', name: 'Sugar 1kg', sku: 'SUGAR', sellPriceMinorUnits: 150000, unit: 'kg'),
  PriceProduct(id: '3', name: 'Cola can', sku: 'C1', barcode: '777', sellPriceMinorUnits: 75000),
  PriceProduct(id: '4', name: 'Cola can (diet)', sku: 'C2', barcode: '777', sellPriceMinorUnits: 80000),
];

Future<ProviderContainer> _pump(WidgetTester tester, {Size size = const Size(1280, 800), Locale? locale}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(overrides: [
    priceSnapshotStoreProvider.overrideWithValue(_MemoryStore()),
    priceCatalogSourceProvider.overrideWithValue(_Source(_products)),
  ]);
  await container.read(priceCheckerModeProvider.notifier).enter('store-a');
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PriceCheckerView(storeId: 'store-a', storeName: 'Karrada Market'),
    ),
  ));
  await tester.pump();
  await tester.pump();
  return container;
}

Future<void> _type(WidgetTester tester, String text) async {
  final submit = text.endsWith('\n');
  await tester.enterText(find.byType(TextField), submit ? text.substring(0, text.length - 1) : text);
  if (submit) await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  await tester.pump();
}

bool _focused(WidgetTester tester) => tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

Future<void> _tapDigits(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text(d)));
    await tester.pump();
  }
  await tester.pump();
}

/// Ends a test: closes the screen and its providers, so no refresh timer
/// outlives the test.
Future<void> _close(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(const SizedBox());
  container.dispose();
}

void main() {
  testWidgets('a scan shows the price, name and serial; it clears after 5 s', (tester) async {
    final c = await _pump(tester);
    expect(find.text('Karrada Market'), findsOneWidget);
    expect(find.text('Products synchronized successfully.'), findsOneWidget);
    expect(find.text('Scan a product to see its price'), findsOneWidget);
    expect(find.text(priceCheckerSerialLabel), findsOneWidget);

    await _type(tester, '6260001\n');
    expect(find.text('Mahmoud Tea 500g'), findsOneWidget);
    expect(find.text(Money.format(350000)), findsOneWidget);
    expect(find.text('Serial Number'), findsOneWidget);
    expect(find.textContaining('6260001'), findsOneWidget);
    expect(find.text('Latest data'), findsOneWidget);

    await tester.pump(PriceCheckerTiming.resultDisplay + const Duration(milliseconds: 100));
    expect(find.text('Scan a product to see its price'), findsOneWidget);
    expect(find.text('Mahmoud Tea 500g'), findsNothing);
    expect(_focused(tester), isTrue);
    await _close(tester, c);
  });

  testWidgets('the box has the keyboard on entry, so a scanner needs no tap', (tester) async {
    final c = await _pump(tester, size: const Size(800, 1280));
    expect(_focused(tester), isTrue);
    await _type(tester, '6260001\n');
    expect(find.text('Mahmoud Tea 500g'), findsOneWidget);
    // Cleared and still focused, ready for the next scan straight away.
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    expect(_focused(tester), isTrue);
    await _close(tester, c);
  });

  testWidgets('a new scan restarts the 5 s and replaces the last product', (tester) async {
    final c = await _pump(tester);
    await _type(tester, '6260001\n');
    await tester.pump(const Duration(seconds: 4));
    await _type(tester, 'sugar\n');
    expect(find.text('Mahmoud Tea 500g'), findsNothing);
    expect(find.text('Sugar 1kg'), findsOneWidget);
    // 4 s into the new result: the first scan's clock must not clear it.
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Sugar 1kg'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1, milliseconds: 100));
    expect(find.text('Sugar 1kg'), findsNothing);
    expect(find.text('Scan a product to see its price'), findsOneWidget);
    await _close(tester, c);
  });

  testWidgets('typing is never wiped by the reset, and hides the last product', (tester) async {
    final c = await _pump(tester);
    await _type(tester, '6260001\n');
    await _type(tester, 'c');
    // The new search started: the tea must not pass for its result.
    expect(find.text('Mahmoud Tea 500g'), findsNothing);
    await tester.pump(PriceCheckerTiming.resultDisplay * 2);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'c');
    await _close(tester, c);
  });

  testWidgets('back-to-back scans each show once, none lost', (tester) async {
    final c = await _pump(tester);
    for (var i = 0; i < 5; i++) {
      await _type(tester, i.isEven ? '6260001\n' : 'sugar\n');
      expect(find.text(i.isEven ? 'Mahmoud Tea 500g' : 'Sugar 1kg'), findsOneWidget);
    }
    await _close(tester, c);
  });

  testWidgets('a product without a barcode shows its SKU as the serial', (tester) async {
    final c = await _pump(tester);
    await _type(tester, 'sugar\n');
    expect(find.text('Sugar 1kg'), findsOneWidget);
    expect(find.textContaining('SUGAR'), findsOneWidget);
    expect(find.textContaining('SKU'), findsWidgets);
    await _close(tester, c);
  });

  testWidgets('a shared barcode lists the products to choose from', (tester) async {
    final c = await _pump(tester);
    await _type(tester, '777\n');
    expect(find.text('This code belongs to several products — choose the right one'), findsOneWidget);
    expect(find.text('Cola can'), findsOneWidget);
    expect(find.text('Cola can (diet)'), findsOneWidget);
    await tester.tap(find.text('Cola can (diet)'));
    await tester.pump();
    expect(find.text(Money.format(80000)), findsOneWidget);
    await _close(tester, c);
  });

  testWidgets('leaving needs the code: a wrong one is refused, 1515 leaves', (tester) async {
    final container = await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('price-checker-exit')));
    await tester.pump();
    await tester.pump();
    await _tapDigits(tester, '1234');
    expect(find.text('Wrong code. Try again.'), findsOneWidget);
    expect(container.read(priceCheckerModeProvider.notifier).isOnFor('store-a'), isTrue);
    await _tapDigits(tester, '1515');
    await tester.pump(const Duration(milliseconds: 400));
    expect(container.read(priceCheckerModeProvider.notifier).isOnFor('store-a'), isFalse);
    expect(find.byType(AlertDialog), findsNothing);
    await _close(tester, container);
  });

  testWidgets('in from the account tile and out with the code, three times: never a blank screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final auth = DriftAuthRepository(db);
    late ProviderContainer container;
    await tester.runAsync(() async {
      final store = await auth.createStore(storeLoginId: 'shop', password: 'pw123456', displayName: 'Karrada Market');
      await auth.createEmployee(storeId: store.id, name: 'Sara', role: 'owner', pin: '1111');
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        priceSnapshotStoreProvider.overrideWithValue(_MemoryStore()),
        priceCatalogSourceProvider.overrideWithValue(_Source(_products)),
      ]);
      container.read(sessionControllerProvider.notifier).setStore(store);
    });
    // The app's own redirect rules, refreshed when the mode changes (the
    // refresh is what used to pull the page out from under the dialog).
    final refresh = ValueNotifier(0);
    container.listen(priceCheckerModeProvider, (_, __) => refresh.value++);
    final router = GoRouter(
      initialLocation: RoutePaths.tilePicker,
      refreshListenable: refresh,
      redirect: (context, state) {
        final session = container.read(sessionControllerProvider);
        return RouteGuard.redirect(
          location: state.matchedLocation,
          hasValidLicense: true,
          hasStoreOnDisk: session.hasStore,
          hasEmployees: true,
          session: session,
          priceCheckerMode: container.read(priceCheckerModeProvider.notifier).isOnFor(session.store?.id),
        );
      },
      routes: [
        GoRoute(path: RoutePaths.tilePicker, builder: (context, state) => const TilePickerScreen()),
        GoRoute(path: RoutePaths.priceChecker, builder: (context, state) => const PriceCheckerScreen()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await settle();
    for (var round = 0; round < 3; round++) {
      expect(find.text('Sara'), findsOneWidget, reason: 'round $round: the accounts show');
      await tester.tap(find.byKey(const ValueKey('price-checker-tile')));
      await settle();
      await _tapDigits(tester, '1515');
      await settle();
      expect(find.text('Scan a product to see its price'), findsOneWidget, reason: 'round $round: checker open');
      expect(_focused(tester), isTrue);
      await _type(tester, '6260001\n');
      expect(find.text('Mahmoud Tea 500g'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('price-checker-exit')));
      await settle();
      await _tapDigits(tester, '1515');
      await settle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(PriceCheckerView), findsNothing);
      expect(find.byType(TilePickerScreen), findsOneWidget, reason: 'round $round: back on the accounts');
      expect(container.read(priceCheckerModeProvider), isNull);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    // Drift closes its watched queries on a zero timer.
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(db.close);
  });

  for (final entry in {
    'phone': const Size(360, 740),
    'tablet': const Size(800, 1280),
    'desktop': const Size(1440, 900),
  }.entries) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('lays out on a ${entry.key} (${locale.languageCode})', (tester) async {
        final c = await _pump(tester, size: entry.value, locale: locale);
        await _type(tester, '6260001\n');
        expect(tester.takeException(), isNull);
        expect(find.text(Money.format(350000)), findsOneWidget);
        await _type(tester, '777\n');
        expect(tester.takeException(), isNull);
        await _close(tester, c);
      });
    }
  }
}
