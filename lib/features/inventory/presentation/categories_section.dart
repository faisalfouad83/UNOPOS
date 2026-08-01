import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../domain/inventory_models.dart';

final categoriesProvider = StreamProvider.autoDispose.family<List<CategoryRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchCategories(storeId);
});

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key, required this.storeId});
  final String storeId;

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).actionAdd),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: AppLocalizations.of(context).commonName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context).actionCancel)),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(inventoryRepositoryProvider).createCategory(storeId, controller.text.trim());
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).actionSave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesProvider(storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.inventoryCategories, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(icon: const Icon(Icons.add), onPressed: () => _addCategory(context, ref)),
              ],
            ),
            categoriesAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (categories) {
                if (categories.isEmpty) {
                  return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.inventoryCategories));
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((c) => Chip(label: Text(c.name))).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
