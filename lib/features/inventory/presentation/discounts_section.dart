import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
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
    var saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.actionAdd),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.commonName)),
                const SizedBox(height: 12),
                SegmentedButton<DiscountType>(
                  segments: [
                    ButtonSegment(value: DiscountType.percentOff, label: Text(context.l10n.discountPercentOff)),
                    ButtonSegment(value: DiscountType.amountOff, label: Text(context.l10n.discountAmountOff)),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setState(() {
                    type = s.first;
                    valueController.clear();
                    error = null;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  // A percentage is a whole number (it's stored as one).
                  keyboardType: type == DiscountType.percentOff
                      ? TextInputType.number
                      : const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    type == DiscountType.percentOff
                        ? FilteringTextInputFormatter.digitsOnly
                        : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: type == DiscountType.percentOff ? context.l10n.posDiscountPercent : l10n.commonAmount,
                    errorText: error,
                    errorMaxLines: 2,
                  ),
                  onChanged: (_) => setState(() => error = null),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) return;
                      final int value;
                      if (type == DiscountType.percentOff) {
                        value = int.tryParse(valueController.text.trim()) ?? 0;
                        if (value < 1 || value > 100) {
                          setState(() => error = context.l10n.invDiscountPercentInvalid);
                          return;
                        }
                      } else {
                        value = Money.toMinorUnits(double.tryParse(valueController.text.trim()) ?? 0);
                        if (value <= 0) {
                          setState(() => error = context.l10n.invAmountInvalid);
                          return;
                        }
                      }
                      setState(() => saving = true);
                      try {
                        await ref.read(inventoryRepositoryProvider).createDiscount(
                              storeId: storeId,
                              name: nameController.text.trim(),
                              type: type,
                              value: value,
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
                Expanded(child: Text(context.l10n.discountsTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
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
                            d.type == DiscountType.percentOff ? '${d.value}%' : Money.format(d.value),
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
