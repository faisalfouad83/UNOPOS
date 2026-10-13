import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_image_store.dart';

/// A product's photo, or a placeholder when it has none (or it can't be
/// loaded right now).
class ProductThumb extends ConsumerWidget {
  const ProductThumb({super.key, required this.imagePath, this.size = 40, this.radius = 8});

  final String? imagePath;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.inventory_2_outlined, size: size * 0.55, color: scheme.primary),
    );
    final path = imagePath;
    if (path == null || path.isEmpty) return placeholder;
    final bytes = ref.watch(productImageProvider(path)).valueOrNull;
    if (bytes == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}
