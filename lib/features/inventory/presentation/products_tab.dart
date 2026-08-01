import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';
import 'product_edit_dialog.dart';
import 'qr_label_dialog.dart';

final _productsSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final _productsStreamProvider = StreamProvider.autoDispose.family<List<ProductRecord>, ({String storeId, String query})>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(key.storeId, searchQuery: key.query.isEmpty ? null : key.query);
});

class ProductsTab extends ConsumerWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();

    final query = ref.watch(_productsSearchProvider);
    final productsAsync = ref.watch(_productsStreamProvider((storeId: storeId, query: query)));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.actionSearch),
              onChanged: (v) => ref.read(_productsSearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(l10n.errorGeneric)),
              data: (products) {
                if (products.isEmpty) {
                  return Center(child: Text(l10n.inventoryAddProduct));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(product.name),
                      subtitle: Text('${product.sku} · ${Money.format(product.sellPriceMinorUnits, currencySymbol: r'$')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code_2),
                            tooltip: l10n.inventoryGenerateQr,
                            onPressed: () => showQrLabelDialog(context, product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => showProductEditDialog(context, ref, existing: product),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductEditDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.inventoryAddProduct),
      ),
    );
  }
}
