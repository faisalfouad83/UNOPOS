import 'package:flutter/material.dart';

/// The looks a store can wear. [dbKey] is the value the server keeps
/// (`theme_assignments.theme_key`, `app_settings.theme_key`); the list must
/// stay in step with the check constraints in
/// `supabase/migrations/0030_store_themes.sql` and
/// `supabase/migrations/0033_occasion_themes.sql`.
enum StoreThemeKey {
  light('light'),
  dark('dark'),
  christmas('christmas'),
  halloween('halloween'),
  eidAlFitr('eid_al_fitr'),
  eidAlAdha('eid_al_adha'),
  nowruz('nowruz'),
  ramadan('ramadan'),
  summer('summer'),
  autumn('autumn'),
  spring('spring'),
  winter('winter'),
  muharram('muharram'),
  iraqiArmyDay('iraqi_army_day'),
  iraqiPoliceDay('iraqi_police_day'),
  iraqiSovereigntyDay('iraqi_sovereignty_day'),
  mawlid('mawlid');

  const StoreThemeKey(this.dbKey);

  final String dbKey;

  /// The theme with this server key, or null for an unknown or empty key
  /// (for example one added by a newer app version).
  static StoreThemeKey? fromDb(String? key) => values.where((k) => k.dbKey == key).firstOrNull;

  ThemePalette get palette => ThemePalettes.of(this);
}

/// The faint picture drawn in the corners of the backdrop. Static (painted
/// once, no animation) so it costs nothing while the till is in use.
enum ThemeMotif { none, star, moon, crescent, geometric, petal, sun, leaf, snowflake }

/// Every colour a theme is made from. Text colours were chosen against the
/// backdrop, the translucent cards over it and the popups, and are checked
/// for WCAG AA contrast (4.5:1) by test/core/theming/theme_contrast_test.dart.
class ThemePalette {
  const ThemePalette({
    required this.brightness,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.popup,
    required this.glass,
    required this.glassAlpha,
    required this.gradient,
    required this.glows,
    required this.motif,
  });

  final Brightness brightness;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  /// "Paid", "online", "balanced" — kept a clearly different hue from
  /// [error] in every theme.
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  /// "Partly paid", "pending sync", "low stock".
  final Color warning;
  final Color onWarning;

  /// Dialogs, menus and sheets (drawn nearly solid).
  final Color popup;

  /// Cards and panels: this colour at [glassAlpha] over the backdrop.
  final Color glass;
  final double glassAlpha;

  /// The backdrop: a diagonal gradient (three stops) with soft [glows].
  final List<Color> gradient;
  final List<Color> glows;
  final ThemeMotif motif;

  bool get isDark => brightness == Brightness.dark;
  Color get glassFill => glass.withValues(alpha: glassAlpha);
  Color get popupFill => popup.withValues(alpha: isDark ? 0.97 : 0.98);
}

/// Success and warning colours of the current theme, for the status texts
/// and badges that Material's ColorScheme has no role for.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;

  factory StatusColors.fromPalette(ThemePalette p) => StatusColors(
        success: p.success,
        onSuccess: p.onSuccess,
        successContainer: p.successContainer,
        onSuccessContainer: p.onSuccessContainer,
        warning: p.warning,
        onWarning: p.onWarning,
      );

  /// The current theme's status colours (the Light theme's when a test
  /// builds a bare ThemeData without them).
  static StatusColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<StatusColors>() ??
        StatusColors.fromPalette(theme.brightness == Brightness.dark ? ThemePalettes.dark : ThemePalettes.light);
  }

  @override
  StatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
  }) =>
      StatusColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        successContainer: successContainer ?? this.successContainer,
        onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
      );

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}

/// What [GlassBackground] paints behind the screens for the current theme.
@immutable
class ThemeDecor extends ThemeExtension<ThemeDecor> {
  const ThemeDecor({required this.gradient, required this.glows, required this.motif, required this.dark});

  final List<Color> gradient;
  final List<Color> glows;
  final ThemeMotif motif;
  final bool dark;

  factory ThemeDecor.fromPalette(ThemePalette p) =>
      ThemeDecor(gradient: p.gradient, glows: p.glows, motif: p.motif, dark: p.isDark);

  @override
  ThemeDecor copyWith({List<Color>? gradient, List<Color>? glows, ThemeMotif? motif, bool? dark}) => ThemeDecor(
        gradient: gradient ?? this.gradient,
        glows: glows ?? this.glows,
        motif: motif ?? this.motif,
        dark: dark ?? this.dark,
      );

  // Themes switch instantly; there's nothing worth animating between two
  // backdrops.
  @override
  ThemeDecor lerp(ThemeExtension<ThemeDecor>? other, double t) => t < 0.5 || other is! ThemeDecor ? this : other;
}

/// The colour sheets of the themes. Light and Dark are the original
/// UNOPOS look (navy/blue/silver), with the primary and error tones
/// deepened just enough to reach AA contrast for button labels and text.
class ThemePalettes {
  const ThemePalettes._();

  static ThemePalette of(StoreThemeKey key) => switch (key) {
        StoreThemeKey.light => light,
        StoreThemeKey.dark => dark,
        StoreThemeKey.christmas => christmas,
        StoreThemeKey.halloween => halloween,
        StoreThemeKey.eidAlFitr => eidAlFitr,
        StoreThemeKey.eidAlAdha => eidAlAdha,
        StoreThemeKey.nowruz => nowruz,
        StoreThemeKey.ramadan => ramadan,
        StoreThemeKey.summer => summer,
        StoreThemeKey.autumn => autumn,
        StoreThemeKey.spring => spring,
        StoreThemeKey.winter => winter,
        StoreThemeKey.muharram => muharram,
        StoreThemeKey.iraqiArmyDay => iraqiArmyDay,
        StoreThemeKey.iraqiPoliceDay => iraqiPoliceDay,
        StoreThemeKey.iraqiSovereigntyDay => iraqiSovereigntyDay,
        StoreThemeKey.mawlid => mawlid,
      };

  static const light = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFF6F8FA),
    onSurface: Color(0xFF0B1220),
    onSurfaceVariant: Color(0xFF3E5468),
    primary: Color(0xFF0067C7),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFB8E5FB),
    onPrimaryContainer: Color(0xFF065277),
    secondary: Color(0xFF566371),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD8DCE1),
    onSecondaryContainer: Color(0xFF414B56),
    tertiary: Color(0xFF566371),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFE1E2),
    onErrorContainer: Color(0xFF641623),
    success: Color(0xFF18703A),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD5F2DD),
    onSuccessContainer: Color(0xFF0D4A22),
    warning: Color(0xFFA84B00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFF7FAFF),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.62,
    gradient: [Color(0xFFEAF1FF), Color(0xFFF6F9FF), Color(0xFFE3EEFF)],
    glows: [Color(0xFF1677FF), Color(0xFF00C2FF), Color(0xFF7C4DFF)],
    motif: ThemeMotif.none,
  );

  static const dark = ThemePalette(
    brightness: Brightness.dark,
    surface: Color(0xFF05080D),
    onSurface: Color(0xFFEDF1F5),
    onSurfaceVariant: Color(0xFFAABED1),
    primary: Color(0xFF00CFFD),
    onPrimary: Color(0xFF05080D),
    primaryContainer: Color(0xFF065277),
    onPrimaryContainer: Color(0xFFB8E5FB),
    secondary: Color(0xFFA1ACB8),
    onSecondary: Color(0xFF05080D),
    secondaryContainer: Color(0xFF414B56),
    onSecondaryContainer: Color(0xFFD8DCE1),
    tertiary: Color(0xFFA1ACB8),
    onTertiary: Color(0xFF05080D),
    error: Color(0xFFFF6369),
    onError: Color(0xFF3B0A0C),
    errorContainer: Color(0xFF5C161A),
    onErrorContainer: Color(0xFFFFD9DA),
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
    successContainer: Color(0xFF14532D),
    onSuccessContainer: Color(0xFFD1FAE5),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF3A2000),
    popup: Color(0xFF14213D),
    glass: Color(0xFF1B2B4D),
    glassAlpha: 0.55,
    gradient: [Color(0xFF070D1A), Color(0xFF0D1B38), Color(0xFF081226)],
    glows: [Color(0xFF1677FF), Color(0xFF00C2FF), Color(0xFF7C4DFF)],
    motif: ThemeMotif.none,
  );

  static const christmas = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFFBF8F3),
    onSurface: Color(0xFF1F1A17),
    onSurfaceVariant: Color(0xFF5A4F47),
    primary: Color(0xFF1B5E3B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDEBD8),
    onPrimaryContainer: Color(0xFF0B3820),
    secondary: Color(0xFF8C2131),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF6D9DD),
    onSecondaryContainer: Color(0xFF5A1220),
    tertiary: Color(0xFF7A5A00),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFFFCF8),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.66,
    gradient: [Color(0xFFF7EFE6), Color(0xFFFCF9F4), Color(0xFFEEF4EE)],
    glows: [Color(0xFFC62828), Color(0xFF2E7D32), Color(0xFFD4A017)],
    motif: ThemeMotif.star,
  );

  static const halloween = ThemePalette(
    brightness: Brightness.dark,
    surface: Color(0xFF100A16),
    onSurface: Color(0xFFF4EDE4),
    onSurfaceVariant: Color(0xFFC9B8A8),
    primary: Color(0xFFFF8A1F),
    onPrimary: Color(0xFF1F0E00),
    primaryContainer: Color(0xFF5A2D00),
    onPrimaryContainer: Color(0xFFFFDCC0),
    secondary: Color(0xFFC59CFF),
    onSecondary: Color(0xFF22103A),
    secondaryContainer: Color(0xFF3F2466),
    onSecondaryContainer: Color(0xFFEBDDFF),
    tertiary: Color(0xFF9CD67A),
    onTertiary: Color(0xFF102200),
    error: Color(0xFFFF6B81),
    onError: Color(0xFF3A0010),
    errorContainer: Color(0xFF6B1426),
    onErrorContainer: Color(0xFFFFD9DF),
    success: Color(0xFF7EE08A),
    onSuccess: Color(0xFF0A2E10),
    successContainer: Color(0xFF1E4D26),
    onSuccessContainer: Color(0xFFD4F7D8),
    warning: Color(0xFFFFD166),
    onWarning: Color(0xFF2E2000),
    popup: Color(0xFF1E1229),
    glass: Color(0xFF2A1838),
    glassAlpha: 0.58,
    gradient: [Color(0xFF140B1C), Color(0xFF1D1028), Color(0xFF120A18)],
    glows: [Color(0xFFFF8A1F), Color(0xFF7C3AED), Color(0xFF9CD67A)],
    motif: ThemeMotif.moon,
  );

  static const eidAlFitr = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFF6FBF8),
    onSurface: Color(0xFF0E1F1A),
    onSurfaceVariant: Color(0xFF3D5A51),
    primary: Color(0xFF00695C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFB9EDE3),
    onPrimaryContainer: Color(0xFF00382F),
    secondary: Color(0xFF7A5C12),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF3E6C2),
    onSecondaryContainer: Color(0xFF3D2E00),
    tertiary: Color(0xFF5B4B8A),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFBFEFC),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFEAF6F0), Color(0xFFF8FCFA), Color(0xFFF3F0E2)],
    glows: [Color(0xFF00A389), Color(0xFFD4AF37), Color(0xFF7FD8C3)],
    motif: ThemeMotif.crescent,
  );

  static const eidAlAdha = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFFAF7F1),
    onSurface: Color(0xFF1A1712),
    onSurfaceVariant: Color(0xFF574E40),
    primary: Color(0xFF2C3E91),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE1FA),
    onPrimaryContainer: Color(0xFF14205A),
    secondary: Color(0xFF8A5A12),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF5E3C4),
    onSecondaryContainer: Color(0xFF452B00),
    tertiary: Color(0xFF00695C),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFDFBF7),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFF3ECDD), Color(0xFFFBF8F2), Color(0xFFE9EDF7)],
    glows: [Color(0xFF3F51B5), Color(0xFFD4A54A), Color(0xFF7FC8B8)],
    motif: ThemeMotif.geometric,
  );

  static const nowruz = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFF7FBF3),
    onSurface: Color(0xFF14200F),
    onSurfaceVariant: Color(0xFF49573F),
    primary: Color(0xFF3A6E1E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD3EFC2),
    onPrimaryContainer: Color(0xFF1A3A08),
    secondary: Color(0xFF8E3B8A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF6D8F3),
    onSecondaryContainer: Color(0xFF4A0F47),
    tertiary: Color(0xFF8F5400),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF00796B),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFC8EFE9),
    onSuccessContainer: Color(0xFF003D36),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFBFDF8),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFEEF7E4), Color(0xFFFAFDF6), Color(0xFFFCEFF1)],
    glows: [Color(0xFF6CBF43), Color(0xFFE86A92), Color(0xFFF2B33D)],
    motif: ThemeMotif.petal,
  );

  static const ramadan = ThemePalette(
    brightness: Brightness.dark,
    surface: Color(0xFF0A0F24),
    onSurface: Color(0xFFF2EEE3),
    onSurfaceVariant: Color(0xFFBFC3D6),
    primary: Color(0xFFF2C14E),
    onPrimary: Color(0xFF2A1E00),
    primaryContainer: Color(0xFF5A4300),
    onPrimaryContainer: Color(0xFFFFE7A8),
    secondary: Color(0xFF7FD1C7),
    onSecondary: Color(0xFF00302B),
    secondaryContainer: Color(0xFF0F4A44),
    onSecondaryContainer: Color(0xFFC6F1EA),
    tertiary: Color(0xFFC6A6FF),
    onTertiary: Color(0xFF25124A),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF3B0A0A),
    errorContainer: Color(0xFF6B1A1A),
    onErrorContainer: Color(0xFFFFDAD6),
    success: Color(0xFF6EE7A8),
    onSuccess: Color(0xFF00391F),
    successContainer: Color(0xFF0F4D30),
    onSuccessContainer: Color(0xFFCFF7E2),
    warning: Color(0xFFFFB86B),
    onWarning: Color(0xFF3A1F00),
    popup: Color(0xFF141C40),
    glass: Color(0xFF1B2550),
    glassAlpha: 0.58,
    gradient: [Color(0xFF0B1230), Color(0xFF121A3F), Color(0xFF0A1028)],
    glows: [Color(0xFFF2C14E), Color(0xFF3B5BDB), Color(0xFF7FD1C7)],
    motif: ThemeMotif.crescent,
  );

  static const summer = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFFFFAF2),
    onSurface: Color(0xFF1F160C),
    onSurfaceVariant: Color(0xFF5C4A36),
    primary: Color(0xFF00727A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC4EEF1),
    onPrimaryContainer: Color(0xFF00363A),
    secondary: Color(0xFFB0450C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDCC7),
    onSecondaryContainer: Color(0xFF5A1F00),
    tertiary: Color(0xFF7F6200),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFFFCF7),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFFFF1DC), Color(0xFFFFFAF3), Color(0xFFE3F6F7)],
    glows: [Color(0xFFFFB300), Color(0xFFFF7043), Color(0xFF26C6DA)],
    motif: ThemeMotif.sun,
  );

  static const autumn = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFFBF6EF),
    onSurface: Color(0xFF22170F),
    onSurfaceVariant: Color(0xFF5E4B3B),
    primary: Color(0xFF7A4A1E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF4DFC8),
    onPrimaryContainer: Color(0xFF3D2006),
    secondary: Color(0xFF55641C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE3EBC2),
    onSecondaryContainer: Color(0xFF2B3500),
    tertiary: Color(0xFF9A4016),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFF9C5700),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFDFAF5),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFF6EADB), Color(0xFFFCF8F2), Color(0xFFF1EBDD)],
    glows: [Color(0xFFD2691E), Color(0xFFB8860B), Color(0xFF8B4513)],
    motif: ThemeMotif.leaf,
  );

  static const spring = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFFDF8FA),
    onSurface: Color(0xFF1E1418),
    onSurfaceVariant: Color(0xFF5A4650),
    primary: Color(0xFF9C2F65),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFD8E8),
    onPrimaryContainer: Color(0xFF4F0A30),
    secondary: Color(0xFF3F7020),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD6EEC4),
    onSecondaryContainer: Color(0xFF173A00),
    tertiary: Color(0xFF6750A4),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFFFBFC),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFFCEEF3), Color(0xFFFEFAFB), Color(0xFFEEF7E8)],
    glows: [Color(0xFFF48FB1), Color(0xFF8BC34A), Color(0xFFCE93D8)],
    motif: ThemeMotif.petal,
  );

  static const winter = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFF5F8FC),
    onSurface: Color(0xFF0E1724),
    onSurfaceVariant: Color(0xFF435468),
    primary: Color(0xFF1F6582),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC9E8F5),
    onPrimaryContainer: Color(0xFF06334A),
    secondary: Color(0xFF56647C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCE3EE),
    onSecondaryContainer: Color(0xFF28334A),
    tertiary: Color(0xFF6E54A0),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFFA14E00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFF9FBFE),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFE6EEF8), Color(0xFFF7FAFD), Color(0xFFE9F1F7)],
    glows: [Color(0xFF90CAF9), Color(0xFFB0BEC5), Color(0xFF80DEEA)],
    motif: ThemeMotif.snowflake,
  );

  /// Muharram: quiet near-black with deep green, no bright accents.
  static const muharram = ThemePalette(
    brightness: Brightness.dark,
    surface: Color(0xFF080B0A),
    onSurface: Color(0xFFECEFEC),
    onSurfaceVariant: Color(0xFFB3BDB7),
    primary: Color(0xFF66C995),
    onPrimary: Color(0xFF00210F),
    primaryContainer: Color(0xFF14452C),
    onPrimaryContainer: Color(0xFFC9F0D8),
    secondary: Color(0xFFB8BEC4),
    onSecondary: Color(0xFF101418),
    secondaryContainer: Color(0xFF33393F),
    onSecondaryContainer: Color(0xFFDDE2E7),
    tertiary: Color(0xFFD9B36A),
    onTertiary: Color(0xFF2A1D00),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF3B0A0A),
    errorContainer: Color(0xFF6B1A1A),
    onErrorContainer: Color(0xFFFFDAD6),
    success: Color(0xFF7BE0A4),
    onSuccess: Color(0xFF00391F),
    successContainer: Color(0xFF0F4D30),
    onSuccessContainer: Color(0xFFCFF7E2),
    warning: Color(0xFFFFB86B),
    onWarning: Color(0xFF3A1F00),
    popup: Color(0xFF111714),
    glass: Color(0xFF18211C),
    glassAlpha: 0.58,
    gradient: [Color(0xFF060908), Color(0xFF0C1410), Color(0xFF070A09)],
    glows: [Color(0xFF1F6B45), Color(0xFF2E3B35), Color(0xFF8C7A4A)],
    motif: ThemeMotif.geometric,
  );

  /// Iraqi Army Day (6 January): olive and khaki with the flag's red and
  /// green as accents.
  static const iraqiArmyDay = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFF7F6EF),
    onSurface: Color(0xFF1A1C14),
    onSurfaceVariant: Color(0xFF4E5340),
    primary: Color(0xFF4B5B22),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDE5BE),
    onPrimaryContainer: Color(0xFF262F0A),
    secondary: Color(0xFFA8231C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF9DAD6),
    onSecondaryContainer: Color(0xFF5C1210),
    tertiary: Color(0xFF00703C),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFF9A4A00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFCFBF6),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFEEEDDC), Color(0xFFF8F7EE), Color(0xFFE6E9D6)],
    glows: [Color(0xFF6B7F2E), Color(0xFFCE1126), Color(0xFF007A3D)],
    motif: ThemeMotif.star,
  );

  /// Iraqi Police Day (9 January): deep navy with silver and a gold badge
  /// accent.
  static const iraqiPoliceDay = ThemePalette(
    brightness: Brightness.dark,
    surface: Color(0xFF060B18),
    onSurface: Color(0xFFEEF2F8),
    onSurfaceVariant: Color(0xFFAFBCD3),
    primary: Color(0xFF7DB0FF),
    onPrimary: Color(0xFF001A40),
    primaryContainer: Color(0xFF0F3570),
    onPrimaryContainer: Color(0xFFD6E4FF),
    secondary: Color(0xFFC0C8D4),
    onSecondary: Color(0xFF0F1622),
    secondaryContainer: Color(0xFF34404F),
    onSecondaryContainer: Color(0xFFDCE3EC),
    tertiary: Color(0xFFFFD166),
    onTertiary: Color(0xFF2E2000),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF3B0A0A),
    errorContainer: Color(0xFF6B1A1A),
    onErrorContainer: Color(0xFFFFDAD6),
    success: Color(0xFF5EE09A),
    onSuccess: Color(0xFF00391F),
    successContainer: Color(0xFF0F4D30),
    onSuccessContainer: Color(0xFFCFF7E2),
    warning: Color(0xFFFFB86B),
    onWarning: Color(0xFF3A1F00),
    popup: Color(0xFF0E1A33),
    glass: Color(0xFF142447),
    glassAlpha: 0.58,
    gradient: [Color(0xFF071026), Color(0xFF0C1A3A), Color(0xFF060D20)],
    glows: [Color(0xFF2F6BFF), Color(0xFF00A3FF), Color(0xFFC0C8D4)],
    motif: ThemeMotif.star,
  );

  /// Iraqi Sovereignty Day (30 June): the flag's green, red and black on
  /// white. Buttons are green so red stays for warnings and errors.
  static const iraqiSovereigntyDay = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFFAF9F7),
    onSurface: Color(0xFF141414),
    onSurfaceVariant: Color(0xFF4A4A4A),
    primary: Color(0xFF00703C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCDEEDB),
    onPrimaryContainer: Color(0xFF00391D),
    secondary: Color(0xFFB0101F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFAD9DB),
    onSecondaryContainer: Color(0xFF5E0710),
    tertiary: Color(0xFF262626),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFF9A4A00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFFFFFF),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.66,
    gradient: [Color(0xFFFCEEEE), Color(0xFFFBFBFA), Color(0xFFEAF4EE)],
    glows: [Color(0xFFCE1126), Color(0xFF007A3D), Color(0xFF1A1A1A)],
    motif: ThemeMotif.star,
  );

  /// Mawlid al-Nabi: green and gold on a light ground.
  static const mawlid = ThemePalette(
    brightness: Brightness.light,
    surface: Color(0xFFF5FAF6),
    onSurface: Color(0xFF0F1D16),
    onSurfaceVariant: Color(0xFF3F574A),
    primary: Color(0xFF0B6B3A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC4EBD3),
    onPrimaryContainer: Color(0xFF00381B),
    secondary: Color(0xFF7A5C00),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF5E6B8),
    onSecondaryContainer: Color(0xFF3D2E00),
    tertiary: Color(0xFF1F5F7A),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF5F1412),
    success: Color(0xFF1E6E2E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7EFD9),
    onSuccessContainer: Color(0xFF12401A),
    warning: Color(0xFF9A4A00),
    onWarning: Color(0xFFFFFFFF),
    popup: Color(0xFFFBFEFC),
    glass: Color(0xFFFFFFFF),
    glassAlpha: 0.64,
    gradient: [Color(0xFFE8F5EC), Color(0xFFF8FCF9), Color(0xFFF6F0DC)],
    glows: [Color(0xFF0B8A4A), Color(0xFFD4AF37), Color(0xFF7FD8A8)],
    motif: ThemeMotif.crescent,
  );
}
