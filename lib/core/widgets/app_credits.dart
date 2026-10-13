import 'package:flutter/material.dart';

/// The app's credit line, shown the same way on the sign-in screen, at the
/// bottom of Settings and in a bottom corner of the main screen.
class AppCredits extends StatelessWidget {
  const AppCredits({super.key, this.alignment = AlignmentDirectional.center});

  static const text = '© faisal fouad & yassin faisal';

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: alignment,
      child: Text(
        text,
        // The names are written in Latin letters: keep them left-to-right
        // even inside an Arabic layout.
        textDirection: TextDirection.ltr,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.75), letterSpacing: 0.2),
      ),
    );
  }
}
