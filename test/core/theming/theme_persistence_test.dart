import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/core/theming/store_themes.dart';
import 'package:unopos/core/theming/theme_controller.dart';
import 'package:unopos/core/theming/theme_resolution.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/settings/data/settings_repository_drift.dart';
import 'package:unopos/features/settings/domain/settings_models.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeLocalStore.lastEffective = null;
  });

  group('settings record', () {
    test("older apps' Light/Dark count as a choice, their default 'system' as Automatic", () {
      expect(const AppSettingsRecord(storeId: 's', themeMode: AppThemeMode.dark).themeChoice, 'dark');
      expect(const AppSettingsRecord(storeId: 's', themeMode: AppThemeMode.light).themeChoice, 'light');
      expect(const AppSettingsRecord(storeId: 's').themeChoice, isNull);
      expect(const AppSettingsRecord(storeId: 's', themeKey: 'nowruz').themeChoice, 'nowruz');
    });

    test('choosing a theme keeps theme_mode right for older apps', () {
      const base = AppSettingsRecord(storeId: 's');
      final halloween = base.withThemeChoice('halloween', darkTheme: true);
      expect(halloween.themeKey, 'halloween');
      expect(halloween.themeMode, AppThemeMode.dark);
      final summer = halloween.withThemeChoice('summer', darkTheme: false);
      expect(summer.themeMode, AppThemeMode.light);
      final auto = summer.withThemeChoice(null, darkTheme: false);
      expect(auto.themeKey, isNull);
      expect(auto.themeMode, AppThemeMode.system);
      expect(auto.themeChoice, isNull);
    });

    test('the local database keeps the choice (in its theme_mode column)', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftSettingsRepository(db);
      await repo.ensureSettings('store-1');
      final s = await repo.ensureSettings('store-1');
      // A store from before themes followed the device.
      expect(s.themeChoice, kFollowDeviceThemeChoice);

      await repo.updateSettings(s.withThemeChoice('ramadan', darkTheme: true));
      var read = await repo.ensureSettings('store-1');
      expect(read.themeKey, 'ramadan');
      expect(read.themeMode, AppThemeMode.dark);

      await repo.updateSettings(read.withThemeChoice(null, darkTheme: false));
      read = await repo.ensureSettings('store-1');
      expect(read.themeKey, isNull);
      expect(read.themeChoice, isNull);
    });
  });

  group('device memory', () {
    test('the theme in effect and the synced assignments survive a restart', () async {
      await ThemeLocalStore.saveEffective(const ResolvedTheme(StoreThemeKey.winter, ThemeSource.store));
      final synced = DateTime.utc(2026, 10, 1, 9);
      await ThemeLocalStore.saveSync(
        'store-1',
        ThemeSyncSnapshot(
          globalAssignment: const ThemeAssignment(scope: 'global', key: StoreThemeKey.christmas, locked: true),
          syncedAt: synced,
        ),
      );

      // "Restart": forget the in-memory copy and read again.
      ThemeLocalStore.lastEffective = null;
      await ThemeLocalStore.preload();
      expect(ResolvedTheme.fromStorage(ThemeLocalStore.lastEffective).key, StoreThemeKey.winter);

      final snapshot = await ThemeLocalStore.loadSync('store-1');
      expect(snapshot!.globalAssignment!.key, StoreThemeKey.christmas);
      expect(snapshot.globalAssignment!.locked, isTrue);
      expect(snapshot.storeAssignment, isNull);
      expect(snapshot.syncedAt, synced);
    });

    test('a damaged saved value falls back to Light', () {
      expect(ResolvedTheme.fromStorage('neon'), ResolvedTheme.defaultTheme);
      expect(ResolvedTheme.fromStorage(null), ResolvedTheme.defaultTheme);
      expect(ResolvedTheme.fromStorage('system').followsDevice, isTrue);
    });
  });

  group('controller (offline, local build)', () {
    late AppDatabase db;
    late ProviderContainer container;
    late String storeId;

    Future<void> start({Map<String, Object> prefs = const {}}) async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      final store = await container
          .read(authRepositoryProvider)
          .createStore(storeLoginId: 'shop', password: 'pw123456', displayName: 'Shop');
      storeId = store.id;
      await container.read(settingsRepositoryProvider).ensureSettings(storeId);
      SharedPreferences.setMockInitialValues(
          {for (final e in prefs.entries) e.key.replaceAll('<store>', storeId): e.value});
      container.read(sessionControllerProvider.notifier).setStore(store);
      container.listen(storeThemeControllerProvider, (_, __) {});
      for (var i = 0; i < 6; i++) {
        await settle();
      }
    }

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test("applies the store's choice at once and remembers it", () async {
      await start();
      final settings = await container.read(settingsRepositoryProvider).ensureSettings(storeId);
      await container
          .read(settingsRepositoryProvider)
          .updateSettings(settings.withThemeChoice('ramadan', darkTheme: true));
      for (var i = 0; i < 4; i++) {
        await settle();
      }
      final state = container.read(storeThemeControllerProvider);
      expect(state.resolved, const ResolvedTheme(StoreThemeKey.ramadan, ThemeSource.store));
      expect(state.theme.colorScheme.primary, ThemePalettes.ramadan.primary);
      expect((await SharedPreferences.getInstance()).getString('theme.v1.effective'), 'ramadan');
    });

    test('a locked developer theme synced earlier still applies offline', () async {
      await start(prefs: {
        'theme.v1.sync.<store>': jsonEncode(ThemeSyncSnapshot(
          globalAssignment: const ThemeAssignment(scope: 'global', key: StoreThemeKey.eidAlFitr, locked: true),
          syncedAt: DateTime.utc(2026, 10, 1),
        ).toJson()),
      });
      final controller = container.read(storeThemeControllerProvider.notifier);
      controller.setStoreChoice('halloween');
      final state = container.read(storeThemeControllerProvider);
      expect(state.resolved, const ResolvedTheme(StoreThemeKey.eidAlFitr, ThemeSource.developerLocked));
      expect(state.lockedByDeveloper, isTrue);
      expect(state.lastSyncedAt, DateTime.utc(2026, 10, 1));
    });

    test('following the device uses Light and Dark', () async {
      await start();
      container.read(storeThemeControllerProvider.notifier).setStoreChoice(kFollowDeviceThemeChoice);
      final state = container.read(storeThemeControllerProvider);
      expect(state.themeMode.name, 'system');
      expect(state.theme.brightness.name, 'light');
      expect(state.darkTheme.brightness.name, 'dark');
    });
  });
}
