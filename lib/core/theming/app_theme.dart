import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// UNOPOS's visual identity — the "Organic" design system: a warm cream
/// ground, a terracotta accent for primary actions, and a sage second voice,
/// with heavily rounded (often pill-shaped) shapes throughout. Every value
/// below is ported 1:1 from the design handoff's `organic.css` token sheet
/// (light values, then the `[data-theme="dark"]` overrides) — see
/// `supabase/../design_handoff_unopos_redesign/screens/organic.css` for the
/// source of truth if these ever need to be retuned.
class _Brand {
  const _Brand._();

  // Ground + text.
  static const Color bgLight = Color(0xFFF5EAD8);
  static const Color surfaceLight = Color(0xFFEBDDC5);
  static const Color textLight = Color(0xFF201E1D);
  static const Color bgDark = Color(0xFF201C17);
  static const Color surfaceDark = Color(0xFF2C2620);
  static const Color textDark = Color(0xFFF3ECE0);

  // Neutral tonal ramp (100 lightest step of the ramp -> 900 darkest step;
  // dark mode uses the same nine hex values remapped onto the opposite
  // steps, since the ramp is a shared perceptual scale, not two palettes).
  static const List<Color> neutralLight = [
    Color(0xFFF9F4ED),
    Color(0xFFEEE7DB),
    Color(0xFFDCD3C4),
    Color(0xFFC0B6A5),
    Color(0xFFA19786),
    Color(0xFF82796A),
    Color(0xFF645C50),
    Color(0xFF474238),
    Color(0xFF2E2B25),
  ];
  static const List<Color> neutralDark = [
    Color(0xFF2E2B25),
    Color(0xFF474238),
    Color(0xFF645C50),
    Color(0xFF82796A),
    Color(0xFFA19786),
    Color(0xFFC0B6A5),
    Color(0xFFDCD3C4),
    Color(0xFFEEE7DB),
    Color(0xFFF9F4ED),
  ];

  // Terracotta accent ramp (primary).
  static const List<Color> accentLight = [
    Color(0xFFFFF2EB),
    Color(0xFFFFE1D0),
    Color(0xFFFFC6A5),
    Color(0xFFF6A06B),
    Color(0xFFD67F48),
    Color(0xFFB2622D),
    Color(0xFF8C491A),
    Color(0xFF643312),
    Color(0xFF402310),
  ];
  static const List<Color> accentDark = [
    Color(0xFF402310),
    Color(0xFF643312),
    Color(0xFF8C491A),
    Color(0xFFB2622D),
    Color(0xFFD67F48),
    Color(0xFFF6A06B),
    Color(0xFFFFC6A5),
    Color(0xFFFFE1D0),
    Color(0xFFFFF2EB),
  ];
  static const Color accentBaseLight = Color(0xFFC67139);
  static const Color accentBaseDark = Color(0xFFF6A06B);

  // Sage accent-2 ramp (secondary/tertiary — "a genuine second voice").
  static const List<Color> accent2Light = [
    Color(0xFFF0FAE1),
    Color(0xFFE1EECC),
    Color(0xFFCCDBB2),
    Color(0xFFAEBF92),
    Color(0xFF8FA073),
    Color(0xFF728157),
    Color(0xFF56633F),
    Color(0xFF3D472B),
    Color(0xFF272E1B),
  ];
  static const List<Color> accent2Dark = [
    Color(0xFF272E1B),
    Color(0xFF3D472B),
    Color(0xFF56633F),
    Color(0xFF728157),
    Color(0xFF8FA073),
    Color(0xFFAEBF92),
    Color(0xFFCCDBB2),
    Color(0xFFE1EECC),
    Color(0xFFF0FAE1),
  ];
  static const Color accent2BaseLight = Color(0xFF7A8A5E);
  static const Color accent2BaseDark = Color(0xFFAEBF92);

  // No error color is defined by the Organic token sheet — this warm brick
  // red is a judgment call kept from the app's original palette because it
  // already reads as "warm", not grey, consistent with the new system's
  // "never desaturate into greys" rule.
  static const Color errorLight = Color(0xFFC4483B);
  static const Color errorContainerLight = Color(0xFFF6D3CD);
  static const Color onErrorContainerLight = Color(0xFF4A140D);
  static const Color errorDark = Color(0xFFE0685A);
  static const Color errorContainerDark = Color(0xFF5C231A);
  static const Color onErrorContainerDark = Color(0xFFF6D3CD);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _base(_lightScheme());
  static ThemeData dark() => _base(_darkScheme());

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
      onError: const Color(0xFF2B0805),
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

  static ThemeData _base(ColorScheme scheme) {
    // Figtree (body) + Caprasimo (headings/buttons) per the Organic system.
    // Neither Google Font covers Arabic glyphs, unlike the single Cairo
    // family used before this redesign — Flutter's text renderer falls back
    // to the platform's Arabic-capable font per-glyph automatically, so
    // Arabic strings still render, just no longer in the same family as the
    // Latin type. That's a real, accepted trade-off of following the
    // handoff's fidelity request, not an oversight.
    final baseTextTheme = GoogleFonts.figtreeTextTheme(
      (scheme.brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final headingFamily = GoogleFonts.caprasimo().fontFamily;

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge
          ?.copyWith(fontFamily: headingFamily, fontSize: 42, fontWeight: FontWeight.w400, letterSpacing: -0.6),
      headlineMedium: baseTextTheme.headlineMedium
          ?.copyWith(fontFamily: headingFamily, fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: -0.45),
      headlineSmall: baseTextTheme.headlineSmall
          ?.copyWith(fontFamily: headingFamily, fontSize: 20, fontWeight: FontWeight.w400, letterSpacing: -0.2),
      titleLarge: baseTextTheme.titleLarge
          ?.copyWith(fontFamily: headingFamily, fontSize: 20, fontWeight: FontWeight.w400),
      titleMedium: baseTextTheme.titleMedium
          ?.copyWith(fontFamily: headingFamily, fontSize: 17, fontWeight: FontWeight.w400),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    // .btn { font-family: var(--font-heading) } — button labels use the
    // display font, not the body font, per the token sheet.
    final buttonTextStyle = TextStyle(fontFamily: headingFamily, fontWeight: FontWeight.w400, fontSize: 14);
    const pillShape = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: scheme.brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.45) : _Brand.neutralLight[8].withValues(alpha: 0.14),
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        margin: EdgeInsets.zero,
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
        backgroundColor: scheme.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
        indicatorColor: scheme.primaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
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
  static const Color terracotta = _Brand.accentBaseLight;
  static const Color sage = _Brand.accent2BaseLight;
  static const Color brickRed = _Brand.errorLight;
  static const Color cream = _Brand.bgLight;
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
