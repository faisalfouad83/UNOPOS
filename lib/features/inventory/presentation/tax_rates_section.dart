import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../domain/inventory_models.dart';

final taxRatesProvider = StreamProvider.autoDispose.family<List<TaxRateRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchTaxRates(storeId);
});

class TaxRatesSection extends ConsumerWidget {
  const TaxRatesSection({super.key, required this.storeId});
  final String storeId;

  Future<void> _addTaxRate(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    bool isDefault = false;
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
                TextField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  decoration: InputDecoration(
                    labelText: context.l10n.taxRatePercent,
                    errorText: error,
                    errorMaxLines: 2,
                  ),
                  onChanged: (_) => setState(() => error = null),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.taxDefaultForNew),
                  value: isDefault,
                  onChanged: (v) => setState(() => isDefault = v ?? false),
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
                      final rate = double.tryParse(rateController.text.trim());
                      if (rate == null || rate < 0 || rate > 100) {
                        setState(() => error = context.l10n.invTaxRateInvalid);
                        return;
                      }
                      setState(() => saving = true);
                      try {
                        // A new default replaces the old one (see createTaxRate).
                        await ref.read(inventoryRepositoryProvider).createTaxRate(
                              storeId,
                              nameController.text.trim(),
                              rate,
                              isDefault: isDefault,
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
    final ratesAsync = ref.watch(taxRatesProvider(storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(context.l10n.taxRatesTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(Icons.add), onPressed: () => _addTaxRate(context, ref)),
              ],
            ),
            ratesAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (rates) => Column(
                children: rates
                    .map((r) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(r.name),
                          trailing: Text('${r.ratePercent}%${r.isDefault ? ' · ${context.l10n.taxDefault}' : ''}'),
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
