import 'package:flutter/material.dart';

/// UNOPOS's mark: a price tag, not a generic storefront/cart icon — the
/// single object most specific to "software that runs a checkout counter."
/// Drawn with CustomPainter so it's crisp at any size and themeable, no
/// bitmap asset needed.
class UnoposLogo extends StatelessWidget {
  const UnoposLogo({super.key, this.size = 56, this.color, this.holeColor});

  final double size;
  final Color? color;
  final Color? holeColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TagPainter(
          tagColor: color ?? scheme.primary,
          holeColor: holeColor ?? scheme.secondary,
        ),
      ),
    );
  }
}

class _TagPainter extends CustomPainter {
  _TagPainter({required this.tagColor, required this.holeColor});

  final Color tagColor;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final tagPath = Path()
      ..moveTo(w * 0.04, h * 0.5)
      ..lineTo(w * 0.32, h * 0.09)
      ..quadraticBezierTo(w * 0.36, h * 0.06, w * 0.42, h * 0.06)
      ..lineTo(w * 0.86, h * 0.06)
      ..quadraticBezierTo(w * 0.94, h * 0.06, w * 0.94, h * 0.14)
      ..lineTo(w * 0.94, h * 0.86)
      ..quadraticBezierTo(w * 0.94, h * 0.94, w * 0.86, h * 0.94)
      ..lineTo(w * 0.42, h * 0.94)
      ..quadraticBezierTo(w * 0.36, h * 0.94, w * 0.32, h * 0.91)
      ..lineTo(w * 0.04, h * 0.5)
      ..close();

    final hole = Path()..addOval(Rect.fromCircle(center: Offset(w * 0.335, h * 0.5), radius: w * 0.075));

    final combined = Path.combine(PathOperation.difference, tagPath, hole);

    canvas.drawPath(combined, Paint()..color = tagColor);

    // A small amber "price dot" accent, echoing a sale sticker.
    canvas.drawCircle(Offset(w * 0.72, h * 0.32), w * 0.06, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _TagPainter oldDelegate) =>
      oldDelegate.tagColor != tagColor || oldDelegate.holeColor != holeColor;
}
