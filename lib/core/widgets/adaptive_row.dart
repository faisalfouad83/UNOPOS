import 'package:flutter/material.dart';

/// A row of form fields that stays a row when there is room for it and
/// becomes a column on a phone, so no field gets squeezed to a few letters.
///
/// Children are written as for a [Row] — [Expanded]/[Flexible] fields with
/// `SizedBox(width: …)` gaps; in the column the wrappers are dropped and the
/// gaps become vertical.
class AdaptiveRow extends StatelessWidget {
  const AdaptiveRow({
    super.key,
    required this.children,
    this.minRowWidth = 480,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.gap = 12,
  });

  final List<Widget> children;

  /// Narrower than this, the fields go one under the other.
  final double minRowWidth;
  final CrossAxisAlignment crossAxisAlignment;

  /// The space between fields in the column.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minRowWidth) {
          return Row(crossAxisAlignment: crossAxisAlignment, children: children);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in children)
              if (c is Flexible)
                c.child
              else if (c is SizedBox && c.child == null && c.height == null)
                SizedBox(height: gap)
              else
                c,
          ],
        );
      },
    );
  }
}
