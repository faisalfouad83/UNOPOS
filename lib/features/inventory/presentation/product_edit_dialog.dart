import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/barcode_input_field.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/barcode_generator.dart';
import '../domain/inventory_models.dart';
import '../domain/product_units.dart';
import 'qr_label_dialog.dart';

Future<void> showProductEditDialog(BuildContext context, WidgetRef ref, {ProductRecord? existing}) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;

  final repo = ref.read(inventoryRepositoryProvider);
  final categories = await repo.watchCategories(session.store!.id).first;
  final taxRates = await repo.watchTaxRates(session.store!.id).first;
  if (!context.mounted) return;

  final nameController = TextEditingController(text: existing?.name);
  final skuController = TextEditingController(text: existing?.sku);
  final barcodeController = TextEditingController(text: existing?.barcode);
  final costController = TextEditingController(text: existing == null ? '' : Money.inputText(existing.costPriceMinorUnits));
  final priceController = TextEditingController(text: existing == null ? '' : Money.inputText(existing.sellPriceMinorUnits));
  final wholesaleController = TextEditingController(
    text: existing?.wholesalePriceMinorUnits == null ? '' : Money.inputText(existing!.wholesalePriceMinorUnits!),
  );
  DateTime? expiryDate = existing?.expiryDate;
  final reorderController = TextEditingController(text: '${existing?.reorderLevel ?? 0}');
  String unit = existing?.unit ?? 'pcs';
  String? categoryId = existing?.categoryId;
  String? taxRateId = existing?.taxRateId ?? (taxRates.where((t) => t.isDefault).isNotEmpty ? taxRates.firstWhere((t) => t.isDefault).id : null);
  ProductRecord? savedWithGeneratedBarcode;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BarcodeInputField(
                        controller: barcodeController,
                        label: AppLocalizations.of(context).inventoryBarcode,
                        helperText: AppLocalizations.of(context).inventoryBarcodeAutoHint,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      tooltip: AppLocalizations.of(context).inventoryGenerateBarcode,
                      onPressed: () async {
                        final code = await BarcodeGenerator.newUniqueBarcode(repo, session.store!.id);
                        setState(() => barcodeController.text = code);
                      },
                    ),
                  ],
                ),
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wholesaleController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).inventoryWholesalePrice,
                          helperText: AppLocalizations.of(context).commonOptional,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: expiryDate ?? now.add(const Duration(days: 180)),
                            firstDate: DateTime(now.year - 2),
                            lastDate: DateTime(now.year + 15),
                          );
                          if (picked != null) setState(() => expiryDate = picked);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).inventoryExpiryDate,
                            helperText: AppLocalizations.of(context).commonOptional,
                            suffixIcon: expiryDate == null
                                ? const Icon(Icons.event)
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() => expiryDate = null),
                                  ),
                          ),
                          child: Text(expiryDate == null ? '—' : AppDateFormat.shortDate(expiryDate!)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: categoryId,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).inventoryCategories),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('—')),
                    ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => categoryId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: taxRateId,
                  decoration: const InputDecoration(labelText: 'Tax rate'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...taxRates.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.ratePercent}%)'))),
                  ],
                  onChanged: (v) => setState(() => taxRateId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reorderController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Reorder level'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: unit,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).inventoryUnit),
                  items: productUnitOptions
                      .map((code) => DropdownMenuItem(value: code, child: Text(productUnitLabel(context, code))))
                      .toList(),
                  onChanged: (v) => setState(() => unit = v ?? unit),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context).actionCancel)),
          FilledButton(
            onPressed: () async {
              // A product with no barcode gets an in-store one generated so
              // it can still be labelled and scanned; a blank SKU reuses it.
              var barcode = barcodeController.text.trim();
              final generated = barcode.isEmpty;
              if (generated) barcode = await BarcodeGenerator.newUniqueBarcode(repo, session.store!.id);
              final sku = skuController.text.trim().isEmpty ? barcode : skuController.text.trim();
              final record = ProductRecord(
                id: existing?.id ?? IdGenerator.newId(),
                storeId: session.store!.id,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                name: nameController.text.trim(),
                unit: unit,
                taxRateId: taxRateId,
                costPriceMinorUnits: Money.toMinorUnits(double.tryParse(costController.text) ?? 0),
                sellPriceMinorUnits: Money.toMinorUnits(double.tryParse(priceController.text) ?? 0),
                reorderLevel: int.tryParse(reorderController.text) ?? 0,
                wholesalePriceMinorUnits: wholesaleController.text.trim().isEmpty
                    ? null
                    : Money.toMinorUnits(double.tryParse(wholesaleController.text) ?? 0),
                expiryDate: expiryDate,
                // Not editable here — carry them over instead of resetting.
                imagePath: existing?.imagePath,
                isActive: existing?.isActive ?? true,
              );
              if (existing == null) {
                await repo.createProduct(record);
              } else {
                await repo.updateProduct(record);
              }
              if (generated) savedWithGeneratedBarcode = record;
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).actionSave),
          ),
        ],
      ),
    ),
  );

  // Offer the label straight away so a freshly generated code can be
  // printed and stuck on the product.
  final generatedFor = savedWithGeneratedBarcode;
  if (generatedFor != null && context.mounted) {
    await showQrLabelDialog(context, ref, generatedFor);
  }
}
