import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';
import 'stock_transfer_dialog.dart';

typedef _StoreBranch = ({String storeId, String branchId});

final _productsForStockProvider = StreamProvider.autoDispose.family<List<ProductRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(storeId);
});

final _stockItemsProvider = StreamProvider.autoDispose.family<List<StockItemRecord>, _StoreBranch>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchStock(key.storeId, key.branchId);
});

final _stockTransfersProvider = StreamProvider.autoDispose.family<List<StockTransferRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchStockTransfers(storeId);
});

class StockTab extends ConsumerWidget {
  const StockTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    final branchId = session.currentBranchId;
    if (storeId == null || branchId == null) return const SizedBox.shrink();

    final productsAsync = ref.watch(_productsForStockProvider(storeId));
    final stockAsync = ref.watch(_stockItemsProvider((storeId: storeId, branchId: branchId)));
    final transfersAsync = ref.watch(_stockTransfersProvider(storeId));

    return Scaffold(
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (products) {
          return stockAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(l10n.errorGeneric)),
            data: (stockItems) {
              final byProductId = {for (final s in stockItems) s.productId: s};
              final pendingTransfers = transfersAsync.value?.where((t) => t.status == 'pending').toList() ?? const [];

              return ListView(
                children: [
                  if (pendingTransfers.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(l10n.inventoryTransferStock, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    ...pendingTransfers.map((transfer) => ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: Text('${transfer.lines.length} item(s)'),
                          subtitle: Text(transfer.toBranchId == branchId ? 'Incoming' : 'Outgoing'),
                          trailing: transfer.toBranchId == branchId
                              ? TextButton(
                                  child: const Text('Receive'),
                                  onPressed: () => ref
                                      .read(inventoryRepositoryProvider)
                                      .receiveStockTransfer(transfer.id, session.employee?.id ?? ''),
                                )
                              : null,
                        )),
                    const Divider(),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(l10n.inventoryStockLevel, style: Theme.of(context).textTheme.titleSmall),
                  ),
                  ...products.map((product) {
                    final qty = byProductId[product.id]?.quantityOnHand ?? 0;
                    final isLow = qty <= product.reorderLevel;
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('${l10n.inventoryStockLevel}: $qty'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLow)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(l10n.inventoryLowStock),
                                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.tune),
                            tooltip: l10n.inventoryAdjustStock,
                            onPressed: () => _showAdjustDialog(context, ref, storeId, branchId, product),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateStockTransferDialog(context, ref),
        icon: const Icon(Icons.swap_horiz),
        label: Text(l10n.inventoryTransferStock),
      ),
    );
  }

  Future<void> _showAdjustDialog(
    BuildContext context,
    WidgetRef ref,
    String storeId,
    String branchId,
    ProductRecord product,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool increase = true;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${l10n.inventoryAdjustStock}: ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('+'), icon: Icon(Icons.add)),
                  ButtonSegment(value: false, label: Text('-'), icon: Icon(Icons.remove)),
                ],
                selected: {increase},
                onSelectionChanged: (s) => setState(() => increase = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.commonQuantity),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () async {
                final qty = int.tryParse(controller.text) ?? 0;
                if (qty <= 0) return;
                final session = ref.read(sessionControllerProvider);
                await ref.read(inventoryRepositoryProvider).recordStockMovement(
                      storeId: storeId,
                      productId: product.id,
                      branchId: branchId,
                      type: increase ? StockMovementType.adjustmentIn : StockMovementType.adjustmentOut,
                      quantity: qty,
                      createdByUserId: session.employee?.id ?? session.store?.id ?? '',
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.actionConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
