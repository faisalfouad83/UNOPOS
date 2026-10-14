import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/store_settings_provider.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../inventory/presentation/discounts_section.dart';
import '../../inventory/presentation/product_thumb.dart';
import '../../inventory/presentation/tax_rates_section.dart';
import '../../shifts/presentation/close_shift_dialog.dart';
import '../../shifts/presentation/open_shift_dialog.dart';
import '../../shifts/presentation/shift_providers.dart';
import '../domain/barcode_scan.dart';
import '../domain/pos_models.dart';
import 'cart_controller.dart';
import 'checkout_sheet.dart';
import 'loyalty_customer_picker.dart';
import 'pos_stock.dart';
import 'process_return_dialog.dart';
import 'scan_search_field.dart';
import 'sales_history_screen.dart';

typedef _ProductQueryKey = ({String storeId, String query});
typedef _BranchKey = ({String storeId, String branchId});

final _posProductsProvider = StreamProvider.autoDispose.family<List<ProductRecord>, _ProductQueryKey>((ref, key) {
  return ref
      .watch(inventoryRepositoryProvider)
      .watchProducts(key.storeId, searchQuery: key.query.isEmpty ? null : key.query);
});

final _heldSalesProvider = StreamProvider.autoDispose.family<List<SaleRecord>, _BranchKey>((ref, key) {
  return ref.watch(posRepositoryProvider).watchHeldSales(key.storeId, key.branchId);
});

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);

    if (session.store == null || session.employee == null || session.currentBranchId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final storeId = session.store!.id;
    final branchId = session.currentBranchId!;
    final cashierId = session.employee!.id;

    final shiftAsync = ref.watch(openShiftProvider((storeId: storeId, cashierId: cashierId)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posTitle),
        actions: [
          shiftAsync.maybeWhen(
            data: (shift) => shift == null
                ? const SizedBox.shrink()
                : Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.point_of_sale),
                      tooltip: l10n.posShiftClose,
                      onPressed: () => showCloseShiftDialog(context, ref, shift),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          if (session.employee!.can(AppPermission.processReturns))
            TextButton.icon(
              icon: const Icon(Icons.assignment_return_outlined),
              label: Text(l10n.returnInvoice),
              onPressed: () => showReturnInvoiceDialog(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: l10n.posSalesHistory,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => SalesHistoryScreen(storeId: storeId))),
          ),
          _HeldSalesButton(storeId: storeId, branchId: branchId),
        ],
      ),
      body: shiftAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (shift) {
          if (shift == null) {
            return Builder(
              builder: (context) => Center(
                child: FilledButton.icon(
                  onPressed: () => showOpenShiftDialog(context, ref),
                  icon: const Icon(Icons.point_of_sale),
                  label: Text(l10n.posShiftOpen),
                ),
              ),
            );
          }
          return _PosBody(storeId: storeId);
        },
      ),
    );
  }
}

class _HeldSalesButton extends ConsumerWidget {
  const _HeldSalesButton({required this.storeId, required this.branchId});
  final String storeId;
  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final held = ref.watch(_heldSalesProvider((storeId: storeId, branchId: branchId)));
    final count = held.maybeWhen(data: (list) => list.length, orElse: () => 0);

    return IconButton(
      tooltip: l10n.posHeldSales,
      icon: Badge(label: Text('$count'), isLabelVisible: count > 0, child: const Icon(Icons.pause_circle_outline)),
      onPressed: () => _showHeldSales(context, ref, held.value ?? const []),
    );
  }

  void _showHeldSales(BuildContext context, WidgetRef ref, List<SaleRecord> heldSales) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75),
          child: Consumer(
            builder: (context, ref, _) {
              // Live list: a sale resumed or sold on another till drops out.
              final live = ref.watch(_heldSalesProvider((storeId: storeId, branchId: branchId))).value ?? heldSales;
              final inCart = ref.watch(cartControllerProvider.select((c) => c.resumingHeldSale?.id));
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.posHeldSales, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  if (live.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(l10n.posEmptyCart)),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final sale in live)
                          ListTile(
                            leading: const Icon(Icons.pause_circle_outline),
                            title: Text((sale.holdLabel?.isNotEmpty ?? false) ? sale.holdLabel! : sale.saleNumber),
                            subtitle: Text(
                              '${AppDateFormat.dateTime(sale.createdAt)} · '
                              '${l10n.posHeldItems(sale.lines.fold(0, (s, l) => s + l.quantity))} · '
                              '${Money.format(sale.grandTotalMinorUnits)}',
                            ),
                            trailing: sale.id == inCart
                                ? Chip(label: Text(l10n.posHeldInCart))
                                : FilledButton.tonal(
                                    child: Text(l10n.posResumeSale),
                                    onPressed: () async {
                                      final ok = await resumeHeldSale(context, ref, sale);
                                      if (ok && sheetContext.mounted) Navigator.of(sheetContext).pop();
                                    },
                                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Suspends what is in the cart. A cart resumed from a held sale is saved
/// back into that same held sale (same number, same place in the list), so
/// suspending again never makes a copy. Returns false if it failed.
Future<bool> holdCurrentCart(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final session = ref.read(sessionControllerProvider);
  final cart = ref.read(cartControllerProvider);
  if (cart.isEmpty || session.store == null || session.currentBranchId == null || session.employee == null) {
    return true;
  }
  try {
    await ref.read(completeSaleUseCaseProvider).holdSale(
          storeId: session.store!.id,
          branchId: session.currentBranchId!,
          cashierId: session.employee!.id,
          customerId: cart.customer?.id,
          lines: cart.pricedLines.map((l) => l.toSaleLineInput()).toList(),
          replacing: cart.resumingHeldSale,
        );
    ref.read(cartControllerProvider.notifier).clear();
    messenger.showSnackBar(SnackBar(content: Text(l10n.posSaleHeld)));
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    return false;
  }
}

/// Puts a held sale back in the cart exactly as it was suspended. Whatever
/// is in the cart first is suspended itself, so nothing is lost.
Future<bool> resumeHeldSale(BuildContext context, WidgetRef ref, SaleRecord sale) async {
  final cartController = ref.read(cartControllerProvider.notifier);
  final owner = cartController.owner;
  if (!ref.read(cartControllerProvider).isEmpty) {
    if (!await holdCurrentCart(context, ref)) return false;
  }
  final inventory = ref.read(inventoryRepositoryProvider);
  final products = [...await inventory.watchProducts(sale.storeId).first];
  // Products since taken off the catalog are still part of the held sale.
  for (final id in sale.lines.map((l) => l.productId).toSet()) {
    if (products.any((p) => p.id == id)) continue;
    final product = await inventory.getProduct(id);
    if (product != null) products.add(product);
  }
  final taxRates = await ref.read(inventoryRepositoryProvider).watchTaxRates(sale.storeId).first;
  final customer = sale.customerId == null
      ? null
      : (await ref.read(debtsRepositoryProvider).watchCustomers(sale.storeId).first)
          .where((c) => c.id == sale.customerId)
          .firstOrNull;
  // Signed out or switched store/branch while loading: leave the new cart alone.
  if (cartController.owner != owner || !ref.read(cartControllerProvider).isEmpty) return false;
  cartController.loadHeldSale(
    sale,
    products,
    taxPercentById: {for (final t in taxRates) t.id: t.ratePercent},
    customer: customer,
  );
  // Stock may have run low since the sale was held.
  if (context.mounted) fitCartToStock(context, ref);
  return true;
}

class _PosBody extends ConsumerStatefulWidget {
  const _PosBody({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_PosBody> createState() => _PosBodyState();
}

class _PosBodyState extends ConsumerState<_PosBody> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// A scanned code, or text typed + Enter: add the matching product to the
  /// cart. Unknown codes leave the cart untouched and just say so.
  Future<void> _onScan(String code) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final storeId = widget.storeId;
    final owner = ref.read(cartControllerProvider.notifier).owner;
    final products = ref.read(_posProductsProvider((storeId: storeId, query: ''))).valueOrNull ??
        await ref.read(inventoryRepositoryProvider).watchProducts(storeId).first;
    var product = matchScannedProduct(products, code);
    if (product == null) {
      // Not in the list loaded on this till (e.g. added a moment ago).
      try {
        product = await ref.read(inventoryRepositoryProvider).findByBarcode(storeId, code);
      } catch (_) {}
    }
    product ??= singleSearchMatch(products, code);
    if (!mounted || ref.read(cartControllerProvider.notifier).owner != owner) return;
    if (product == null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.posBarcodeNotFound(code)), duration: const Duration(seconds: 3)),
      );
      return;
    }
    final taxRates = ref.read(taxRatesProvider(storeId)).valueOrNull ??
        await ref.read(inventoryRepositoryProvider).watchTaxRates(storeId).first;
    final rate = taxRates.where((t) => t.id == product!.taxRateId).firstOrNull?.ratePercent ?? 0;
    if (!mounted || ref.read(cartControllerProvider.notifier).owner != owner) return;
    addToCartWithinStock(context, ref, product, taxRatePercent: rate);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the branch's stock loaded (and current) while the till is open.
    ref.watch(posStockProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = AppBreakpoints.isCompact(width);

    final productGrid = _ProductGrid(
      storeId: widget.storeId,
      query: _query,
      search: ScanSearchField(
        controller: _searchController,
        focusNode: _searchFocus,
        hintText: AppLocalizations.of(context).posScanHint,
        onChanged: (v) => setState(() => _query = v),
        onScan: _onScan,
      ),
    );
    const cartPanel = _CartPanel();

    if (isCompact) {
      return Column(
        children: [
          Expanded(flex: 3, child: productGrid),
          const Divider(height: 1),
          Expanded(flex: 2, child: cartPanel),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: productGrid),
        const VerticalDivider(width: 1),
        const SizedBox(width: 380, child: cartPanel),
      ],
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.storeId, required this.query, required this.search});
  final String storeId;
  final String query;
  final Widget search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(_posProductsProvider((storeId: storeId, query: query)));

    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: search),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(l10n.errorGeneric)),
            data: (products) {
              if (products.isEmpty) return Center(child: Text(l10n.posNoProductsFound));
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductTile(product: product);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});
  final ProductRecord product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxRates = ref.watch(taxRatesProvider(product.storeId)).value ?? const [];
    final wholesale = ref.watch(cartControllerProvider.select((c) => c.wholesale));
    final stock = ref.watch(posStockProvider.select((s) => s == null ? null : (s[product.id] ?? 0)));
    final out = stock != null && stock <= 0;
    final theme = Theme.of(context);
    final taxRatePercent = product.taxRateId == null
        ? 0.0
        : (taxRates.where((t) => t.id == product.taxRateId).isEmpty
            ? 0.0
            : taxRates.firstWhere((t) => t.id == product.taxRateId).ratePercent);

    return Material(
      color: out ? theme.colorScheme.errorContainer.withValues(alpha: 0.35) : theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => addToCartWithinStock(context, ref, product, taxRatePercent: taxRatePercent),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProductThumb(imagePath: product.imagePath, size: 48, radius: 10),
              const SizedBox(height: 8),
              Text(product.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                Money.format(CartLine.unitPriceFor(product, wholesale: wholesale)),
                style: theme.textTheme.labelLarge,
              ),
              if (stock != null)
                Text(
                  out
                      ? AppLocalizations.of(context).posStockOutBadge
                      : AppLocalizations.of(context).posStockBadge(stock),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: out
                        ? theme.colorScheme.error
                        : stock <= product.reorderLevel
                            ? Colors.orange.shade800
                            : theme.colorScheme.onSurfaceVariant,
                    fontWeight: out ? FontWeight.bold : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartControllerProvider);
    final stock = ref.watch(posStockProvider);
    final session = ref.watch(sessionControllerProvider);
    final storeSettings = ref.watch(currentStoreSettingsProvider).valueOrNull;
    final canDiscount = session.employee?.can(AppPermission.giveDiscount) ?? false;
    final keepMargin = storeSettings?.fullDiscountKeepsMargin ?? false;
    final rate = storeSettings == null
        ? null
        : ExchangeRate(storeCurrency: Money.currency, iqdPerUsd: storeSettings.usdExchangeRate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                avatar: const Icon(Icons.local_shipping_outlined, size: 18),
                label: Text(l10n.posWholesalePrices),
                selected: cart.wholesale,
                onSelected: (on) => ref.read(cartControllerProvider.notifier).setWholesale(on),
              ),
              InputChip(
                avatar: Icon(cart.customer == null ? Icons.person_outline : Icons.person, size: 18),
                label: Text(cart.customer?.name ?? l10n.customerWalkIn),
                onPressed: session.store == null
                    ? null
                    : () async {
                        final picked = await showLoyaltyCustomerPicker(
                          context,
                          ref,
                          session.store!.id,
                          showPoints: storeSettings?.loyaltyEnabled ?? false,
                        );
                        if (picked != null) ref.read(cartControllerProvider.notifier).setCustomer(picked);
                      },
                onDeleted:
                    cart.customer == null ? null : () => ref.read(cartControllerProvider.notifier).setCustomer(null),
              ),
              if (cart.resumingHeldSale != null)
                Chip(
                  avatar: const Icon(Icons.play_circle_outline, size: 18),
                  label: Text(cart.resumingHeldSale!.saleNumber),
                ),
            ],
          ),
        ),
        Expanded(
          child: cart.isEmpty
              ? Center(child: Text(l10n.posEmptyCart))
              : ListView.builder(
                  itemCount: cart.lines.length,
                  itemBuilder: (context, index) {
                    final line = cart.lines[index];
                    final onHand = stock == null ? null : (stock[line.product.id] ?? 0);
                    return ListTile(
                      onTap: canDiscount ? () => _showLineDiscountDialog(context, ref, line, keepMargin) : null,
                      leading: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setCartQuantityWithinStock(context, ref, line, line.quantity - 1),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(line.product.name, overflow: TextOverflow.ellipsis)),
                          InkWell(
                            onTap: () => _showQuantityDialog(context, ref, line),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        [
                          Money.format(line.unitPriceMinorUnits),
                          if (line.discountAmountMinorUnits > 0) '-${Money.format(line.discountAmountMinorUnits)}',
                          if (onHand != null) l10n.posStockBadge(onHand),
                        ].join(' · '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: onHand != null && line.quantity >= onHand
                                ? null
                                : () => setCartQuantityWithinStock(context, ref, line, line.quantity + 1),
                          ),
                          if (canDiscount)
                            IconButton(
                              icon: Icon(
                                Icons.local_offer_outlined,
                                color: line.discountAmountMinorUnits > 0 ? Theme.of(context).colorScheme.primary : null,
                              ),
                              tooltip: l10n.posLineDiscount,
                              onPressed: () => _showLineDiscountDialog(context, ref, line, keepMargin),
                            ),
                          Text(Money.format(line.lineTotalMinorUnits)),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canDiscount && !cart.isEmpty)
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.discount_outlined),
                      label: Text(l10n.posInvoiceDiscount),
                      onPressed: () => _showInvoiceDiscountDialog(context, ref, cart, keepMargin),
                    ),
                    const Spacer(),
                    if (cart.invoiceDiscountMinorUnits > 0)
                      Text(
                        '-${Money.format(cart.invoiceDiscountMinorUnits)}',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.commonTotal, style: Theme.of(context).textTheme.titleMedium),
                  Text(Money.format(cart.grandTotalMinorUnits), style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              if (rate != null && rate.isSet && cart.grandTotalMinorUnits > 0)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '≈ ${rate.foreign.format(rate.toForeign(cart.grandTotalMinorUnits))}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: cart.isEmpty || session.store == null || session.currentBranchId == null
                          ? null
                          : () => holdCurrentCart(context, ref),
                      child: Text(l10n.posHoldSale),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () async {
                              // Another till may have sold some meanwhile.
                              if (!fitCartToStock(context, ref)) return;
                              final settings =
                                  await ref.read(settingsRepositoryProvider).ensureSettings(session.store!.id);
                              if (context.mounted) {
                                await showCheckoutSheet(context, ref, settings: settings);
                              }
                            },
                      child: Text(l10n.posCheckout),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Type a line's quantity straight in, kept within the branch's stock.
Future<void> _showQuantityDialog(BuildContext context, WidgetRef ref, CartLine line) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: '${line.quantity}');
  final available = stockOnHand(ref, line.product.id);
  final quantity = await showDialog<int>(
    context: context,
    builder: (context) {
      void submit() => Navigator.of(context).pop(int.tryParse(controller.text.trim()));
      return AlertDialog(
        title: Text(line.product.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.posSetQuantity,
            helperText: available == null ? null : l10n.posStockBadge(available),
          ),
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: submit, child: Text(l10n.actionSave)),
        ],
      );
    },
  );
  controller.dispose();
  if (quantity == null || !context.mounted) return;
  setCartQuantityWithinStock(context, ref, line, quantity);
}

/// Discount on one cart line: one of the store's saved discounts, or a
/// percent / amount the cashier types for this sale.
Future<void> _showLineDiscountDialog(BuildContext context, WidgetRef ref, CartLine line, bool keepMargin) async {
  final storeId = ref.read(sessionControllerProvider).store?.id;
  if (storeId == null) return;
  final discounts = await ref.read(discountsProvider(storeId).future);
  if (!context.mounted) return;
  final cart = ref.read(cartControllerProvider.notifier);
  await showDialog<void>(
    context: context,
    builder: (context) => _DiscountDialog(
      title: line.product.name,
      baseMinorUnits: line.grossMinorUnits,
      presets: discounts,
      hasDiscount: line.discountAmountMinorUnits > 0,
      onApply: (isPercent, value) => cart.setLineDiscount(
        line.product.id,
        line.discountFor(
          isPercent: isPercent,
          value: isPercent ? value : Money.toMinorUnits(value.toDouble()),
          keepMargin: keepMargin,
        ),
      ),
      onRemove: () => cart.setLineDiscount(line.product.id, 0),
    ),
  );
}

/// Discount on the whole invoice, spread across the lines.
Future<void> _showInvoiceDiscountDialog(BuildContext context, WidgetRef ref, CartState cart, bool keepMargin) async {
  final l10n = AppLocalizations.of(context);
  final controller = ref.read(cartControllerProvider.notifier);
  final base = cart.lines.fold(0, (s, l) => s + l.grossMinorUnits - l.discountAmountMinorUnits);
  await showDialog<void>(
    context: context,
    builder: (context) => _DiscountDialog(
      title: l10n.posInvoiceDiscount,
      baseMinorUnits: base,
      presets: const [],
      hasDiscount: cart.invoiceDiscount != null,
      onApply: (isPercent, value) => controller.setInvoiceDiscount(
        isPercent
            ? InvoiceDiscount.percent(value, keepMargin: keepMargin)
            : InvoiceDiscount.amount(Money.toMinorUnits(value.toDouble()), keepMargin: keepMargin),
      ),
      onRemove: () => controller.setInvoiceDiscount(null),
    ),
  );
}

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog({
    required this.title,
    required this.baseMinorUnits,
    required this.presets,
    required this.hasDiscount,
    required this.onApply,
    required this.onRemove,
  });

  final String title;
  final int baseMinorUnits;
  final List<DiscountRecord> presets;
  final bool hasDiscount;

  /// [value] is a percent, or an amount in major units (as typed).
  final void Function(bool isPercent, num value) onApply;
  final VoidCallback onRemove;

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  bool _percent = true;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(bool isPercent, num value) {
    widget.onApply(isPercent, value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typed = double.tryParse(_controller.text) ?? 0;
    final preview = _percent
        ? (widget.baseMinorUnits * typed.clamp(0, 100) / 100).round()
        : Money.toMinorUnits(typed).clamp(0, widget.baseMinorUnits);
    return AlertDialog(
      title: Text('${l10n.commonDiscount}: ${widget.title}'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: [
                const ButtonSegment(value: true, label: Text('%')),
                ButtonSegment(value: false, label: Text(Money.currency.code)),
              ],
              selected: {_percent},
              onSelectionChanged: (s) => setState(() => _percent = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: InputDecoration(
                labelText: _percent ? l10n.posDiscountPercent : l10n.posDiscountAmount,
                helperText: typed > 0 ? '-${Money.format(preview)}' : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _apply(_percent, typed),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in const [5, 10, 15, 20, 50, 100])
                  ActionChip(label: Text('$p%'), onPressed: () => _apply(true, p)),
              ],
            ),
            if (widget.presets.isNotEmpty) ...[
              const Divider(),
              for (final d in widget.presets)
                ListTile(
                  dense: true,
                  title: Text(d.name),
                  subtitle: Text(d.type == DiscountType.percentOff ? '${d.value}%' : Money.format(d.value)),
                  onTap: () => d.type == DiscountType.percentOff
                      ? _apply(true, d.value)
                      : _apply(false, Money.toMajorUnits(d.value)),
                ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.hasDiscount)
          TextButton(
            onPressed: () {
              widget.onRemove();
              Navigator.of(context).pop();
            },
            child: Text(l10n.posRemoveDiscount),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: typed > 0 ? () => _apply(_percent, typed) : null, child: Text(l10n.actionConfirm)),
      ],
    );
  }
}
