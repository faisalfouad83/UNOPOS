// Every one of the twelve themes, in English, Arabic and Kurdish, at phone
// and desktop sizes: the Settings screen (with the theme picker), the
// developer's Themes tab and a sample of common widgets — buttons, chips,
// inputs, status colours, a dialog — must draw without an exception or
// overflow. Mirrors the harness in test/screens/screens_test.dart.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/app/app.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/l10n/kurdish_locale_fallback.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/core/supabase/supabase_config.dart';
import 'package:unopos/core/theming/app_theme.dart';
import 'package:unopos/core/theming/glass_background.dart';
import 'package:unopos/core/theming/store_themes.dart';
import 'package:unopos/core/utils/formatters.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/developer/presentation/theme_assignments_tab.dart';
import 'package:unopos/features/settings/presentation/settings_screen.dart';

/// A bit of everything a cashier sees, in the theme's colours.
class _Sample extends StatelessWidget {
  const _Sample();

  @override
  Widget build(BuildContext context) {
    final status = StatusColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('UNOPOS')),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'POS'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Stock'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(Money.format(1250000)),
              subtitle: Text('Paid', style: TextStyle(color: status.success)),
              trailing: Text('Due', style: TextStyle(color: scheme.error)),
            ),
          ),
          Text('Pending', style: TextStyle(color: status.warning)),
          const TextField(decoration: InputDecoration(labelText: 'Search')),
          Wrap(spacing: 8, children: [
            FilledButton(onPressed: () {}, child: const Text('Pay')),
            OutlinedButton(onPressed: () {}, child: const Text('Hold')),
            TextButton(onPressed: () {}, child: const Text('Cancel')),
            const Chip(label: Text('Cash')),
            const FilterChip(label: Text('Card'), selected: true, onSelected: null),
          ]),
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(title: Text('Receipt'), content: Text('Printed')),
              ),
              child: const Text('open dialog'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  if (kUseSupabaseBackend) {
    test('themes (run with --dart-define=UNOPOS_USE_SUPABASE=false)', () {}, skip: true);
    return;
  }

  testWidgets('every theme draws the sample screens in en, ar and ckb', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    late ProviderContainer container;
    await tester.runAsync(() async {
      container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      final auth = container.read(authRepositoryProvider);
      final store = await auth.createStore(storeLoginId: 'shop', password: 'pw123456', displayName: 'متجر');
      await auth.createBranch(storeId: store.id, name: 'Main', isMainBranch: true);
      await container.read(settingsRepositoryProvider).ensureSettings(store.id);
      container.read(sessionControllerProvider.notifier).setStore(store);
    });

    final problems = <String>[];
    const sizes = {'phone': Size(360, 780), 'desktop': Size(1280, 800)};
    final screens = <String, Widget>{
      'settings': const SettingsScreen(),
      'developer-themes': const Scaffold(body: ThemeAssignmentsTab()),
      'sample': const _Sample(),
    };

    Future<void> settle() async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    for (final key in StoreThemeKey.values) {
      for (final locale in const ['en', 'ar', 'ckb']) {
        for (final size in sizes.entries) {
          tester.view.physicalSize = size.value;
          tester.view.devicePixelRatio = 1;
          for (final screen in screens.entries) {
            final errors = <String>[];
            final old = FlutterError.onError;
            FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').first);
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpWidget(UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.forKey(key),
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
                home: screen.value,
              ),
            ));
            await settle();
            if (screen.key == 'sample') {
              await tester.tap(find.text('open dialog'));
              await settle();
            }
            final exception = tester.takeException();
            if (exception != null) errors.add('$exception'.split('\n').first);
            FlutterError.onError = old;
            if (errors.isNotEmpty) problems.add('[${key.dbKey} $locale ${size.key} ${screen.key}] ${errors.first}');
          }
        }
      }
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    tester.view.reset();
    await tester.runAsync(() async {
      container.dispose();
      await db.close();
    });
    expect(problems, isEmpty, reason: problems.take(10).join('\n'));
  });
}
