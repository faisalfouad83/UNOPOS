import 'store_themes.dart';

/// The store's own choice that means "Light or Dark, following the
/// device's light/dark setting" — what UNOPOS did before there were
/// themes. Kept in `app_settings.theme_key` like a theme key.
const String kFollowDeviceThemeChoice = 'system';

/// A theme set by the developer, for every store ([globalScope]) or for one
/// store (scope = that store's id). Kept on the server in
/// `theme_assignments`.
class ThemeAssignment {
  const ThemeAssignment({
    required this.scope,
    required this.key,
    this.locked = false,
    this.updatedAt,
    this.updatedBy,
  });

  static const String globalScope = 'global';

  /// 'global' or a store id.
  final String scope;
  final StoreThemeKey key;

  /// When true the store cannot choose another theme.
  final bool locked;
  final DateTime? updatedAt;
  final String? updatedBy;

  bool get isGlobal => scope == globalScope;

  /// Null when the row's theme is unknown to this app version — the row is
  /// then ignored, as if there were no assignment.
  static ThemeAssignment? fromRow(Map<String, dynamic> row) {
    final key = StoreThemeKey.fromDb(row['theme_key'] as String?);
    final scope = row['scope'] as String?;
    if (key == null || scope == null || scope.isEmpty) return null;
    return ThemeAssignment(
      scope: scope,
      key: key,
      locked: row['locked'] as bool? ?? false,
      updatedAt: DateTime.tryParse('${row['updated_at'] ?? ''}'),
      updatedBy: row['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'scope': scope,
        'theme_key': key.dbKey,
        'locked': locked,
        'updated_at': updatedAt?.toIso8601String(),
        'updated_by': updatedBy,
      };

  @override
  bool operator ==(Object other) =>
      other is ThemeAssignment &&
      other.scope == scope &&
      other.key == key &&
      other.locked == locked &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(scope, key, locked, updatedAt);
}

/// Where the theme in effect came from.
enum ThemeSource {
  /// The developer's assignment for this store (or, without one, the global
  /// assignment) is locked: the store's own choice is set aside.
  developerLocked,

  /// The store's own choice in Settings.
  store,

  /// The developer's assignment for this store.
  developerStore,

  /// The developer's assignment for all stores.
  developerGlobal,

  /// Nothing chosen anywhere: Light.
  defaultTheme,
}

/// The theme in effect. [key] is null when it follows the device's light/dark
/// setting (Light or Dark).
class ResolvedTheme {
  const ResolvedTheme(this.key, this.source);

  final StoreThemeKey? key;
  final ThemeSource source;

  bool get followsDevice => key == null;

  /// What is saved on the device and offered at the next launch: a theme
  /// key, or [kFollowDeviceThemeChoice].
  String get storageValue => key?.dbKey ?? kFollowDeviceThemeChoice;

  static ResolvedTheme fromStorage(String? value) {
    if (value == kFollowDeviceThemeChoice) return const ResolvedTheme(null, ThemeSource.store);
    final key = StoreThemeKey.fromDb(value);
    return key == null ? defaultTheme : ResolvedTheme(key, ThemeSource.store);
  }

  static const defaultTheme = ResolvedTheme(StoreThemeKey.light, ThemeSource.defaultTheme);

  @override
  bool operator ==(Object other) => other is ResolvedTheme && other.key == key && other.source == source;

  @override
  int get hashCode => Object.hash(key, source);

  @override
  String toString() => 'ResolvedTheme(${key?.dbKey ?? 'device'}, ${source.name})';
}

/// The developer assignment that applies to a store: its own one when the
/// developer set one, otherwise the global one.
ThemeAssignment? effectiveDeveloperAssignment(ThemeAssignment? storeAssignment, ThemeAssignment? globalAssignment) =>
    storeAssignment ?? globalAssignment;

/// Works out which theme a store shows. Precedence, highest first:
///
/// 1. A **locked** developer assignment. The assignment that counts is the
///    store's own when the developer set one, otherwise the global one — so
///    a store-specific, unlocked assignment is the developer's deliberate
///    exception to a locked global theme.
/// 2. The store's own choice in Settings ([storeChoice]: a theme key, or
///    [kFollowDeviceThemeChoice] for Light/Dark following the device).
/// 3. The developer's (unlocked) assignment: the store's own, then the
///    global one.
/// 4. Light.
///
/// [storeChoice] null or empty means the store left it on "Automatic". A
/// key this app version doesn't know is treated the same way.
ResolvedTheme resolveStoreTheme({
  ThemeAssignment? storeAssignment,
  ThemeAssignment? globalAssignment,
  String? storeChoice,
}) {
  final developer = effectiveDeveloperAssignment(storeAssignment, globalAssignment);
  if (developer != null && developer.locked) return ResolvedTheme(developer.key, ThemeSource.developerLocked);

  if (storeChoice == kFollowDeviceThemeChoice) return const ResolvedTheme(null, ThemeSource.store);
  final chosen = StoreThemeKey.fromDb(storeChoice);
  if (chosen != null) return ResolvedTheme(chosen, ThemeSource.store);

  if (storeAssignment != null) return ResolvedTheme(storeAssignment.key, ThemeSource.developerStore);
  if (globalAssignment != null) return ResolvedTheme(globalAssignment.key, ThemeSource.developerGlobal);
  return ResolvedTheme.defaultTheme;
}
