import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';
import '../domain/product_expiry.dart';
import '../domain/product_units.dart';
import 'product_edit_dialog.dart';
import 'stock_receive_dialog.dart';
import 'product_thumb.dart';
import 'product_import_dialog.dart';
import 'qr_label_dialog.dart';

final _productsSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final _productsStreamProvider =
    StreamProvider.autoDispose.family<List<ProductRecord>, ({String storeId, String query})>((ref, key) {
  return ref
      .watch(inventoryRepositoryProvider)
      .watchProducts(key.storeId, searchQuery: key.query.isEmpty ? null : key.query);
});

final _branchStockProvider =
    StreamProvider.autoDispose.family<Map<String, int>, ({String storeId, String branchId})>((ref, key) {
  return ref
      .watch(inventoryRepositoryProvider)
      .watchStock(key.storeId, key.branchId)
      .map((items) => {for (final s in items) s.productId: s.quantityOnHand});
});

class ProductsTab extends ConsumerWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();

    final query = ref.watch(_productsSearchProvider);
    final canEdit = ref.watch(sessionControllerProvider).employee?.can(AppPermission.editProducts) ?? false;
    final productsAsync = ref.watch(_productsStreamProvider((storeId: storeId, query: query)));
    final branchId = ref.watch(sessionControllerProvider).currentBranchId;
    // Stock in the branch being worked in (each branch has its own stock).
    final stock = branchId == null
        ? const <String, int>{}
        : ref.watch(_branchStockProvider((storeId: storeId, branchId: branchId))).valueOrNull ?? const <String, int>{};

    final compact = MediaQuery.sizeOf(context).width < 600;
    final search = TextField(
      decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.actionSearch),
      onChanged: (v) => ref.read(_productsSearchProvider.notifier).state = v,
    );
    final actions = <Widget>[
      if (canEdit) ...[
        FilledButton.tonalIcon(
          icon: const Icon(Icons.add_box_outlined),
          label: Text(l10n.stockReceiveTitle),
          onPressed: () => showStockReceiveDialog(context, ref),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.auto_awesome),
          tooltip: l10n.inventoryGenerateMissingBarcodes,
          onPressed: () => _generateMissingBarcodes(context, ref, storeId),
        ),
        IconButton(
          icon: const Icon(Icons.upload_file),
          tooltip: l10n.importProductsTitle,
          onPressed: () => showProductImportDialog(context, ref),
        ),
      ],
    ];

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            // On a phone the search gets its own line, the actions below it.
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      if (actions.isNotEmpty) ...[const SizedBox(height: 8), Row(children: actions)],
                    ],
                  )
                : Row(children: [Expanded(child: search), const SizedBox(width: 8), ...actions]),
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
                    final expiry = expiryStatusOf(product);
                    final qty = stock[product.id] ?? 0;
                    final low = qty <= product.reorderLevel;
                    return ListTile(
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ProductThumb(imagePath: product.imagePath, size: 44),
                          if (expiry == ExpiryStatus.expired || expiry == ExpiryStatus.soon)
                            PositionedDirectional(
                              end: -4,
                              top: -4,
                              child: Icon(
                                expiry == ExpiryStatus.expired ? Icons.dangerous : Icons.schedule,
                                size: 16,
                                color: expiry == ExpiryStatus.expired
                                    ? Theme.of(context).colorScheme.error
                                    : Colors.orange.shade800,
                              ),
                            ),
                        ],
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.barcode ?? product.sku} · ${Money.format(product.sellPriceMinorUnits)} · ${productUnitLabel(context, product.unit)}',
                      ),
                      onTap: compact && canEdit ? () => showProductEditDialog(context, ref, existing: product) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Stock on hand here (replaces the cost, which stays in
                          // the product form for costing and profit).
                          Tooltip(
                            message: l10n.inventoryStockLevel,
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text('$qty'),
                              backgroundColor: low ? Theme.of(context).colorScheme.errorContainer : null,
                              labelStyle: low ? TextStyle(color: Theme.of(context).colorScheme.onErrorContainer) : null,
                            ),
                          ),
                          // A phone has room for the stock and one menu; the
                          // row itself opens the product.
                          if (compact)
                            PopupMenuButton<String>(
                              onSelected: (action) => switch (action) {
                                'label' => showQrLabelDialog(context, ref, product),
                                'edit' => showProductEditDialog(context, ref, existing: product),
                                _ => _deleteProduct(context, ref, product),
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(value: 'label', child: Text(l10n.inventoryGenerateQr)),
                                if (canEdit) PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
                                if (canEdit) PopupMenuItem(value: 'delete', child: Text(l10n.productDelete)),
                              ],
                            )
                          else ...[
                            IconButton(
                              icon: const Icon(Icons.qr_code_2),
                              tooltip: l10n.inventoryGenerateQr,
                              onPressed: () => showQrLabelDialog(context, ref, product),
                            ),
                            if (canEdit)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => showProductEditDialog(context, ref, existing: product),
                              ),
                            if (canEdit)
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                tooltip: l10n.productDelete,
                                onPressed: () => _deleteProduct(context, ref, product),
                              ),
                          ],
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
      floatingActionButton: !canEdit
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showProductEditDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.inventoryAddProduct),
            ),
    );
  }
}

/// Back-fills an in-store barcode for every product that doesn't have one
/// yet, so older products can be labelled too.
Future<void> _generateMissingBarcodes(BuildContext context, WidgetRef ref, String storeId) async {
  final l10n = AppLocalizations.of(context);
  final products = await ref.read(inventoryRepositoryProvider).watchProducts(storeId).first;
  var count = 0;
  for (final product in products) {
    if (product.barcode?.isNotEmpty ?? false) continue;
    await assignGeneratedBarcode(ref, product);
    count++;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inventoryBarcodesGenerated(count))));
  }
}

/// Removes a product from the catalog after confirmation. Past invoices,
/// returns and stock history still refer to it, so it is taken off sale
/// (hidden everywhere) rather than erased.
Future<void> _deleteProduct(BuildContext context, WidgetRef ref, ProductRecord product) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
      title: Text(l10n.productDeleteTitle(product.name)),
      content: Text(l10n.productDeleteMessage),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.productDelete),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(inventoryRepositoryProvider).setProductActive(product.id, false);
    messenger.showSnackBar(SnackBar(content: Text(l10n.productDeleted(product.name))));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
  }
}
