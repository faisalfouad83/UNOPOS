import 'package:flutter/material.dart';

import 'store_themes.dart';

/// A small picture of a theme: its backdrop, a glass card with a line of
/// text, a button and the success/error colours — what a screen in that
/// theme looks like, without building one.
class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({super.key, required this.palette, this.width = 112, this.height = 72});

  /// A swatch split diagonally between Light and Dark (the "follow the
  /// device" choice).
  static Widget lightDark({double width = 112, double height = 72}) => SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ThemeSwatch(palette: ThemePalettes.light, width: width, height: height),
              ClipPath(
                clipper: _DiagonalClipper(),
                child: ThemeSwatch(palette: ThemePalettes.dark, width: width, height: height),
              ),
            ],
          ),
        ),
      );

  final ThemePalette palette;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    Widget dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p.gradient),
      ),
      child: Stack(
        children: [
          if (p.glows.isNotEmpty)
            PositionedDirectional(
              top: -18,
              start: -18,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [p.glows.first.withValues(alpha: 0.45), p.glows.first.withValues(alpha: 0)]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: p.glassFill,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: p.isDark ? Colors.white.withValues(alpha: 0.14) : p.onSurface.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 5,
                    width: 46,
                    decoration: BoxDecoration(color: p.onSurface, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    width: 30,
                    decoration: BoxDecoration(color: p.onSurfaceVariant, borderRadius: BorderRadius.circular(3)),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 34,
                        decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(6)),
                      ),
                      const Spacer(),
                      dot(p.success),
                      const SizedBox(width: 3),
                      dot(p.error),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}
