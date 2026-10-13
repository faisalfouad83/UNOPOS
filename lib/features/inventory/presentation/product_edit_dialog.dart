import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/barcode_input_field.dart';
import '../../auth/domain/session_controller.dart';
import '../../settings/presentation/invoice_branding_section.dart';
import '../data/product_image_store.dart';
import '../domain/barcode_generator.dart';
import '../domain/inventory_models.dart';
import '../domain/product_code.dart';
import '../domain/product_units.dart';
import 'product_thumb.dart';
import 'qr_label_dialog.dart';
import 'stock_tab.dart';

/// Add or edit a product: photo, name, its barcode (scanned, typed or
/// generated — one code field; the internal SKU is optional and defaults to
/// the barcode), prices, and for a new product the stock it starts with in
/// the branch being worked in.
Future<void> showProductEditDialog(BuildContext context, WidgetRef ref, {ProductRecord? existing}) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;

  final repo = ref.read(inventoryRepositoryProvider);
  final categories = await repo.watchCategories(session.store!.id).first;
  final taxRates = await repo.watchTaxRates(session.store!.id).first;
  if (!context.mounted) return;

  final saved = await showDialog<_Saved>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProductEditDialog(existing: existing, categories: categories, taxRates: taxRates),
  );

  // Offer the label straight away so a freshly generated code can be
  // printed and stuck on the product.
  if (saved != null && saved.generatedBarcode && context.mounted) {
    await showQrLabelDialog(context, ref, saved.product);
  }
}

class _Saved {
  const _Saved(this.product, {required this.generatedBarcode});
  final ProductRecord product;
  final bool generatedBarcode;
}

class _ProductEditDialog extends ConsumerStatefulWidget {
  const _ProductEditDialog({required this.existing, required this.categories, required this.taxRates});

  final ProductRecord? existing;
  final List<CategoryRecord> categories;
  final List<TaxRateRecord> taxRates;

  @override
  ConsumerState<_ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends ConsumerState<_ProductEditDialog> {
  late final ProductRecord? existing = widget.existing;
  late final _name = TextEditingController(text: existing?.name);
  late final _barcode = TextEditingController(text: existing?.barcode);
  late final _sku =
      TextEditingController(text: existing == null || existing!.sku == existing!.barcode ? '' : existing!.sku);
  late final _cost =
      TextEditingController(text: existing == null ? '' : Money.inputText(existing!.costPriceMinorUnits));
  late final _price =
      TextEditingController(text: existing == null ? '' : Money.inputText(existing!.sellPriceMinorUnits));
  late final _wholesale = TextEditingController(
    text: existing?.wholesalePriceMinorUnits == null ? '' : Money.inputText(existing!.wholesalePriceMinorUnits!),
  );
  late final _reorder = TextEditingController(text: '${existing?.reorderLevel ?? 0}');
  final _openingStock = TextEditingController();
  late DateTime? _expiry = existing?.expiryDate;
  late String _unit = existing?.unit ?? 'pcs';
  late String? _categoryId = existing?.categoryId;
  late String? _taxRateId = existing?.taxRateId ?? widget.taxRates.where((t) => t.isDefault).firstOrNull?.id;

  /// Photo picked in this dialog (not saved yet), or the photo removed.
  Uint8List? _newImage;
  bool _imageRemoved = false;

  bool _generated = false;
  bool _saving = false;
  String? _nameError;
  String? _codeError;
  String? _skuError;
  String? _stockError;
  String? _error;
  int? _stockHere;

  @override
  void initState() {
    super.initState();
    final e = existing;
    final branchId = ref.read(sessionControllerProvider).currentBranchId;
    if (e != null && branchId != null) {
      ref.read(inventoryRepositoryProvider).getStockItem(e.id, branchId).then((s) {
        if (mounted) setState(() => _stockHere = s?.quantityOnHand ?? 0);
      }).catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _barcode, _sku, _cost, _price, _wholesale, _reorder, _openingStock]) {
      c.dispose();
    }
    super.dispose();
  }

  String _codeErrorText(AppLocalizations l10n, ProductCodeError e) => switch (e) {
        ProductCodeError.invalidCharacters => l10n.productCodeInvalidChars,
        ProductCodeError.tooLong => l10n.productCodeTooLong,
        ProductCodeError.badCheckDigit => l10n.productCodeBadCheckDigit,
      };

  Future<void> _generate() async {
    final storeId = ref.read(sessionControllerProvider).store!.id;
    final code = await BarcodeGenerator.newUniqueBarcode(ref.read(inventoryRepositoryProvider), storeId);
    setState(() {
      _barcode.text = code;
      _generated = true;
      _codeError = null;
    });
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await pickImageFile();
      if (bytes == null) return;
      final png = await resizeImageToPng(bytes, maxSide: 512);
      setState(() {
        _newImage = png;
        _imageRemoved = false;
      });
    } on FormatException catch (e) {
      setState(() => _error = e.message == 'size' ? l10n.imageTooLarge : l10n.imageWrongType);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionControllerProvider);
    final storeId = session.store!.id;
    final repo = ref.read(inventoryRepositoryProvider);
    final images = ref.read(productImageStoreProvider);

    final name = _name.text.trim();
    var barcode = _barcode.text.trim();
    final skuTyped = _sku.text.trim();
    final opening = _openingStock.text.trim().isEmpty ? 0 : int.tryParse(_openingStock.text.trim());
    setState(() {
      _nameError = name.isEmpty ? l10n.errorRequired : null;
      final codeProblem = validateProductCode(barcode);
      _codeError = codeProblem == null ? null : _codeErrorText(l10n, codeProblem);
      final skuProblem = validateProductCode(skuTyped);
      _skuError =
          skuProblem == null || skuProblem == ProductCodeError.badCheckDigit ? null : _codeErrorText(l10n, skuProblem);
      _stockError = opening == null || opening < 0 ? l10n.errorQuantityInvalid : null;
      _error = null;
    });
    if (_nameError != null || _codeError != null || _skuError != null || _stockError != null) return;

    setState(() => _saving = true);
    try {
      // No code typed: generate an in-store one so the product can still
      // be labelled and scanned.
      var generated = _generated;
      if (barcode.isEmpty) {
        barcode = await BarcodeGenerator.newUniqueBarcode(repo, storeId);
        generated = true;
      }
      final id = existing?.id ?? IdGenerator.newId();

      // One code, one product.
      final sameBarcode = await repo.findByBarcode(storeId, barcode);
      if (sameBarcode != null && sameBarcode.id != id) {
        setState(() => _codeError = l10n.productCodeTaken(sameBarcode.name));
        return;
      }
      final sku = skuTyped.isEmpty ? barcode : skuTyped;
      final all = await repo.watchProducts(storeId).first;
      final sameSku = all.where((p) => p.id != id && p.sku.toLowerCase() == sku.toLowerCase()).firstOrNull;
      if (sameSku != null) {
        setState(() => _skuError = l10n.productCodeTaken(sameSku.name));
        return;
      }

      var imagePath = _imageRemoved ? null : existing?.imagePath;
      if (_newImage != null) {
        imagePath = await images.save(storeId: storeId, productId: id, png: _newImage!);
      }

      final record = ProductRecord(
        id: id,
        storeId: storeId,
        categoryId: _categoryId,
        sku: sku,
        barcode: barcode,
        name: name,
        unit: _unit,
        taxRateId: _taxRateId,
        costPriceMinorUnits: Money.toMinorUnits(double.tryParse(_cost.text) ?? 0),
        sellPriceMinorUnits: Money.toMinorUnits(double.tryParse(_price.text) ?? 0),
        reorderLevel: int.tryParse(_reorder.text) ?? 0,
        wholesalePriceMinorUnits:
            _wholesale.text.trim().isEmpty ? null : Money.toMinorUnits(double.tryParse(_wholesale.text) ?? 0),
        expiryDate: _expiry,
        imagePath: imagePath,
        isActive: existing?.isActive ?? true,
      );
      if (existing == null) {
        await repo.createProduct(record);
        // The stock it starts with, in the branch being worked in, recorded
        // as an ordinary stock movement so the history explains it.
        final branchId = session.currentBranchId;
        if (opening! > 0 && branchId != null) {
          await repo.recordStockMovement(
            storeId: storeId,
            productId: id,
            branchId: branchId,
            type: StockMovementType.adjustmentIn,
            quantity: opening,
            unitCostMinorUnits: record.costPriceMinorUnits,
            referenceType: 'OPENING_STOCK',
            referenceId: id,
            createdByUserId: session.employee?.id ?? storeId,
          );
        }
      } else {
        await repo.updateProduct(record);
      }
      // The old photo is no longer used by anything.
      final oldPath = existing?.imagePath;
      if (oldPath != null && oldPath != imagePath) await images.remove(oldPath);

      if (mounted) Navigator.of(context).pop(_Saved(record, generatedBarcode: generated));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final money = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];
    final session = ref.watch(sessionControllerProvider);
    final branchName = ref
            .watch(storeBranchesProvider(session.store!.id))
            .valueOrNull
            ?.where((b) => b.id == session.currentBranchId)
            .firstOrNull
            ?.name ??
        '';
    final showsImage = _newImage != null || (!_imageRemoved && (existing?.imagePath?.isNotEmpty ?? false));

    return AlertDialog(
      title: Text(existing == null ? l10n.inventoryAddProduct : existing!.name),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (_newImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_newImage!, width: 72, height: 72, fit: BoxFit.cover),
                    )
                  else
                    ProductThumb(imagePath: _imageRemoved ? null : existing?.imagePath, size: 72, radius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(showsImage ? l10n.productPhotoChange : l10n.productPhotoChoose),
                          onPressed: _saving ? null : _pickImage,
                        ),
                        if (showsImage)
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: Text(l10n.actionRemove),
                            onPressed: () => setState(() {
                              _newImage = null;
                              _imageRemoved = true;
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                autofocus: existing == null,
                decoration: InputDecoration(labelText: l10n.commonName, errorText: _nameError),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BarcodeInputField(
                      controller: _barcode,
                      label: l10n.inventoryBarcode,
                      helperText: _codeError == null ? l10n.productCodeHelp : null,
                      errorText: _codeError,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    tooltip: l10n.inventoryGenerateBarcode,
                    onPressed: _saving ? null : _generate,
                  ),
                ],
              ),
              if (_generated)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.productCodeGeneratedInfo, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: _sku.text.isNotEmpty,
                title: Text(l10n.productSkuOptional, style: theme.textTheme.bodyMedium),
                children: [
                  TextField(
                    controller: _sku,
                    decoration: InputDecoration(
                      labelText: context.l10n.inventorySku,
                      helperText: l10n.productSkuHelp,
                      helperMaxLines: 2,
                      errorText: _skuError,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cost,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: money,
                      decoration: InputDecoration(labelText: context.l10n.inventoryCostPrice),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: money,
                      decoration: InputDecoration(labelText: l10n.commonPrice),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (existing == null)
                TextField(
                  controller: _openingStock,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.productOpeningStock,
                    helperText: branchName.isEmpty ? null : l10n.productStockInBranch(branchName),
                    errorText: _stockError,
                    prefixIcon: const Icon(Icons.inventory_outlined),
                  ),
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_outlined),
                  title: Text('${l10n.inventoryStockLevel}: ${_stockHere ?? '…'}'),
                  subtitle: branchName.isEmpty ? null : Text(l10n.productStockInBranch(branchName)),
                  trailing: OutlinedButton(
                    onPressed: session.currentBranchId == null
                        ? null
                        : () async {
                            await showStockAdjustDialog(
                              context,
                              ref,
                              storeId: session.store!.id,
                              branchId: session.currentBranchId!,
                              product: existing!,
                              onHand: _stockHere ?? 0,
                            );
                            final s = await ref
                                .read(inventoryRepositoryProvider)
                                .getStockItem(existing!.id, session.currentBranchId!);
                            if (mounted) setState(() => _stockHere = s?.quantityOnHand ?? 0);
                          },
                    child: Text(l10n.inventoryAdjustStock),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wholesale,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: money,
                      decoration: InputDecoration(
                        labelText: l10n.inventoryWholesalePrice,
                        helperText: l10n.commonOptional,
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
                          initialDate: _expiry ?? now.add(const Duration(days: 180)),
                          firstDate: DateTime(now.year - 2),
                          lastDate: DateTime(now.year + 15),
                        );
                        if (picked != null) setState(() => _expiry = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.inventoryExpiryDate,
                          helperText: l10n.commonOptional,
                          suffixIcon: _expiry == null
                              ? const Icon(Icons.event)
                              : IconButton(
                                  icon: const Icon(Icons.clear), onPressed: () => setState(() => _expiry = null)),
                        ),
                        child: Text(_expiry == null ? '—' : AppDateFormat.shortDate(_expiry!)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l10n.inventoryCategories),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  ...widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _taxRateId,
                decoration: InputDecoration(labelText: context.l10n.taxRate),
                items: [
                  DropdownMenuItem(value: null, child: Text(context.l10n.commonNone)),
                  ...widget.taxRates
                      .map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.ratePercent}%)'))),
                ],
                onChanged: (v) => setState(() => _taxRateId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reorder,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: context.l10n.inventoryReorderLevel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: InputDecoration(labelText: l10n.inventoryUnit),
                      items: productUnitOptions
                          .map((code) => DropdownMenuItem(value: code, child: Text(productUnitLabel(context, code))))
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v ?? _unit),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.actionSave),
        ),
      ],
    );
  }
}
