import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../suppliers/domain/suppliers_models.dart';
import '../domain/inventory_models.dart';

final _purchaseOrdersProvider = StreamProvider.autoDispose.family<List<PurchaseOrderRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchPurchaseOrders(storeId);
});

class PurchaseOrdersTab extends ConsumerWidget {
  const PurchaseOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final po = orders[index];
              return ListTile(
                title: Text('PO ${po.id.substring(0, 8)} · ${Money.format(po.totalCostMinorUnits, currencySymbol: r'$')}'),
                subtitle: Text(po.status),
                trailing: po.status == 'received'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : TextButton(
                        child: const Text('Receive'),
                        onPressed: () async {
                          final result = await ref.read(inventoryRepositoryProvider).receivePurchaseOrder(po.id, session.employee?.id ?? '');
                          await ref.read(suppliersRepositoryProvider).recordTransaction(
                                storeId: storeId,
                                supplierId: po.supplierId,
                                type: SupplierTransactionType.purchase,
                                amountMinorUnits: result,
                                relatedPurchaseOrderId: po.id,
                                createdByUserId: session.employee?.id ?? '',
                              );
                          await ref.read(accountingPostingServiceProvider).postSupplierPurchase(
                                storeId: storeId,
                                branchId: po.branchId,
                                purchaseOrderId: po.id,
                                createdByUserId: session.employee?.id ?? '',
                                amountMinorUnits: result,
                                paidImmediately: po.paidImmediately,
                              );
                        },
                      ),
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

  Future<void> _showCreatePoDialog(BuildContext context, WidgetRef ref, String storeId, String branchId) async {
    final products = await ref.read(inventoryRepositoryProvider).watchProducts(storeId).first;
    final suppliers = await ref.read(suppliersRepositoryProvider).watchSuppliers(storeId).first;
    if (!context.mounted) return;
    if (suppliers.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a supplier and at least one product first')));
      return;
    }

    String? supplierId = suppliers.first.id;
    final lines = <(ProductRecord, TextEditingController qty, TextEditingController cost)>[];

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Purchase Order'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: supplierId,
                    items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => supplierId = v),
                    decoration: const InputDecoration(labelText: 'Supplier'),
                  ),
                  const SizedBox(height: 12),
                  ...lines.map((line) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(line.$1.name)),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                controller: line.$2,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(labelText: 'Qty'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: line.$3,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                decoration: const InputDecoration(labelText: 'Cost'),
                              ),
                            ),
                          ],
                        ),
                      )),
                  DropdownButton<ProductRecord>(
                    hint: const Text('Add product line'),
                    items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                    onChanged: (p) {
                      if (p == null) return;
                      setState(() {
                        lines.add((
                          p,
                          TextEditingController(text: '1'),
                          TextEditingController(text: Money.toMajorUnits(p.costPriceMinorUnits).toStringAsFixed(2)),
                        ));
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: supplierId == null || lines.isEmpty
                  ? null
                  : () async {
                      await ref.read(inventoryRepositoryProvider).createPurchaseOrder(
                            storeId: storeId,
                            branchId: branchId,
                            supplierId: supplierId!,
                            paidImmediately: false,
                            lines: lines
                                .map((l) => SupplierPurchaseLine(
                                      productId: l.$1.id,
                                      quantity: int.tryParse(l.$2.text) ?? 0,
                                      unitCostMinorUnits: Money.toMinorUnits(double.tryParse(l.$3.text) ?? 0),
                                    ))
                                .toList(),
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
