import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/barcode_input_field.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';

Future<void> showProductEditDialog(BuildContext context, WidgetRef ref, {ProductRecord? existing}) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;

  final nameController = TextEditingController(text: existing?.name);
  final skuController = TextEditingController(text: existing?.sku);
  final barcodeController = TextEditingController(text: existing?.barcode);
  final costController = TextEditingController(text: existing == null ? '' : Money.toMajorUnits(existing.costPriceMinorUnits).toStringAsFixed(2));
  final priceController = TextEditingController(text: existing == null ? '' : Money.toMajorUnits(existing.sellPriceMinorUnits).toStringAsFixed(2));
  final reorderController = TextEditingController(text: '${existing?.reorderLevel ?? 0}');

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existing == null ? AppLocalizations.of(context).inventoryAddProduct : existing.name),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: AppLocalizations.of(context).commonName)),
              const SizedBox(height: 12),
              TextField(controller: skuController, decoration: const InputDecoration(labelText: 'SKU')),
              const SizedBox(height: 12),
              BarcodeInputField(controller: barcodeController, label: AppLocalizations.of(context).inventoryBarcode),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      decoration: const InputDecoration(labelText: 'Cost price'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).commonPrice),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reorderController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Reorder level'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context).actionCancel)),
        FilledButton(
          onPressed: () async {
            final repo = ref.read(inventoryRepositoryProvider);
            final record = ProductRecord(
              id: existing?.id ?? IdGenerator.newId(),
              storeId: session.store!.id,
              sku: skuController.text.trim(),
              barcode: barcodeController.text.trim().isEmpty ? null : barcodeController.text.trim(),
              name: nameController.text.trim(),
              costPriceMinorUnits: Money.toMinorUnits(double.tryParse(costController.text) ?? 0),
              sellPriceMinorUnits: Money.toMinorUnits(double.tryParse(priceController.text) ?? 0),
              reorderLevel: int.tryParse(reorderController.text) ?? 0,
            );
            if (existing == null) {
              await repo.createProduct(record);
            } else {
              await repo.updateProduct(record);
            }
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).actionSave),
        ),
      ],
    ),
  );
}
