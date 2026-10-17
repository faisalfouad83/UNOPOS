import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/theming/app_theme.dart';
import 'package:unopos/core/theming/store_themes.dart';

/// WCAG 2.x contrast ratio of two opaque colours.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

double hueDistance(Color a, Color b) {
  final d = (HSLColor.fromColor(a).hue - HSLColor.fromColor(b).hue).abs() % 360;
  return d > 180 ? 360 - d : d;
}

void main() {
  for (final key in StoreThemeKey.values) {
    group('${key.dbKey} theme', () {
      final p = key.palette;

      // Everything text is drawn on: the bare backdrop, a glass card over
      // each part of it, a popup, and the opaque surface.
      final grounds = <String, Color>{
        for (var i = 0; i < p.gradient.length; i++) 'backdrop $i': p.gradient[i],
        for (var i = 0; i < p.gradient.length; i++)
          'card over backdrop $i': Color.alphaBlend(p.glassFill, p.gradient[i]),
        'popup': Color.alphaBlend(p.popupFill, p.gradient.first),
        'surface': p.surface,
      };

      test('text, money and status colours reach AA (4.5:1) on every surface', () {
        final texts = <String, Color>{
          'text / money': p.onSurface,
          'secondary text': p.onSurfaceVariant,
          'primary (links, text buttons)': p.primary,
          'error': p.error,
          'success': p.success,
          'warning': p.warning,
        };
        for (final t in texts.entries) {
          for (final g in grounds.entries) {
            expect(contrast(t.value, g.value), greaterThanOrEqualTo(4.5), reason: '${t.key} on ${g.key}');
          }
        }
      });

      test('labels on filled colours reach AA', () {
        final pairs = <String, (Color, Color)>{
          'button label': (p.onPrimary, p.primary),
          'secondary label': (p.onSecondary, p.secondary),
          'tertiary label': (p.onTertiary, p.tertiary),
          'error label': (p.onError, p.error),
          'success label': (p.onSuccess, p.success),
          'warning label': (p.onWarning, p.warning),
          'primary container': (p.onPrimaryContainer, p.primaryContainer),
          'secondary container': (p.onSecondaryContainer, p.secondaryContainer),
          'error container': (p.onErrorContainer, p.errorContainer),
          'success container': (p.onSuccessContainer, p.successContainer),
        };
        for (final e in pairs.entries) {
          expect(contrast(e.value.$1, e.value.$2), greaterThanOrEqualTo(4.5), reason: e.key);
        }
      });

      test('error and success stay clearly different', () {
        expect(hueDistance(p.error, p.success), greaterThanOrEqualTo(60));
        // And an error never looks like the theme's own accent.
        expect(hueDistance(p.error, p.primary), greaterThanOrEqualTo(20));
      });

      test('the built ThemeData carries the palette', () {
        final theme = AppTheme.forKey(key);
        expect(theme.brightness, p.brightness);
        expect(theme.colorScheme.primary, p.primary);
        expect(theme.colorScheme.onSurface, p.onSurface);
        expect(theme.colorScheme.error, p.error);
        expect(theme.extension<StatusColors>()?.success, p.success);
        expect(theme.extension<ThemeDecor>()?.motif, p.motif);
        // The Arabic/Kurdish fallback font stays in every theme.
        expect(theme.textTheme.bodyMedium?.fontFamilyFallback, contains('UnoArabic'));
      });
    });
  }

  test('Light and Dark are still AppTheme.light() and AppTheme.dark()', () {
    expect(AppTheme.light(), same(AppTheme.forKey(StoreThemeKey.light)));
    expect(AppTheme.dark().brightness, Brightness.dark);
  });
}
