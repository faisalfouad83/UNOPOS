import 'package:flutter/material.dart';

import 'store_themes.dart';

/// UNOPOS's visual identity, in twelve colourways (see [StoreThemeKey] and
/// store_themes.dart). Every theme shares the same shapes and type —
/// heavily rounded/pill, bundled Noto Sans with Noto Sans Arabic as the
/// fallback for Arabic and Kurdish — and the same "glass" look: transparent
/// screens over [GlassBackground], translucent cards, nearly solid popups.
/// Only the colour tokens differ. Light and Dark are the original look,
/// recoloured to the UNOPOS logo (a navy tile, a blue-to-cyan "U" and a
/// brushed-silver "N").
class AppTheme {
  const AppTheme._();

  // Built once per theme: rebuilding ThemeData on every app rebuild forces
  // the whole widget tree to restyle.
  static final Map<StoreThemeKey, ThemeData> _built = {};

  static ThemeData light() => forKey(StoreThemeKey.light);
  static ThemeData dark() => forKey(StoreThemeKey.dark);

  /// The ThemeData of one of the twelve store themes.
  static ThemeData forKey(StoreThemeKey key) => _built[key] ??= _base(key.palette);

  /// Bundled fonts (assets/fonts): Noto Sans for Latin with Noto Sans Arabic
  /// as the fallback, so English and Arabic share one look and nothing is
  /// fetched from the internet at runtime.
  static const String bodyFamily = 'UnoSans';
  static const List<String> fallbackFamilies = ['UnoArabic'];

  static ColorScheme _scheme(ThemePalette p) {
    final base = ColorScheme.fromSeed(seedColor: p.primary, brightness: p.brightness);
    return base.copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      secondaryContainer: p.secondaryContainer,
      onSecondaryContainer: p.onSecondaryContainer,
      tertiary: p.tertiary,
      onTertiary: p.onTertiary,
      error: p.error,
      onError: p.onError,
      errorContainer: p.errorContainer,
      onErrorContainer: p.onErrorContainer,
      surface: p.surface,
      onSurface: p.onSurface,
      onSurfaceVariant: p.onSurfaceVariant,
    );
  }

  /// Translucent "glass" fills for cards and panels over [GlassBackground].
  static Color glassFill(Brightness b) => (b == Brightness.dark ? ThemePalettes.dark : ThemePalettes.light).glassFill;
  static Color glassBorder(Brightness b) =>
      _glassBorder(b == Brightness.dark ? ThemePalettes.dark : ThemePalettes.light);

  static Color _glassBorder(ThemePalette p) =>
      p.isDark ? Colors.white.withValues(alpha: 0.14) : p.onSurface.withValues(alpha: 0.10);

  /// The fill layers above a card (chips, raised panels): a little more of
  /// the glass colour, lifted towards white in dark themes.
  static ColorScheme _glassScheme(ColorScheme s, ThemePalette p) {
    final fill = p.glassFill;
    final dark = p.isDark;
    final lifted = dark ? Color.lerp(p.glass, Colors.white, 0.08)! : Colors.white;
    return s.copyWith(
      surfaceContainerLowest: fill,
      surfaceContainerLow: fill,
      surfaceContainer: lifted.withValues(alpha: dark ? 0.6 : 0.7),
      surfaceContainerHigh:
          (dark ? Color.lerp(p.glass, Colors.white, 0.14)! : Colors.white).withValues(alpha: dark ? 0.7 : 0.78),
      outlineVariant: dark ? _glassBorder(p) : p.onSurface.withValues(alpha: 0.14),
    );
  }

  static ThemeData _base(ThemePalette palette) {
    final scheme = _glassScheme(_scheme(palette), palette);
    final glassSide = BorderSide(color: _glassBorder(palette), width: 1);
    final popupShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: glassSide);
    final base = (scheme.brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final baseTextTheme = base.apply(
      fontFamily: bodyFamily,
      fontFamilyFallback: fallbackFamilies,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    const headingFamily = bodyFamily;

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge
          ?.copyWith(fontFamily: headingFamily, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.6),
      headlineMedium: baseTextTheme.headlineMedium
          ?.copyWith(fontFamily: headingFamily, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.45),
      headlineSmall: baseTextTheme.headlineSmall
          ?.copyWith(fontFamily: headingFamily, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleLarge:
          baseTextTheme.titleLarge?.copyWith(fontFamily: headingFamily, fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium:
          baseTextTheme.titleMedium?.copyWith(fontFamily: headingFamily, fontSize: 17, fontWeight: FontWeight.w700),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    // .btn { font-family: var(--font-heading) } — button labels use the
    // display font, not the body font, per the token sheet.
    const buttonTextStyle = TextStyle(
        fontFamily: headingFamily, fontFamilyFallback: fallbackFamilies, fontWeight: FontWeight.w700, fontSize: 14);
    const pillShape = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      fontFamily: bodyFamily,
      fontFamilyFallback: fallbackFamilies,
      // A short fade instead of the default zoom keeps moving between
      // sections snappy on desktop tills.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: scheme,
      extensions: [StatusColors.fromPalette(palette), ThemeDecor.fromPalette(palette)],
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: palette.popupFill,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      // No elevation: a shadow under a translucent card shows through it as
      // a dark frame. The glass reads from the fill and the light edge.
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: palette.glassFill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: glassSide),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.popupFill,
        surfaceTintColor: Colors.transparent,
        shape: popupShape,
        elevation: 24,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.popupFill,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: glassSide),
        elevation: 12,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.popupFill,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: palette.popupFill),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(palette.popupFill)),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: pillShape,
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: pillShape,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: pillShape,
          textStyle: buttonTextStyle,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        side: BorderSide.none,
        shape: pillShape,
        labelStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.glassFill,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
        indicatorColor: scheme.primaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.glassFill,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        height: 68,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.onSurface,
        contentTextStyle:
            TextStyle(color: palette.surface, fontFamily: bodyFamily, fontFamilyFallback: fallbackFamilies),
        actionTextColor: palette.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Brand colors exposed for the handful of places that need to reach past
/// the semantic ColorScheme roles for a deliberate accent (filled tiles with
/// their own label colour) — everything else should use
/// Theme.of(context).colorScheme, not these directly.
class BrandColors {
  const BrandColors._();
  static const Color blue = Color(0xFF0079E4);
  static const Color silver = Color(0xFF566371);
  static const Color red = Color(0xFFE5484D);
  static const Color paper = Color(0xFFF6F8FA);
  static const Color ink = Color(0xFF0B1220);
}

/// Breakpoint helper — POS terminals span phones, tablets, and desktop
/// windows, so most screens branch layout on width rather than platform.
class AppBreakpoints {
  const AppBreakpoints._();
  static const double compact = 600;
  static const double medium = 1024;

  static bool isCompact(double width) => width < compact;
  static bool isExpanded(double width) => width >= medium;
}
