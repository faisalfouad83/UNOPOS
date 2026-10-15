import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';
import 'purchase_orders_tab.dart';
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

class StockTab extends ConsumerStatefulWidget {
  const StockTab({super.key});

  @override
  ConsumerState<StockTab> createState() => _StockTabState();
}

class _StockTabState extends ConsumerState<StockTab> {
  /// Transfers being received right now (a second tap does nothing).
  final _receiving = <String>{};

  Future<void> _receive(StockTransferRecord transfer, String userId) async {
    if (!_receiving.add(transfer.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(inventoryRepositoryProvider).receiveStockTransfer(transfer.id, userId);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(receiptErrorText(l10n, e, transfer: true))));
    } finally {
      _receiving.remove(transfer.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // A transfer whose lines haven't all arrived yet isn't shown.
              final pendingTransfers =
                  transfersAsync.value?.where((t) => t.status == 'pending' && t.lines.isNotEmpty).toList() ?? const [];

              return ListView(
                // Room for the transfer button over the last row.
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  if (pendingTransfers.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(l10n.inventoryTransferStock, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    ...pendingTransfers.map((transfer) => ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: Text(context.l10n.transferItemCount(transfer.lines.length)),
                          subtitle: Text(transfer.toBranchId == branchId
                              ? context.l10n.transferIncoming
                              : context.l10n.transferOutgoing),
                          trailing: transfer.toBranchId != branchId
                              ? null
                              : _receiving.contains(transfer.id)
                                  ? const SizedBox(
                                      width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                  : TextButton(
                                      child: Text(context.l10n.actionReceive),
                                      onPressed: () => _receive(transfer, session.employee?.id ?? ''),
                                    ),
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
                            onPressed: () => showStockAdjustDialog(
                              context,
                              ref,
                              storeId: storeId,
                              branchId: branchId,
                              product: product,
                              onHand: qty,
                            ),
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
}

/// Adds or takes away stock of [product] in [branchId] (a counted
/// correction, damage, etc.), recorded as a stock movement. Can't take away
/// more than is on hand.
Future<void> showStockAdjustDialog(
  BuildContext context,
  WidgetRef ref, {
  required String storeId,
  required String branchId,
  required ProductRecord product,
  required int onHand,
}) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  var increase = true;
  String? error;
  var saving = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${l10n.inventoryAdjustStock}: ${product.name}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.inventoryStockLevel}: $onHand'),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('+'), icon: Icon(Icons.add)),
                  ButtonSegment(value: false, label: Text('-'), icon: Icon(Icons.remove)),
                ],
                selected: {increase},
                onSelectionChanged: (s) => setState(() {
                  increase = s.first;
                  error = null;
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.commonQuantity, errorText: error),
                onChanged: (_) => setState(() => error = null),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    final qty = int.tryParse(controller.text) ?? 0;
                    if (qty <= 0 || (!increase && qty > onHand)) {
                      setState(() => error = l10n.errorQuantityInvalid);
                      return;
                    }
                    setState(() => saving = true);
                    final session = ref.read(sessionControllerProvider);
                    try {
                      await ref.read(inventoryRepositoryProvider).recordStockMovement(
                            storeId: storeId,
                            productId: product.id,
                            branchId: branchId,
                            type: increase ? StockMovementType.adjustmentIn : StockMovementType.adjustmentOut,
                            quantity: qty,
                            unitCostMinorUnits: product.costPriceMinorUnits,
                            referenceType: 'ADJUSTMENT',
                            createdByUserId: session.employee?.id ?? session.store?.id ?? '',
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (_) {
                      if (!context.mounted) return;
                      setState(() {
                        saving = false;
                        error = l10n.errorGeneric;
                      });
                    }
                  },
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
}
