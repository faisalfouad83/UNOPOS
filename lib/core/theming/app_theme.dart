import 'package:flutter/material.dart';

/// UNOPOS's visual identity — recolored to match the UNOPOS logo (a navy
/// tile with a blue-to-cyan "U" and a brushed-silver "N"): a deep navy
/// ground, a vivid blue accent for primary actions, and a steel-silver
/// second voice, echoing the mark's own two materials. Shapes and type
/// (heavily rounded/pill, Caprasimo + Figtree) are unchanged from the prior
/// pass — only the color tokens moved. Hex values are sampled directly from
/// the logo artwork (`assets/branding/unopos_icon.png`) or generated as an
/// HSL tonal ramp around that same hue, mirroring the previous token
/// sheet's method (dark mode reuses the same nine ramp values, reversed).
class _Brand {
  const _Brand._();

  // Ground + text.
  static const Color bgLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF0B1220);
  static const Color bgDark = Color(0xFF05080D);
  static const Color surfaceDark = Color(0xFF101826);
  static const Color textDark = Color(0xFFEDF1F5);

  // Neutral tonal ramp (100 lightest step of the ramp -> 900 darkest step;
  // dark mode uses the same nine hex values remapped onto the opposite
  // steps, since the ramp is a shared perceptual scale, not two palettes).
  static const List<Color> neutralLight = [
    Color(0xFFF8F9F9),
    Color(0xFFD0DBE6),
    Color(0xFFAABED1),
    Color(0xFF83A1BC),
    Color(0xFF5D84A8),
    Color(0xFF466683),
    Color(0xFF32485C),
    Color(0xFF1D2A35),
    Color(0xFF080C0F),
  ];
  static const List<Color> neutralDark = [
    Color(0xFF080C0F),
    Color(0xFF1D2A35),
    Color(0xFF32485C),
    Color(0xFF466683),
    Color(0xFF5D84A8),
    Color(0xFF83A1BC),
    Color(0xFFAABED1),
    Color(0xFFD0DBE6),
    Color(0xFFF8F9F9),
  ];

  // Blue accent ramp (primary) — the "U" stroke's gradient.
  static const List<Color> accentLight = [
    Color(0xFFEFF5F8),
    Color(0xFFB8E5FB),
    Color(0xFF87D3F9),
    Color(0xFF56C1F6),
    Color(0xFF25AFF4),
    Color(0xFF0B95D9),
    Color(0xFF0974A8),
    Color(0xFF065277),
    Color(0xFF043046),
  ];
  static const List<Color> accentDark = [
    Color(0xFF043046),
    Color(0xFF065277),
    Color(0xFF0974A8),
    Color(0xFF0B95D9),
    Color(0xFF25AFF4),
    Color(0xFF56C1F6),
    Color(0xFF87D3F9),
    Color(0xFFB8E5FB),
    Color(0xFFEFF5F8),
  ];
  static const Color accentBaseLight = Color(0xFF0079E4);
  static const Color accentBaseDark = Color(0xFF00CFFD);

  // Steel-silver accent-2 ramp (secondary/tertiary) — the "N" stroke's
  // brushed-metal finish, "a genuine second voice" alongside the blue.
  static const List<Color> accent2Light = [
    Color(0xFFF4F5F6),
    Color(0xFFD8DCE1),
    Color(0xFFBCC4CD),
    Color(0xFFA1ACB8),
    Color(0xFF8594A3),
    Color(0xFF6A7B8D),
    Color(0xFF566371),
    Color(0xFF414B56),
    Color(0xFF2C333A),
  ];
  static const List<Color> accent2Dark = [
    Color(0xFF2C333A),
    Color(0xFF414B56),
    Color(0xFF566371),
    Color(0xFF6A7B8D),
    Color(0xFF8594A3),
    Color(0xFFA1ACB8),
    Color(0xFFBCC4CD),
    Color(0xFFD8DCE1),
    Color(0xFFF4F5F6),
  ];
  static const Color accent2BaseLight = Color(0xFF566371);
  static const Color accent2BaseDark = Color(0xFFA1ACB8);

  // No error color comes from the logo — a clean modern red, tuned to sit
  // comfortably next to a cool blue palette without reading as a clash.
  static const Color errorLight = Color(0xFFE5484D);
  static const Color errorContainerLight = Color(0xFFFFE1E2);
  static const Color onErrorContainerLight = Color(0xFF641623);
  static const Color errorDark = Color(0xFFFF6369);
  static const Color errorContainerDark = Color(0xFF5C161A);
  static const Color onErrorContainerDark = Color(0xFFFFD9DA);
}

class AppTheme {
  const AppTheme._();

  // Built once: rebuilding ThemeData on every app rebuild forces the whole
  // widget tree to restyle.
  static final ThemeData _light = _base(_lightScheme());
  static final ThemeData _dark = _base(_darkScheme());

  static ThemeData light() => _light;
  static ThemeData dark() => _dark;

  /// Bundled fonts (assets/fonts): Noto Sans for Latin with Noto Sans Arabic
  /// as the fallback, so English and Arabic share one look and nothing is
  /// fetched from the internet at runtime.
  static const String bodyFamily = 'UnoSans';
  static const List<String> fallbackFamilies = ['UnoArabic'];

  static ColorScheme _lightScheme() {
    final n = _Brand.neutralLight;
    final a = _Brand.accentLight;
    final a2 = _Brand.accent2Light;
    final base = ColorScheme.fromSeed(seedColor: _Brand.accentBaseLight, brightness: Brightness.light);
    return base.copyWith(
      primary: _Brand.accentBaseLight,
      onPrimary: _Brand.bgLight,
      primaryContainer: a[1],
      onPrimaryContainer: a[7],
      secondary: _Brand.accent2BaseLight,
      onSecondary: _Brand.bgLight,
      secondaryContainer: a2[1],
      onSecondaryContainer: a2[7],
      tertiary: a2[5],
      onTertiary: _Brand.bgLight,
      tertiaryContainer: a2[0],
      onTertiaryContainer: a2[8],
      error: _Brand.errorLight,
      onError: Colors.white,
      errorContainer: _Brand.errorContainerLight,
      onErrorContainer: _Brand.onErrorContainerLight,
      surface: _Brand.bgLight,
      onSurface: _Brand.textLight,
      surfaceContainerLowest: n[0],
      surfaceContainerLow: _Brand.surfaceLight,
      surfaceContainer: n[1],
      surfaceContainerHigh: n[2],
      surfaceContainerHighest: n[3],
      outline: n[4],
      outlineVariant: n[2],
    );
  }

  static ColorScheme _darkScheme() {
    final n = _Brand.neutralDark;
    final a = _Brand.accentDark;
    final a2 = _Brand.accent2Dark;
    final base = ColorScheme.fromSeed(seedColor: _Brand.accentBaseDark, brightness: Brightness.dark);
    return base.copyWith(
      primary: _Brand.accentBaseDark,
      onPrimary: _Brand.bgDark,
      primaryContainer: a[1],
      onPrimaryContainer: a[7],
      secondary: _Brand.accent2BaseDark,
      onSecondary: _Brand.bgDark,
      secondaryContainer: a2[1],
      onSecondaryContainer: a2[7],
      tertiary: a2[5],
      onTertiary: _Brand.bgDark,
      tertiaryContainer: a2[0],
      onTertiaryContainer: a2[8],
      error: _Brand.errorDark,
      onError: const Color(0xFF3B0A0C),
      errorContainer: _Brand.errorContainerDark,
      onErrorContainer: _Brand.onErrorContainerDark,
      surface: _Brand.bgDark,
      onSurface: _Brand.textDark,
      surfaceContainerLowest: n[0],
      surfaceContainerLow: _Brand.surfaceDark,
      surfaceContainer: n[1],
      surfaceContainerHigh: n[2],
      surfaceContainerHighest: n[3],
      outline: n[4],
      outlineVariant: n[2],
    );
  }

  /// Translucent "glass" fills for cards and panels over [GlassBackground].
  static Color glassFill(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1B2B4D).withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.62);
  static Color glassBorder(Brightness b) =>
      b == Brightness.dark ? Colors.white.withValues(alpha: 0.14) : const Color(0xFF1B3A73).withValues(alpha: 0.10);

  /// Popups (dialogs, menus, sheets) stay nearly solid so text over busy
  /// screens stays easy to read.
  static Color _popupFill(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF14213D).withValues(alpha: 0.97) : const Color(0xFFF7FAFF).withValues(alpha: 0.98);

  static ColorScheme _glassScheme(ColorScheme s) {
    final dark = s.brightness == Brightness.dark;
    final fill = glassFill(s.brightness);
    return s.copyWith(
      surfaceContainerLowest: fill,
      surfaceContainerLow: fill,
      surfaceContainer: dark ? const Color(0xFF213459).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.7),
      surfaceContainerHigh: dark ? const Color(0xFF263B63).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.78),
      outlineVariant: dark ? glassBorder(s.brightness) : const Color(0xFF1B3A73).withValues(alpha: 0.14),
    );
  }

  static ThemeData _base(ColorScheme opaqueScheme) {
    final scheme = _glassScheme(opaqueScheme);
    final glassSide = BorderSide(color: glassBorder(scheme.brightness), width: 1);
    final popupShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: glassSide);
    final base = (scheme.brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final baseTextTheme = base
        .apply(
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
      titleLarge: baseTextTheme.titleLarge
          ?.copyWith(fontFamily: headingFamily, fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: baseTextTheme.titleMedium
          ?.copyWith(fontFamily: headingFamily, fontSize: 17, fontWeight: FontWeight.w700),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    // .btn { font-family: var(--font-heading) } — button labels use the
    // display font, not the body font, per the token sheet.
    const buttonTextStyle = TextStyle(fontFamily: headingFamily, fontFamilyFallback: fallbackFamilies, fontWeight: FontWeight.w700, fontSize: 14);
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
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: _popupFill(scheme.brightness),
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
        color: glassFill(scheme.brightness),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: glassSide),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _popupFill(scheme.brightness),
        surfaceTintColor: Colors.transparent,
        shape: popupShape,
        elevation: 24,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _popupFill(scheme.brightness),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: glassSide),
        elevation: 12,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _popupFill(scheme.brightness),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: _popupFill(scheme.brightness)),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(_popupFill(scheme.brightness))),
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
        backgroundColor: glassFill(scheme.brightness),
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
        indicatorColor: scheme.primaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: glassFill(scheme.brightness),
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        height: 68,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Brand colors exposed for the handful of places that need to reach past
/// the semantic ColorScheme roles for a deliberate accent — everything else
/// should use Theme.of(context).colorScheme, not these directly.
class BrandColors {
  const BrandColors._();
  static const Color blue = _Brand.accentBaseLight;
  static const Color silver = _Brand.accent2BaseLight;
  static const Color red = _Brand.errorLight;
  static const Color paper = _Brand.bgLight;
  static const Color ink = _Brand.textLight;
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
