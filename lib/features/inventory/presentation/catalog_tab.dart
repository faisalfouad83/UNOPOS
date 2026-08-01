import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/session_controller.dart';
import 'categories_section.dart';
import 'discounts_section.dart';
import 'tax_rates_section.dart';

/// Groups everything a manager configures once and rarely touches again —
/// product categories, tax rates, and discounts — so the Products tab
/// doesn't get cluttered with setup screens.
class CatalogTab extends ConsumerWidget {
  const CatalogTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CategoriesSection(storeId: storeId),
        const SizedBox(height: 16),
        TaxRatesSection(storeId: storeId),
        const SizedBox(height: 16),
        DiscountsSection(storeId: storeId),
      ],
    );
  }
}
