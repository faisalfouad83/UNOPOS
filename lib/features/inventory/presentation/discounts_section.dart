import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../domain/inventory_models.dart';

final discountsProvider = StreamProvider.autoDispose.family<List<DiscountRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchDiscounts(storeId);
});

class DiscountsSection extends ConsumerWidget {
  const DiscountsSection({super.key, required this.storeId});
  final String storeId;

  Future<void> _addDiscount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    DiscountType type = DiscountType.percentOff;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.actionAdd),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.commonName)),
              const SizedBox(height: 12),
              SegmentedButton<DiscountType>(
                segments: const [
                  ButtonSegment(value: DiscountType.percentOff, label: Text('% off')),
                  ButtonSegment(value: DiscountType.amountOff, label: Text('Amount off')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(labelText: type == DiscountType.percentOff ? 'Percent' : l10n.commonAmount),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final rawValue = double.tryParse(valueController.text) ?? 0;
                final value = type == DiscountType.percentOff ? rawValue.round() : Money.toMinorUnits(rawValue);
                await ref.read(inventoryRepositoryProvider).createDiscount(
                      storeId: storeId,
                      name: nameController.text.trim(),
                      type: type,
                      value: value,
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final discountsAsync = ref.watch(discountsProvider(storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Discounts', style: TextStyle(fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(Icons.add), onPressed: () => _addDiscount(context, ref)),
              ],
            ),
            discountsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (discounts) => Column(
                children: discounts
                    .map((d) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(d.name),
                          trailing: Text(
                            d.type == DiscountType.percentOff ? '${d.value}%' : Money.format(d.value, currencySymbol: r'$'),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
