// Every main screen, drawn at phone and tablet sizes (and a desktop window),
// must lay out without overflowing. Runs on the local (Drift) build with a
// small seeded store:
//
//   flutter test test/screens --dart-define=UNOPOS_USE_SUPABASE=false
//
// With SHOTS_DIR set, a PNG of each screen is saved there, for looking at.
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/app/app.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/l10n/kurdish_locale_fallback.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/core/routing/app_bootstrap.dart';
import 'package:unopos/core/routing/app_router.dart';
import 'package:unopos/core/supabase/supabase_config.dart';
import 'package:unopos/core/theming/app_theme.dart';
import 'package:unopos/core/theming/glass_background.dart';
import 'package:unopos/core/constants/default_chart_of_accounts.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/licensing/data/licensing_repository_drift.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

/// Licensed, so the app opens on its screens rather than the lock.
class _LicensedRepository extends DriftLicensingRepository {
  _LicensedRepository(super.db);
  @override
  Future<({bool licensed, DateTime? expiresAt})> licenseFor(String storeId) async => (licensed: true, expiresAt: null);
}

const _sizes = {
  'phone': Size(360, 780),
  'tablet': Size(800, 1280),
  'tablet-land': Size(1280, 800),
};

typedef _Action = Future<void> Function(WidgetTester tester);

/// A screen, optionally with something done on it (a dialog opened).
class _Case {
  const _Case(this.route, [this.name, this.action]);
  final String route;
  final String? name;
  final _Action? action;
  String get label => name ?? route.substring(1);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) throw StateError('nothing to tap: $finder');
  await tester.tap(finder.first, warnIfMissed: false);
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 120));
  }
}

final _cases = <_Case>[
  const _Case('/home'),
  const _Case('/pos'),
  _Case('/pos', 'pos-cart', (t) async {
    await _tap(t, find.text('بسكويت'));
    await _tap(t, find.text('شاي محمود 500 غم'));
    // On a phone the cart opens from the bar at the bottom.
    final bar = find.byIcon(Icons.shopping_cart_outlined);
    if (bar.evaluate().isNotEmpty) await _tap(t, bar);
  }),
  _Case('/pos', 'pos-pay', (t) async {
    await _tap(t, find.text('بسكويت'));
    final pay = find.byIcon(Icons.payments_outlined);
    await _tap(t, pay.evaluate().isNotEmpty ? pay : find.text('الدفع'));
  }),
  const _Case('/invoices'),
  _Case('/invoices', 'invoice-details', (t) => _tap(t, find.text('S-000005'))),
  const _Case('/inventory'),
  _Case('/inventory', 'product-new', (t) => _tap(t, find.byType(FloatingActionButton))),
  _Case('/inventory', 'stock-receive', (t) async {
    await _tap(t, find.byIcon(Icons.add_box_outlined));
    await t.enterText(find.byType(TextField).first, 'بسكويت');
    await _tap(t, find.text('بسكويت').last);
  }),
  const _Case('/debts'),
  const _Case('/customers'),
  _Case('/customers', 'customer-details', (t) => _tap(t, find.text('أبو أحمد'))),
  const _Case('/suppliers'),
  const _Case('/accounting'),
  const _Case('/expenses-cash'),
  _Case('/expenses-cash', 'expense-new', (t) => _tap(t, find.byIcon(Icons.add))),
  const _Case('/hr'),
  _Case('/hr', 'employee-new', (t) => _tap(t, find.byType(FloatingActionButton))),
  const _Case('/reports'),
  const _Case('/settings'),
];

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final p in paths) {
      final bytes = File(p).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('UnoSans', ['assets/fonts/NotoSansLatin-Regular.ttf', 'assets/fonts/NotoSansLatin-Bold.ttf']);
  await load('UnoArabic', ['assets/fonts/NotoSansArabic-Regular.ttf', 'assets/fonts/NotoSansArabic-Bold.ttf']);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final icons = [
    if (flutterRoot != null) '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ].where((p) => File(p).existsSync()).toList();
  if (icons.isNotEmpty) await load('MaterialIcons', icons);
}

void main() {
  if (kUseSupabaseBackend) {
    test('screens (run with --dart-define=UNOPOS_USE_SUPABASE=false)', () {}, skip: true);
    return;
  }

  final shotsDir = Platform.environment['SHOTS_DIR'];
  final only = Platform.environment['SHOTS_ONLY'];
  final locales = (Platform.environment['SHOTS_LOCALES'] ?? 'ar').split(',');

  testWidgets('every main screen lays out at phone, tablet and desktop sizes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(_loadFonts);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    late ProviderContainer container;
    await tester.runAsync(() async {
      container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        licensingRepositoryProvider.overrideWith((ref) => _LicensedRepository(ref.watch(databaseProvider))),
        appBootstrapProvider.overrideWith(
          (ref) async => AppBootstrapResult(
            store: ref.read(sessionControllerProvider).store,
            hasValidLicense: true,
            hasEmployees: true,
          ),
        ),
      ]);
      await _seed(container);
      container.read(licenseValidProvider.notifier).state = true;
      container.read(storeHasEmployeesProvider.notifier).state = true;
      await container.read(appBootstrapProvider.future);
    });

    final problems = <String>[];
    final boundary = GlobalKey();

    for (final locale in locales) {
      for (final entry in _sizes.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1;
        for (final c in _cases) {
          if (only != null && !c.label.contains(only)) continue;
          final route = c.route;
          final errors = <String>[];
          final old = FlutterError.onError;
          FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').take(4).join(' | '));
          final router = container.read(routerProvider);
          // A fresh screen each time: no dialog or cart left from before.
          await tester.pumpWidget(const SizedBox.shrink());
          container.read(cartControllerProvider.notifier).clear();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: RepaintBoundary(
                key: boundary,
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light(),
                  locale: Locale(locale),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    KurdishFallbackMaterialLocalizationsDelegate(),
                    KurdishFallbackWidgetsLocalizationsDelegate(),
                    KurdishFallbackCupertinoLocalizationsDelegate(),
                  ],
                  scrollBehavior: const AppScrollBehavior(),
                  builder: (context, child) => Directionality(
                    textDirection: locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
                    child: GlassBackground(child: child ?? const SizedBox.shrink()),
                  ),
                  routerConfig: router,
                ),
              ),
            ),
          );
          router.go(route);
          for (var i = 0; i < 8; i++) {
            await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
            await tester.pump(const Duration(milliseconds: 100));
          }
          if (c.action != null) {
            try {
              await c.action!(tester);
            } catch (e) {
              errors.add('action failed: $e');
            }
          }
          final exception = tester.takeException();
          if (exception != null) errors.add('$exception'.split('\n').first);
          FlutterError.onError = old;
          if (errors.isNotEmpty) {
            // The first error explains the rest (later ones cascade from it).
            final first = errors.first;
            problems.add('[$locale ${entry.key} ${c.label}] ${first.length > 400 ? first.substring(0, 400) : first}');
          }

          if (shotsDir != null) {
            await tester.runAsync(() async {
              final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
              final image = await render.toImage();
              final png = await image.toByteData(format: ui.ImageByteFormat.png);
              final name = '${c.label.replaceAll('/', '_')}_${entry.key}_$locale.png';
              File('$shotsDir/$name')
                ..createSync(recursive: true)
                ..writeAsBytesSync(png!.buffer.asUint8List());
            });
          }
        }
      }
    }

    // Stop the clock and other timers before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    tester.view.reset();
    await tester.runAsync(() async {
      container.dispose();
      await db.close();
    });

    if (problems.isNotEmpty) {
      // ignore: avoid_print
      print('SCREEN PROBLEMS:\n${problems.join('\n')}');
      if (shotsDir != null) File('$shotsDir/problems.txt').writeAsStringSync(problems.join('\n'));
    }
    expect(problems, isEmpty);
  });
}

/// A small store with something on every screen.
Future<void> _seed(ProviderContainer c) async {
  final auth = c.read(authRepositoryProvider);
  final store = await auth.createStore(
    storeLoginId: 'mars',
    password: 'pw123456',
    displayName: 'سوبرماركت المريخ',
  );
  final branch = await auth.createBranch(storeId: store.id, name: 'الفرع الرئيسي', isMainBranch: true);
  await auth.createBranch(storeId: store.id, name: 'فرع الكرادة');
  final owner = await auth.createEmployee(storeId: store.id, name: 'فيصل فؤاد', role: 'owner', pin: '4826');
  await auth.createEmployee(
    storeId: store.id,
    branchId: branch.id,
    name: 'علي حسين',
    role: 'cashier',
    pin: '5931',
    phone: '07701234567',
  );
  await c.read(settingsRepositoryProvider).ensureSettings(store.id);
  await c.read(accountingRepositoryProvider).seedDefaultChartOfAccounts(store.id);

  final session = c.read(sessionControllerProvider.notifier);
  session.setStore(store);
  await session.signInEmployeeDirectly(owner);
  session.setCurrentBranch(branch.id);

  final inventory = c.read(inventoryRepositoryProvider);
  final names = [
    'شاي محمود 500 غم',
    'سكر أبيض 1 كغم',
    'رز بسمتي 5 كغم',
    'زيت دوار الشمس 1.8 لتر',
    'معجون طماطم',
    'حليب نيدو 900 غم',
    'مياه معدنية 24 قنينة',
    'بسكويت',
  ];
  final products = <ProductRecord>[];
  for (var i = 0; i < names.length; i++) {
    final p = await inventory.createProduct(
      ProductRecord(
        id: '',
        storeId: store.id,
        sku: 'SKU-${1000 + i}',
        barcode: '62${100000000 + i}',
        name: names[i],
        costPriceMinorUnits: (1000 + i * 750) * 100 ~/ 100,
        sellPriceMinorUnits: 1500 + i * 1000,
        wholesalePriceMinorUnits: 1400 + i * 900,
        reorderLevel: 5,
      ),
    );
    products.add(p);
    if (i != 3) {
      await inventory.recordStockMovement(
        storeId: store.id,
        productId: p.id,
        branchId: branch.id,
        type: StockMovementType.purchaseIn,
        quantity: i == 5 ? 3 : 40 + i,
        unitCostMinorUnits: p.costPriceMinorUnits,
        createdByUserId: owner.id,
      );
    }
  }

  final debts = c.read(debtsRepositoryProvider);
  final customer = await debts.createCustomer(store.id, 'أبو أحمد', phone: '07801112233', address: 'بغداد - المنصور');
  await debts.createCustomer(store.id, 'أم زينب', phone: '07709998877');

  final shift = await c.read(shiftsRepositoryProvider).openShift(
        storeId: store.id,
        branchId: branch.id,
        cashierId: owner.id,
        openingCashFloatMinorUnits: 50000,
      );
  final sales = c.read(completeSaleUseCaseProvider);
  SaleLineInput line(ProductRecord p, int qty) => SaleLineInput(
        productId: p.id,
        quantity: qty,
        unitPriceMinorUnits: p.sellPriceMinorUnits,
        costPriceSnapshotMinorUnits: p.costPriceMinorUnits,
      );
  for (var i = 0; i < 4; i++) {
    final lines = [line(products[i], 1 + i), line(products[(i + 2) % 8], 2)];
    final total = lines.fold<int>(0, (s, l) => s + l.unitPriceMinorUnits * l.quantity);
    await sales.checkout(
      storeId: store.id,
      branchId: branch.id,
      cashierId: owner.id,
      shiftId: shift.id,
      paymentMethod: SalePaymentMethod.cash,
      lines: lines,
      amountTenderedMinorUnits: total,
      changeGivenMinorUnits: 0,
    );
  }
  await sales.checkout(
    storeId: store.id,
    branchId: branch.id,
    cashierId: owner.id,
    shiftId: shift.id,
    paymentMethod: SalePaymentMethod.payLater,
    lines: [line(products[2], 2)],
    customerNameForPayLater: customer.name,
    extras: {'customer_id': customer.id},
  );
  await sales.holdSale(
    storeId: store.id,
    branchId: branch.id,
    cashierId: owner.id,
    shiftId: shift.id,
    holdLabel: 'زبون ينتظر',
    lines: [line(products[1], 3)],
  );
  await c.read(accountingPostingServiceProvider).postExpense(
        storeId: store.id,
        branchId: branch.id,
        expenseAccountCode: SystemAccountCodes.miscExpense,
        createdByUserId: owner.id,
        amountMinorUnits: 25000,
        isCash: true,
        memo: 'كهرباء',
      );
  await c.read(suppliersRepositoryProvider).createSupplier(
        storeId: store.id,
        name: 'شركة النهرين للمواد الغذائية',
        contactPhone: '07901234567',
      );
}
