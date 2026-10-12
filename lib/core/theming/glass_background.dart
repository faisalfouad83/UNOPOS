import 'package:flutter/material.dart';

/// The backdrop behind every screen in the light "glass" look: a deep
/// gradient with a few soft brand-coloured glows. Screens are transparent
/// and their cards are translucent, so this shows through them. Drawn once
/// and kept in its own layer — no blur, no animation — so it costs nothing
/// while the till is in use.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [Color(0xFF070D1A), Color(0xFF0D1B38), Color(0xFF081226)]
                    : const [Color(0xFFEAF1FF), Color(0xFFF6F9FF), Color(0xFFE3EEFF)],
              ),
            ),
            child: Stack(
              children: [
                _Glow(alignment: const Alignment(-0.95, -0.9), color: const Color(0xFF1677FF), dark: dark, size: 520),
                _Glow(alignment: const Alignment(1.0, 0.95), color: const Color(0xFF00C2FF), dark: dark, size: 460),
                _Glow(alignment: const Alignment(0.35, -0.35), color: const Color(0xFF7C4DFF), dark: dark, size: 360),
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
