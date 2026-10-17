import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'store_themes.dart';

/// The backdrop behind every screen in the "glass" look: the current
/// theme's gradient with a few soft glows and, for the seasonal themes, a
/// faint motif in two corners (stars, a crescent, leaves...). Screens are
/// transparent and their cards are translucent, so this shows through them.
/// Drawn once and kept in its own layer — no blur, no animation — so it
/// costs nothing while the till is in use.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decor = theme.extension<ThemeDecor>() ??
        ThemeDecor.fromPalette(theme.brightness == Brightness.dark ? ThemePalettes.dark : ThemePalettes.light);
    final dark = decor.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: decor.gradient),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (decor.glows.isNotEmpty)
                  _Glow(alignment: const Alignment(-0.95, -0.9), color: decor.glows[0], dark: dark, size: 520),
                if (decor.glows.length > 1)
                  _Glow(alignment: const Alignment(1.0, 0.95), color: decor.glows[1], dark: dark, size: 460),
                if (decor.glows.length > 2)
                  _Glow(alignment: const Alignment(0.35, -0.35), color: decor.glows[2], dark: dark, size: 360),
                if (decor.motif != ThemeMotif.none)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _MotifPainter(
                        motif: decor.motif,
                        color: (decor.glows.isNotEmpty ? decor.glows.first : theme.colorScheme.primary)
                            .withValues(alpha: dark ? 0.16 : 0.12),
                        rtl: Directionality.maybeOf(context) == TextDirection.rtl,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.alignment, required this.color, required this.dark, required this.size});

  final Alignment alignment;
  final Color color;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: dark ? 0.32 : 0.22), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// A few outline shapes in the top end corner and one in the bottom start
/// corner, kept small and faint so they never sit under text strongly
/// enough to matter.
class _MotifPainter extends CustomPainter {
  _MotifPainter({required this.motif, required this.color, required this.rtl});

  final ThemeMotif motif;
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final unit = math.min(size.shortestSide * 0.22, 120.0);
    final endX = rtl ? unit * 0.9 : size.width - unit * 0.9;
    final startX = rtl ? size.width - unit * 0.8 : unit * 0.8;
    _draw(canvas, Offset(endX, unit * 0.9), unit * 0.5);
    _draw(canvas, Offset(endX + (rtl ? unit * 0.75 : -unit * 0.75), unit * 1.6), unit * 0.22);
    _draw(canvas, Offset(endX + (rtl ? -unit * 0.1 : unit * 0.1), unit * 2.05), unit * 0.14);
    _draw(canvas, Offset(startX, size.height - unit * 0.9), unit * 0.38);
  }

  void _draw(Canvas canvas, Offset c, double r) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, r * 0.08)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    switch (motif) {
      case ThemeMotif.none:
        return;
      case ThemeMotif.star:
        canvas.drawPath(_star(c, r, r * 0.45, 5), fill);
      case ThemeMotif.geometric:
        // An eight-pointed star: two squares, one turned 45 degrees.
        canvas.drawPath(_polygon(c, r, 4, 0), stroke);
        canvas.drawPath(_polygon(c, r, 4, math.pi / 4), stroke);
        canvas.drawCircle(c, r * 0.3, stroke);
      case ThemeMotif.crescent:
        final moon = Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: c, radius: r)),
          Path()..addOval(Rect.fromCircle(center: c + Offset(r * 0.42, -r * 0.18), radius: r * 0.86)),
        );
        canvas.drawPath(moon, fill);
        if (r > 30) canvas.drawPath(_star(c + Offset(r * 0.55, -r * 0.05), r * 0.22, r * 0.09, 5), fill);
      case ThemeMotif.moon:
        canvas.drawCircle(c, r, stroke);
        canvas.drawCircle(c + Offset(-r * 0.3, -r * 0.2), r * 0.16, fill);
        canvas.drawCircle(c + Offset(r * 0.25, r * 0.3), r * 0.1, fill);
      case ThemeMotif.petal:
        for (var i = 0; i < 5; i++) {
          final a = i * 2 * math.pi / 5 - math.pi / 2;
          canvas.save();
          canvas.translate(c.dx + math.cos(a) * r * 0.5, c.dy + math.sin(a) * r * 0.5);
          canvas.rotate(a + math.pi / 2);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.55, height: r * 0.95), fill);
          canvas.restore();
        }
      case ThemeMotif.sun:
        canvas.drawCircle(c, r * 0.45, fill);
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi / 6;
          final dir = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(c + dir * r * 0.62, c + dir * r, stroke);
        }
      case ThemeMotif.leaf:
        final top = c + Offset(0, -r);
        final bottom = c + Offset(0, r);
        final leaf = Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(c.dx + r * 0.9, c.dy, bottom.dx, bottom.dy)
          ..quadraticBezierTo(c.dx - r * 0.9, c.dy, top.dx, top.dy)
          ..close();
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(-0.5);
        canvas.translate(-c.dx, -c.dy);
        canvas.drawPath(leaf, fill);
        canvas.drawLine(top, bottom + Offset(0, r * 0.25), stroke..color = color.withValues(alpha: color.a * 1.4));
        canvas.restore();
      case ThemeMotif.snowflake:
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final dir = Offset(math.cos(a), math.sin(a));
          final tip = c + dir * r;
          canvas.drawLine(c, tip, stroke);
          final mid = c + dir * r * 0.6;
          for (final s in [-1, 1]) {
            final b = a + s * math.pi / 4;
            canvas.drawLine(mid, mid + Offset(math.cos(b), math.sin(b)) * r * 0.28, stroke);
          }
        }
    }
  }

  static Path _star(Offset c, double outer, double inner, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Path _polygon(Offset c, double r, int sides, double rotation) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = rotation + i * 2 * math.pi / sides;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_MotifPainter old) => old.motif != motif || old.color != color || old.rtl != rtl;
}
