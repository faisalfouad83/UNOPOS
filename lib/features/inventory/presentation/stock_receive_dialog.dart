import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/barcode_input_field.dart';
import '../../auth/domain/session_controller.dart';
import '../../pos/domain/barcode_scan.dart';
import '../domain/inventory_models.dart';
import 'product_thumb.dart';
import '../../../core/widgets/adaptive_row.dart';

/// One product being received.
class _Line {
  _Line(this.product, this.onHand);
  final ProductRecord product;
  final int onHand;
  final quantity = TextEditingController(text: '1');
  final cost = TextEditingController();
  final price = TextEditingController();

  /// Its stock movement is saved; a retry after a later failure (e.g. the
  /// price change) must not add the stock again.
  bool stockRecorded = false;

  void dispose() {
    quantity.dispose();
    cost.dispose();
    price.dispose();
  }
}

/// New goods arrived: add them to the stock of the branch being worked in.
/// Pick each product (scan, or search by name), its quantity, and only if
/// it changed, its new cost and/or selling price — left empty, the prices
/// stay as they are. Each line is recorded as a stock movement.
Future<void> showStockReceiveDialog(BuildContext context, WidgetRef ref) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.currentBranchId == null) return;
  final products = await ref.read(inventoryRepositoryProvider).watchProducts(session.store!.id).first;
  if (!context.mounted) return;
  final saved = await showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _StockReceiveDialog(products: products),
  );
  if (saved != null && saved > 0 && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).stockReceiveDone(saved))),
    );
  }
}

class _StockReceiveDialog extends ConsumerStatefulWidget {
  const _StockReceiveDialog({required this.products});
  final List<ProductRecord> products;

  @override
  ConsumerState<_StockReceiveDialog> createState() => _StockReceiveDialogState();
}

class _StockReceiveDialogState extends ConsumerState<_StockReceiveDialog> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _lines = <_Line>[];
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  List<ProductRecord> get _matches {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.products
        .where(
            (p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q) || (p.barcode ?? '').contains(q))
        .take(6)
        .toList();
  }

  Future<void> _add(ProductRecord product) async {
    final existing = _lines.where((l) => l.product.id == product.id).firstOrNull;
    if (existing != null) {
      // Scanned again: one more of it.
      existing.quantity.text = '${(int.tryParse(existing.quantity.text) ?? 0) + 1}';
    } else {
      final branchId = ref.read(sessionControllerProvider).currentBranchId!;
      int onHand;
      try {
        onHand = (await ref.read(inventoryRepositoryProvider).getStockItem(product.id, branchId))?.quantityOnHand ?? 0;
      } catch (_) {
        onHand = 0;
      }
      if (!mounted) return;
      // Scanned twice while the stock was being looked up.
      final again = _lines.where((l) => l.product.id == product.id).firstOrNull;
      if (again != null) {
        again.quantity.text = '${(int.tryParse(again.quantity.text) ?? 0) + 1}';
      } else {
        _lines.add(_Line(product, onHand));
      }
    }
    setState(() {
      _search.clear();
      _error = null;
    });
    _searchFocus.requestFocus();
  }

  void _onSubmitted(String text) {
    final product = matchScannedProduct(widget.products, text) ?? singleSearchMatch(widget.products, text);
    if (product == null) {
      setState(() => _error = AppLocalizations.of(context).posBarcodeNotFound(text.trim()));
      _searchFocus.requestFocus();
      return;
    }
    _add(product);
  }

  /// Receives with the phone's camera, one product after another (each
  /// scan of the same product counts one more).
  Future<void> _scanWithCamera() async {
    final l10n = AppLocalizations.of(context);
    await scanBarcodesContinuously(
      context,
      onCode: (code) async {
        final product = matchScannedProduct(widget.products, code);
        if (product == null) return l10n.posBarcodeNotFound(code);
        await _add(product);
        return '✓ ${product.name}';
      },
    );
  }

  int? _money(String text) => text.trim().isEmpty ? null : Money.toMinorUnits(double.tryParse(text.trim()) ?? -1);

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    for (final l in _lines) {
      final qty = int.tryParse(l.quantity.text.trim());
      final cost = _money(l.cost.text);
      final price = _money(l.price.text);
      if (qty == null || qty <= 0 || (cost != null && cost < 0) || (price != null && price < 0)) {
        setState(() => _error = l10n.stockReceiveInvalid(l.product.name));
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final session = ref.read(sessionControllerProvider);
    final repo = ref.read(inventoryRepositoryProvider);
    var done = 0;
    try {
      for (final l in _lines) {
        final qty = int.parse(l.quantity.text.trim());
        final newCost = _money(l.cost.text);
        final newPrice = _money(l.price.text);
        final p = l.product;
        if (!l.stockRecorded) {
          await repo.recordStockMovement(
            storeId: p.storeId,
            productId: p.id,
            branchId: session.currentBranchId!,
            type: StockMovementType.purchaseIn,
            quantity: qty,
            unitCostMinorUnits: newCost ?? p.costPriceMinorUnits,
            referenceType: 'STOCK_RECEIPT',
            createdByUserId: session.employee?.id ?? p.storeId,
          );
          l.stockRecorded = true;
        }
        if ((newCost != null && newCost != p.costPriceMinorUnits) ||
            (newPrice != null && newPrice != p.sellPriceMinorUnits)) {
          await repo.updateProduct(
            ProductRecord(
              id: p.id,
              storeId: p.storeId,
              categoryId: p.categoryId,
              sku: p.sku,
              barcode: p.barcode,
              name: p.name,
              unit: p.unit,
              costPriceMinorUnits: newCost ?? p.costPriceMinorUnits,
              sellPriceMinorUnits: newPrice ?? p.sellPriceMinorUnits,
              taxRateId: p.taxRateId,
              reorderLevel: p.reorderLevel,
              imagePath: p.imagePath,
              isActive: p.isActive,
              wholesalePriceMinorUnits: p.wholesalePriceMinorUnits,
              expiryDate: p.expiryDate,
            ),
          );
        }
        done++;
      }
      if (mounted) Navigator.of(context).pop(done);
    } catch (_) {
      // Lines already saved stay saved (and go from the list); the one
      // that stopped keeps its place, without its stock added twice.
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.stockReceivePartial(done, _lines.length);
          for (final l in _lines.take(done)) {
            l.dispose();
          }
          _lines.removeRange(0, done);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final money = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];
    final matches = _matches;

    return AlertDialog(
      title: Text(l10n.stockReceiveTitle),
      content: SizedBox(
        width: 640,
        // Everything scrolls together, so on a phone (with the keyboard
        // open) every line can still be reached.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.stockReceiveHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              TextField(
                controller: _search,
                focusNode: _searchFocus,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: cameraScanAvailable
                      ? IconButton(
                          icon: const Icon(Icons.photo_camera_outlined),
                          tooltip: l10n.posScanCamera,
                          onPressed: _saving ? null : _scanWithCamera,
                        )
                      : const Icon(Icons.qr_code_scanner),
                  errorMaxLines: 3,
                  hintText: l10n.posScanHint,
                  errorText: _error,
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: _onSubmitted,
                onEditingComplete: () {},
              ),
              if (matches.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(top: 4),
                  child: Column(
                    children: [
                      for (final p in matches)
                        ListTile(
                          dense: true,
                          leading: ProductThumb(imagePath: p.imagePath, size: 32),
                          title: Text(p.name),
                          subtitle: Text('${p.barcode ?? p.sku} · ${Money.format(p.sellPriceMinorUnits)}'),
                          onTap: () => _add(p),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (_lines.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.stockReceiveEmpty, textAlign: TextAlign.center),
                )
              else
                for (var i = 0; i < _lines.length; i++)
                  Builder(
                    builder: (context) {
                      final l = _lines[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (i > 0) const Divider(height: 16),
                          Row(
                            children: [
                              ProductThumb(imagePath: l.product.imagePath, size: 32),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${l.product.name} · ${l10n.inventoryStockLevel}: ${l.onHand}',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.actionRemove,
                                icon: const Icon(Icons.close),
                                onPressed: _saving ? null : () => setState(() => _lines.removeAt(i).dispose()),
                              ),
                            ],
                          ),
                          AdaptiveRow(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: l.quantity,
                                  enabled: !l.stockRecorded,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(labelText: l10n.commonQuantity),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: l.cost,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: money,
                                  decoration: InputDecoration(
                                    labelText: l10n.stockReceiveNewCost,
                                    hintText: Money.inputText(l.product.costPriceMinorUnits),
                                    helperText: l10n.stockReceiveKeepIfEmpty,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: l.price,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: money,
                                  decoration: InputDecoration(
                                    labelText: l10n.stockReceiveNewPrice,
                                    hintText: Money.inputText(l.product.sellPriceMinorUnits),
                                    helperText: l10n.stockReceiveKeepIfEmpty,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton.icon(
          onPressed: _saving || _lines.isEmpty ? null : _save,
          icon: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check),
          label: Text(l10n.stockReceiveSave(_lines.length)),
        ),
      ],
    );
  }
}
