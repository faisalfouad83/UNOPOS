import 'package:flutter/material.dart';

/// UNOPOS's brand mark — the actual logo artwork (the blue/silver "U+N"
/// monogram on its navy tile), not a themed vector redraw. Every call site
/// uses this at icon-ish sizes (22-72px), so this is the tight monogram
/// crop, not the full lockup with the "UNOPOS" wordmark and tagline — that
/// text would be illegible this small. It's a fixed dark tile by design, so
/// it reads consistently as a brand badge regardless of the surrounding
/// light/dark theme.
class UnoposLogo extends StatelessWidget {
  const UnoposLogo({super.key, this.size = 56, this.borderRadius});

  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? size * 0.2),
      child: Image.asset(
        'assets/branding/unopos_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
