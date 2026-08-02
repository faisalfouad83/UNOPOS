import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// UNOPOS's visual identity is grounded in the till itself: a deep ledger
/// green for trust and structure, a price-tag amber for money and calls to
/// action, and a warm receipt-paper cream instead of a stark white — this
/// is a tool people stand at all day, not a marketing page.
class _Brand {
  const _Brand._();

  static const Color tillGreen = Color(0xFF1B4332);
  static const Color priceAmber = Color(0xFFE8A33D);
  static const Color freshGreen = Color(0xFF4C9A6A);
  static const Color tagRed = Color(0xFFC4483B);
  static const Color receiptCream = Color(0xFFF7F3EA);
  static const Color charcoalInk = Color(0xFF12181A);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _base(_lightScheme());
  static ThemeData dark() => _base(_darkScheme());

  static ColorScheme _lightScheme() {
    final base = ColorScheme.fromSeed(seedColor: _Brand.tillGreen, brightness: Brightness.light);
    return base.copyWith(
      primary: _Brand.tillGreen,
      onPrimary: _Brand.receiptCream,
      primaryContainer: const Color(0xFFCFE3D4),
      onPrimaryContainer: const Color(0xFF082013),
      secondary: _Brand.priceAmber,
      onSecondary: const Color(0xFF3A2704),
      secondaryContainer: const Color(0xFFFCE4BB),
      onSecondaryContainer: const Color(0xFF3A2704),
      tertiary: _Brand.freshGreen,
      onTertiary: Colors.white,
      error: _Brand.tagRed,
      onError: Colors.white,
      errorContainer: const Color(0xFFF6D3CD),
      onErrorContainer: const Color(0xFF4A140D),
      surface: _Brand.receiptCream,
      onSurface: const Color(0xFF1E2420),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFBF8F1),
      surfaceContainer: const Color(0xFFF1EBDD),
      surfaceContainerHigh: const Color(0xFFEAE2CF),
      surfaceContainerHighest: const Color(0xFFE3D9C2),
      outline: const Color(0xFF8C8371),
      outlineVariant: const Color(0xFFD8CFBB),
    );
  }

  static ColorScheme _darkScheme() {
    final base = ColorScheme.fromSeed(seedColor: _Brand.tillGreen, brightness: Brightness.dark);
    return base.copyWith(
      primary: const Color(0xFF6FC28E),
      onPrimary: const Color(0xFF07130C),
      primaryContainer: const Color(0xFF20402C),
      onPrimaryContainer: const Color(0xFFCFE3D4),
      secondary: _Brand.priceAmber,
      onSecondary: const Color(0xFF3A2704),
      secondaryContainer: const Color(0xFF52400F),
      onSecondaryContainer: const Color(0xFFFCE4BB),
      tertiary: const Color(0xFF8FD1A8),
      onTertiary: const Color(0xFF07130C),
      error: const Color(0xFFE0685A),
      onError: const Color(0xFF2B0805),
      errorContainer: const Color(0xFF5C231A),
      onErrorContainer: const Color(0xFFF6D3CD),
      surface: _Brand.charcoalInk,
      onSurface: const Color(0xFFEDEAE2),
      surfaceContainerLowest: const Color(0xFF0B0F10),
      surfaceContainerLow: const Color(0xFF171E20),
      surfaceContainer: const Color(0xFF1C2426),
      surfaceContainerHigh: const Color(0xFF26302F),
      surfaceContainerHighest: const Color(0xFF313D3B),
      outline: const Color(0xFF6B7573),
      outlineVariant: const Color(0xFF394442),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    // Cairo reads equally well in Arabic, Kurdish Sorani, and English —
    // one type family across every language instead of a Latin font with
    // Arabic bolted on as an afterthought.
    final baseTextTheme = GoogleFonts.cairoTextTheme(
      (scheme.brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light()).textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

/// Brand colors exposed for the handful of places that need to reach past
/// the semantic ColorScheme roles for a deliberate accent (e.g. a price
/// figure, a receipt-edge card) — everything else should use
/// Theme.of(context).colorScheme, not these directly.
class BrandColors {
  const BrandColors._();
  static const Color tillGreen = _Brand.tillGreen;
  static const Color priceAmber = _Brand.priceAmber;
  static const Color freshGreen = _Brand.freshGreen;
  static const Color tagRed = _Brand.tagRed;
  static const Color receiptCream = _Brand.receiptCream;
  static const Color charcoalInk = _Brand.charcoalInk;
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
