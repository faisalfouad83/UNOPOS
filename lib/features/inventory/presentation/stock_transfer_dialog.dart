import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';

Future<void> showCreateStockTransferDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.currentBranchId == null || session.employee == null) return;

  final branches = await ref.read(authRepositoryProvider).listBranches(session.store!.id);
  final otherBranches = branches.where((b) => b.id != session.currentBranchId).toList();
  final products = await ref.read(inventoryRepositoryProvider).watchProducts(session.store!.id).first;
  if (!context.mounted) return;

  if (otherBranches.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This store only has one branch — nothing to transfer to')));
    return;
  }
  if (products.isEmpty) return;

  BranchRecord toBranch = otherBranches.first;
  final lines = <(ProductRecord, TextEditingController qty)>[];

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.inventoryTransferStock),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<BranchRecord>(
                  initialValue: toBranch,
                  decoration: const InputDecoration(labelText: 'To branch'),
                  items: otherBranches.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                  onChanged: (v) => setState(() => toBranch = v ?? toBranch),
                ),
                const SizedBox(height: 12),
                ...lines.map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(line.$1.name)),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: line.$2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(labelText: l10n.commonQuantity),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => lines.remove(line)),
                          ),
                        ],
                      ),
                    )),
                DropdownButton<ProductRecord>(
                  hint: const Text('Add product line'),
                  items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (p) {
                    if (p == null) return;
                    setState(() => lines.add((p, TextEditingController(text: '1'))));
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: lines.isEmpty
                ? null
                : () async {
                    await ref.read(inventoryRepositoryProvider).createStockTransfer(
                          storeId: session.store!.id,
                          fromBranchId: session.currentBranchId!,
                          toBranchId: toBranch.id,
                          requestedByUserId: session.employee!.id,
                          productQuantities: lines
                              .map((l) => MapEntry(l.$1.id, int.tryParse(l.$2.text) ?? 0))
                              .where((e) => e.value > 0)
                              .toList(),
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
