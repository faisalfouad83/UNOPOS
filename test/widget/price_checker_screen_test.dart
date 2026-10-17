import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/utils/formatters.dart';
import 'package:unopos/features/price_checker/application/price_checker_controller.dart';
import 'package:unopos/features/price_checker/application/price_checker_mode.dart';
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
  testWidgets('a scan shows the price, name and serial; idle clears after 30 s', (tester) async {
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

    await tester.pump(PriceCheckerView.idleTimeout + const Duration(seconds: 1));
    expect(find.text('Scan a product to see its price'), findsOneWidget);
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
