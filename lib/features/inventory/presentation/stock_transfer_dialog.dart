import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.transferOneBranchOnly)));
    return;
  }
  if (products.isEmpty) return;

  BranchRecord toBranch = otherBranches.first;
  final lines = <(ProductRecord, TextEditingController qty)>[];
  var saving = false;
  String? error;

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
                  isExpanded: true,
                  initialValue: toBranch,
                  decoration: InputDecoration(labelText: context.l10n.transferToBranch),
                  items: otherBranches
                      .map((b) => DropdownMenuItem(value: b, child: Text(b.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: saving ? null : (v) => setState(() => toBranch = v ?? toBranch),
                ),
                const SizedBox(height: 12),
                ...lines.map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(line.$1.name, maxLines: 2, overflow: TextOverflow.ellipsis)),
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
                            onPressed: saving ? null : () => setState(() => lines.remove(line)),
                          ),
                        ],
                      ),
                    )),
                DropdownButton<ProductRecord>(
                  isExpanded: true,
                  hint: Text(context.l10n.addProductLine),
                  items: products
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: saving
                      ? null
                      : (p) {
                          if (p == null) return;
                          setState(() {
                            error = null;
                            lines.add((p, TextEditingController(text: '1')));
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
          TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: saving || lines.isEmpty
                ? null
                : () async {
                    final quantities = <MapEntry<String, int>>[];
                    for (final l in lines) {
                      final qty = int.tryParse(l.$2.text.trim()) ?? 0;
                      if (qty <= 0) {
                        setState(() => error = '${l.$1.name}: ${l10n.errorQuantityInvalid}');
                        return;
                      }
                      quantities.add(MapEntry(l.$1.id, qty));
                    }
                    setState(() {
                      saving = true;
                      error = null;
                    });
                    try {
                      await ref.read(inventoryRepositoryProvider).createStockTransfer(
                            storeId: session.store!.id,
                            fromBranchId: session.currentBranchId!,
                            toBranchId: toBranch.id,
                            requestedByUserId: session.employee!.id,
                            productQuantities: quantities,
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
}
