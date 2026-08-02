import 'package:flutter/material.dart';

/// A card with a rounded top and a torn/perforated bottom edge — the one
/// signature shape UNOPOS repeats deliberately, because it's literally the
/// shape of what the app prints. Used sparingly, for the handful of cards
/// that deserve to feel like a real receipt: totals, activation, summaries.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
    this.toothWidth = 16,
    this.toothHeight = 7,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double toothWidth;
  final double toothHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipPath(
      clipper: _ReceiptEdgeClipper(toothWidth: toothWidth, toothHeight: toothHeight),
      child: ColoredBox(
        color: color ?? scheme.surfaceContainerLow,
        child: Padding(
          padding: padding.add(EdgeInsets.only(bottom: toothHeight + 6)),
          child: child,
        ),
      ),
    );
  }
}

class _ReceiptEdgeClipper extends CustomClipper<Path> {
  const _ReceiptEdgeClipper({required this.toothWidth, required this.toothHeight});

  final double toothWidth;
  final double toothHeight;
  static const double topRadius = 20;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, topRadius)
      ..quadraticBezierTo(0, 0, topRadius, 0)
      ..lineTo(size.width - topRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, topRadius);

    final bottomY = size.height - toothHeight;
    path.lineTo(size.width, bottomY);

    final teeth = (size.width / toothWidth).round().clamp(2, 200);
    final actualToothWidth = size.width / teeth;
    for (var i = 0; i < teeth; i++) {
      final midX = size.width - (i + 0.5) * actualToothWidth;
      final nextX = size.width - (i + 1) * actualToothWidth;
      path.lineTo(midX, size.height);
      path.lineTo(nextX, bottomY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ReceiptEdgeClipper oldClipper) =>
      oldClipper.toothWidth != toothWidth || oldClipper.toothHeight != toothHeight;
}
