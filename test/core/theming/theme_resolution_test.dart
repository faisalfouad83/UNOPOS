import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/theming/store_themes.dart';
import 'package:unopos/core/theming/theme_resolution.dart';

ThemeAssignment global(StoreThemeKey key, {bool locked = false}) =>
    ThemeAssignment(scope: ThemeAssignment.globalScope, key: key, locked: locked);

ThemeAssignment store(StoreThemeKey key, {bool locked = false}) =>
    ThemeAssignment(scope: 'store-1', key: key, locked: locked);

void main() {
  test('nothing set anywhere: Light', () {
    expect(resolveStoreTheme(), const ResolvedTheme(StoreThemeKey.light, ThemeSource.defaultTheme));
  });

  test("the store's own choice", () {
    expect(resolveStoreTheme(storeChoice: 'ramadan'), const ResolvedTheme(StoreThemeKey.ramadan, ThemeSource.store));
  });

  test("'system' follows the device (Light or Dark)", () {
    final r = resolveStoreTheme(storeChoice: kFollowDeviceThemeChoice);
    expect(r.followsDevice, isTrue);
    expect(r.source, ThemeSource.store);
  });

  test('an unknown key counts as Automatic', () {
    expect(resolveStoreTheme(storeChoice: 'neon', globalAssignment: global(StoreThemeKey.winter)),
        const ResolvedTheme(StoreThemeKey.winter, ThemeSource.developerGlobal));
  });

  test("an unlocked developer assignment applies only when the store hasn't chosen", () {
    expect(resolveStoreTheme(globalAssignment: global(StoreThemeKey.summer)),
        const ResolvedTheme(StoreThemeKey.summer, ThemeSource.developerGlobal));
    expect(resolveStoreTheme(globalAssignment: global(StoreThemeKey.summer), storeChoice: 'dark'),
        const ResolvedTheme(StoreThemeKey.dark, ThemeSource.store));
  });

  test('a store assignment beats the global one', () {
    expect(
      resolveStoreTheme(storeAssignment: store(StoreThemeKey.nowruz), globalAssignment: global(StoreThemeKey.summer)),
      const ResolvedTheme(StoreThemeKey.nowruz, ThemeSource.developerStore),
    );
  });

  test("a locked assignment beats the store's choice", () {
    expect(
      resolveStoreTheme(storeAssignment: store(StoreThemeKey.eidAlFitr, locked: true), storeChoice: 'halloween'),
      const ResolvedTheme(StoreThemeKey.eidAlFitr, ThemeSource.developerLocked),
    );
    expect(
      resolveStoreTheme(globalAssignment: global(StoreThemeKey.christmas, locked: true), storeChoice: 'system'),
      const ResolvedTheme(StoreThemeKey.christmas, ThemeSource.developerLocked),
    );
  });

  test('an unlocked store assignment is the exception to a locked global theme', () {
    // The store's own assignment is the one that counts, and it isn't
    // locked: the store's choice wins, else that assignment.
    expect(
      resolveStoreTheme(
        storeAssignment: store(StoreThemeKey.autumn),
        globalAssignment: global(StoreThemeKey.christmas, locked: true),
        storeChoice: 'spring',
      ),
      const ResolvedTheme(StoreThemeKey.spring, ThemeSource.store),
    );
    expect(
      resolveStoreTheme(
        storeAssignment: store(StoreThemeKey.autumn),
        globalAssignment: global(StoreThemeKey.christmas, locked: true),
      ),
      const ResolvedTheme(StoreThemeKey.autumn, ThemeSource.developerStore),
    );
  });

  test('a locked store assignment beats an unlocked global one and the choice', () {
    expect(
      resolveStoreTheme(
        storeAssignment: store(StoreThemeKey.winter, locked: true),
        globalAssignment: global(StoreThemeKey.summer),
        storeChoice: 'light',
      ),
      const ResolvedTheme(StoreThemeKey.winter, ThemeSource.developerLocked),
    );
  });

  test('assignment rows with an unknown theme are ignored', () {
    expect(ThemeAssignment.fromRow({'scope': 'global', 'theme_key': 'neon'}), isNull);
    final a = ThemeAssignment.fromRow({
      'scope': 'store-1',
      'theme_key': 'eid_al_adha',
      'locked': true,
      'updated_at': '2026-10-01T10:00:00Z',
    })!;
    expect(a.key, StoreThemeKey.eidAlAdha);
    expect(a.locked, isTrue);
    expect(a.isGlobal, isFalse);
    expect(ThemeAssignment.fromRow(a.toJson()), a);
  });

  test('every theme key round-trips through its server key', () {
    for (final k in StoreThemeKey.values) {
      expect(StoreThemeKey.fromDb(k.dbKey), k);
    }
    expect(StoreThemeKey.values, hasLength(12));
  });
}
