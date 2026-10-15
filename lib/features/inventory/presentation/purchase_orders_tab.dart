import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../suppliers/domain/suppliers_models.dart';
import '../domain/inventory_models.dart';

final _purchaseOrdersProvider = StreamProvider.autoDispose.family<List<PurchaseOrderRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchPurchaseOrders(storeId);
});

/// What to tell the user when receiving a purchase order ([transfer] false)
/// or a stock transfer failed: the server's "already received" / "was
/// cancelled" in words, anything else as a general error.
String receiptErrorText(AppLocalizations l10n, Object error, {required bool transfer}) {
  return switch (ReceiptRefusedException.from(error)?.reason) {
    ReceiptRefusal.alreadyReceived => transfer ? l10n.invTransferAlreadyReceived : l10n.invPoAlreadyReceived,
    ReceiptRefusal.cancelled => transfer ? l10n.invTransferCancelled : l10n.invPoCancelled,
    null => l10n.errorGeneric,
  };
}

class PurchaseOrdersTab extends ConsumerStatefulWidget {
  const PurchaseOrdersTab({super.key});

  @override
  ConsumerState<PurchaseOrdersTab> createState() => _PurchaseOrdersTabState();
}

class _PurchaseOrdersTabState extends ConsumerState<PurchaseOrdersTab> {
  /// Orders being received right now (a second tap does nothing).
  final _receiving = <String>{};

  /// Receives [po]: its stock goes in (on the server, once), then what is
  /// owed to the supplier and the journal entry are recorded for the
  /// order's own total — also when the receipt was kept to send later.
  Future<void> _receive(PurchaseOrderRecord po) async {
    if (!_receiving.add(po.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final session = ref.read(sessionControllerProvider);
    final userId = session.employee?.id ?? '';
    try {
      await ref.read(inventoryRepositoryProvider).receivePurchaseOrder(po.id, userId);
      final amount = po.totalCostMinorUnits;
      if (amount > 0) {
        await ref.read(suppliersRepositoryProvider).recordTransaction(
              storeId: po.storeId,
              supplierId: po.supplierId,
              type: SupplierTransactionType.purchase,
              amountMinorUnits: amount,
              relatedPurchaseOrderId: po.id,
              createdByUserId: userId,
            );
        await ref.read(accountingPostingServiceProvider).postSupplierPurchase(
              storeId: po.storeId,
              branchId: po.branchId,
              purchaseOrderId: po.id,
              createdByUserId: userId,
              amountMinorUnits: amount,
              paidImmediately: po.paidImmediately,
            );
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.invPoReceived)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(receiptErrorText(l10n, e, transfer: false))));
    } finally {
      _receiving.remove(po.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    if (storeId == null) return const SizedBox.shrink();

    final poAsync = ref.watch(_purchaseOrdersProvider(storeId));

    return Scaffold(
      body: poAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (orders) {
          if (orders.isEmpty) return Center(child: Text(l10n.inventoryPurchaseOrders));
          return ListView.builder(
            // Room for the add button over the last row.
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final po = orders[index];
              final busy = _receiving.contains(po.id);
              return ListTile(
                title:
                    Text('${context.l10n.poShort} ${po.id.substring(0, 8)} · ${Money.format(po.totalCostMinorUnits)}'),
                subtitle: Text(po.status),
                trailing: switch (po.status) {
                  'received' => const Icon(Icons.check_circle, color: Colors.green),
                  'cancelled' => const Icon(Icons.block),
                  _ => busy
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(
                          onPressed: () => _receive(po),
                          child: Text(context.l10n.actionReceive),
                        ),
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePoDialog(context, ref, storeId, session.currentBranchId ?? ''),
        icon: const Icon(Icons.add),
        label: Text(l10n.inventoryPurchaseOrders),
      ),
    );
  }
}

typedef _PoLine = (ProductRecord, TextEditingController qty, TextEditingController cost);

Future<void> _showCreatePoDialog(BuildContext context, WidgetRef ref, String storeId, String branchId) async {
  final products = await ref.read(inventoryRepositoryProvider).watchProducts(storeId).first;
  final suppliers = await ref.read(suppliersRepositoryProvider).watchSuppliers(storeId).first;
  if (!context.mounted) return;
  if (suppliers.isEmpty || products.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.poNeedSupplierAndProduct)));
    return;
  }

  String? supplierId = suppliers.first.id;
  final lines = <_PoLine>[];
  var saving = false;
  String? error;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final l10n = AppLocalizations.of(context);

        Future<void> create() async {
          final parsed = <SupplierPurchaseLine>[];
          for (final l in lines) {
            final qty = int.tryParse(l.$2.text.trim());
            final cost = double.tryParse(l.$3.text.trim());
            if (qty == null || qty <= 0 || cost == null || cost < 0) {
              setState(() => error = '${l.$1.name}: ${l10n.errorQuantityInvalid}');
              return;
            }
            parsed.add(SupplierPurchaseLine(
              productId: l.$1.id,
              quantity: qty,
              unitCostMinorUnits: Money.toMinorUnits(cost),
            ));
          }
          setState(() {
            saving = true;
            error = null;
          });
          try {
            await ref.read(inventoryRepositoryProvider).createPurchaseOrder(
                  storeId: storeId,
                  branchId: branchId,
                  supplierId: supplierId!,
                  paidImmediately: false,
                  lines: parsed,
                );
            if (context.mounted) Navigator.of(context).pop();
          } catch (_) {
            if (context.mounted) {
              setState(() {
                saving = false;
                error = l10n.errorGeneric;
              });
            }
          }
        }

        return AlertDialog(
          title: Text(l10n.poNew),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: supplierId,
                    items: suppliers
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: saving ? null : (v) => setState(() => supplierId = v),
                    decoration: InputDecoration(labelText: l10n.poSupplier),
                  ),
                  const SizedBox(height: 12),
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(line.$1.name, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              controller: line.$2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(labelText: l10n.commonQuantity),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 84,
                            child: TextField(
                              controller: line.$3,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              decoration: InputDecoration(labelText: l10n.inventoryCostPrice),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.actionRemove,
                            icon: const Icon(Icons.close),
                            onPressed: saving ? null : () => setState(() => lines.remove(line)),
                          ),
                        ],
                      ),
                    ),
                  DropdownButton<ProductRecord>(
                    isExpanded: true,
                    hint: Text(l10n.addProductLine),
                    items: products
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: saving
                        ? null
                        : (p) {
                            if (p == null) return;
                            setState(() {
                              error = null;
                              lines.add((
                                p,
                                TextEditingController(text: '1'),
                                TextEditingController(
                                    text: Money.toMajorUnits(p.costPriceMinorUnits).toStringAsFixed(2)),
                              ));
                            });
                          },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: saving || supplierId == null || lines.isEmpty ? null : create,
              child: Text(l10n.actionCreate),
            ),
          ],
        );
      },
    ),
  );
  for (final l in lines) {
    l.$2.dispose();
    l.$3.dispose();
  }
}
