import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/store_settings_provider.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/barcode_input_field.dart';
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
import '../domain/pos_repository.dart';
import 'cart_controller.dart';
import 'checkout_sheet.dart';
import 'loyalty_customer_picker.dart';
import 'pos_stock.dart';
import 'process_return_dialog.dart';
import 'scan_search_field.dart';
import 'sales_history_screen.dart';
import '../../../core/theming/store_themes.dart';

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

/// True while the cart is being held or a held sale resumed: the buttons
/// wait, so a double tap can't hold the same cart twice.
final cartBusyProvider = StateProvider<bool>((ref) => false);

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
            AppBreakpoints.isCompact(MediaQuery.sizeOf(context).width)
                ? IconButton(
                    icon: const Icon(Icons.assignment_return_outlined),
                    tooltip: l10n.returnInvoice,
                    onPressed: () => showReturnInvoiceDialog(context, ref),
                  )
                : TextButton.icon(
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
              final busy = ref.watch(cartBusyProvider);
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
                                    onPressed: busy
                                        ? null
                                        : () async {
                                            final ok = await resumeHeldSale(context, ref, sale);
                                            if (ok && sheetContext.mounted) Navigator.of(sheetContext).pop();
                                          },
                                    child: Text(l10n.posResumeSale),
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
  final busy = ref.read(cartBusyProvider.notifier);
  if (busy.state) return false;
  busy.state = true;
  try {
    return await _holdCurrentCart(context, ref);
  } finally {
    busy.state = false;
  }
}

Future<bool> _holdCurrentCart(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final session = ref.read(sessionControllerProvider);
  final cart = ref.read(cartControllerProvider);
  // Read before waiting: the sheet this was started from may be closed by
  // the time the sale is held, and the cart must still be emptied then.
  final cartController = ref.read(cartControllerProvider.notifier);
  final owner = cartController.owner;
  final useCase = ref.read(completeSaleUseCaseProvider);
  if (cart.isEmpty || session.store == null || session.currentBranchId == null || session.employee == null) {
    return true;
  }
  final replacing = cart.resumingHeldSale;
  try {
    await useCase.holdSale(
      storeId: session.store!.id,
      branchId: session.currentBranchId!,
      cashierId: session.employee!.id,
      customerId: cart.customer?.id,
      lines: cart.pricedLines.map((l) => l.toSaleLineInput()).toList(),
      replacing: replacing,
    );
    if (cartController.owner == owner) cartController.clear();
    messenger.showSnackBar(SnackBar(content: Text(l10n.posSaleHeld)));
    return true;
  } on HeldSaleClosedException {
    // Sold or removed elsewhere: the cart stays, as a sale of its own.
    if (replacing != null) cartController.detachHeldSale(replacing.id);
    messenger.showSnackBar(SnackBar(content: Text(l10n.posHeldSaleDetached), duration: const Duration(seconds: 8)));
    return false;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    return false;
  }
}

/// A held sale is saved as its header and then each line; another till may
/// see it in between. It is complete once its lines add up to its total.
bool heldSaleIsComplete(SaleRecord sale) =>
    sale.lines.isNotEmpty && sale.lines.fold(0, (s, l) => s + l.lineTotalMinorUnits) == sale.grandTotalMinorUnits;

/// Puts a held sale back in the cart exactly as it was suspended. Whatever
/// is in the cart first is suspended itself, so nothing is lost.
Future<bool> resumeHeldSale(BuildContext context, WidgetRef ref, SaleRecord sale) async {
  final busy = ref.read(cartBusyProvider.notifier);
  if (busy.state) return false;
  busy.state = true;
  try {
    return await _resumeHeldSale(context, ref, sale);
  } finally {
    busy.state = false;
  }
}

Future<bool> _resumeHeldSale(BuildContext context, WidgetRef ref, SaleRecord listed) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  // Read before waiting (see holdCurrentCart).
  final cartController = ref.read(cartControllerProvider.notifier);
  final owner = cartController.owner;
  final pos = ref.read(posRepositoryProvider);
  final inventory = ref.read(inventoryRepositoryProvider);
  final debts = ref.read(debtsRepositoryProvider);

  // The sale as it is now, with all its lines: the list may be a moment
  // behind (sold on another till, or still being saved).
  SaleRecord? sale;
  for (var attempt = 0;; attempt++) {
    try {
      sale = await pos.getSale(listed.id);
    } catch (_) {
      sale = null;
    }
    if (sale == null || sale.status != SaleStatus.held || heldSaleIsComplete(sale) || attempt >= 3) break;
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
  if (sale == null || sale.status != SaleStatus.held) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.posHeldSaleClosed)));
    return false;
  }
  if (!heldSaleIsComplete(sale)) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.posHeldSaleIncomplete)));
    return false;
  }

  if (!cartController.isEmpty) {
    if (!context.mounted || !await _holdCurrentCart(context, ref)) return false;
  }
  final products = [...await inventory.watchProducts(sale.storeId).first];
  // Products since taken off the catalog are still part of the held sale.
  for (final id in sale.lines.map((l) => l.productId).toSet()) {
    if (products.any((p) => p.id == id)) continue;
    final product = await inventory.getProduct(id);
    if (product != null) products.add(product);
  }
  final taxRates = await inventory.watchTaxRates(sale.storeId).first;
  final customerId = sale.customerId;
  final customer = customerId == null
      ? null
      : (await debts.watchCustomers(sale.storeId).first).where((c) => c.id == customerId).firstOrNull;
  // Signed out or switched store/branch while loading: leave the new cart alone.
  if (cartController.owner != owner || !cartController.isEmpty) return false;
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
    await _addByCode(code);
  }

  /// Rings up products with the phone's camera, one after another.
  Future<void> _scanWithCamera() async {
    final l10n = AppLocalizations.of(context);
    await scanBarcodesContinuously(
      context,
      onCode: (code) async {
        final product = await _addByCode(code);
        return product == null ? l10n.posBarcodeNotFound(code) : '✓ ${product.name}';
      },
    );
  }

  /// See [_onScan]; returns the product found (null when none).
  Future<ProductRecord?> _addByCode(String code) async {
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
    if (!mounted || ref.read(cartControllerProvider.notifier).owner != owner) return null;
    if (product == null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.posBarcodeNotFound(code)), duration: const Duration(seconds: 3)),
      );
      return null;
    }
    final taxRates = ref.read(taxRatesProvider(storeId)).valueOrNull ??
        await ref.read(inventoryRepositoryProvider).watchTaxRates(storeId).first;
    final rate = taxRates.where((t) => t.id == product!.taxRateId).firstOrNull?.ratePercent ?? 0;
    if (!mounted || ref.read(cartControllerProvider.notifier).owner != owner) return null;
    addToCartWithinStock(context, ref, product, taxRatePercent: rate);
    return product;
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the branch's stock loaded (and current) while the till is open.
    // Listened to, not watched: this screen itself doesn't show stock, and a
    // rebuild of it while a product tile is reading the stock would be a
    // rebuild in the middle of building.
    ref.listen(posStockProvider, (_, __) {});

    final productGrid = _ProductGrid(
      storeId: widget.storeId,
      query: _query,
      search: ScanSearchField(
        controller: _searchController,
        focusNode: _searchFocus,
        hintText: AppLocalizations.of(context).posScanHint,
        onChanged: (v) => setState(() => _query = v),
        onScan: _onScan,
        onCameraScan: _scanWithCamera,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Room for products and the cart side by side (a desktop window or
        // a tablet held sideways); otherwise the products take the screen
        // and the cart is a bar at the bottom that opens over them.
        if (constraints.maxWidth >= 900) {
          return Row(
            children: [
              Expanded(child: productGrid),
              const VerticalDivider(width: 1),
              const SizedBox(width: 370, child: _CartPanel()),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: productGrid),
            const _CartBar(),
          ],
        );
      },
    );
  }
}

/// Takes payment for the cart (after checking the stock once more —
/// another till may have sold some meanwhile). Returns whether the cart
/// was sold (it is empty afterwards).
Future<bool> _startCheckout(BuildContext context, WidgetRef ref) async {
  final storeId = ref.read(sessionControllerProvider).store?.id;
  final cartController = ref.read(cartControllerProvider.notifier);
  final settingsRepository = ref.read(settingsRepositoryProvider);
  if (storeId == null || cartController.isEmpty) return false;
  if (!fitCartToStock(context, ref)) return false;
  final settings = await settingsRepository.ensureSettings(storeId);
  if (!context.mounted) return false;
  await showCheckoutSheet(context, ref, settings: settings);
  return cartController.isEmpty;
}

/// The cart on a phone or a tablet held upright: what is in it and the
/// total, a button that opens it in full, and payment.
class _CartBar extends ConsumerWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);
    final items = cart.lines.fold<int>(0, (s, l) => s + l.quantity);
    return Material(
      elevation: 6,
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openCart(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      children: [
                        Badge(
                          isLabelVisible: items > 0,
                          label: Text('$items'),
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.posCart, style: theme.textTheme.labelMedium),
                              Text(
                                Money.format(cart.grandTotalMinorUnits),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_up),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: cart.isEmpty ? null : () => _startCheckout(context, ref),
                icon: const Icon(Icons.payments_outlined),
                label: Text(l10n.posCheckout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCart(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.85,
        child: _CartPanel(onCheckedOut: () => Navigator.of(sheetContext).maybePop()),
      ),
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
                // As many columns as fit: two on a phone, more on a tablet.
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisExtent: 172,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
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
    final inCart = ref.watch(
      cartControllerProvider.select((c) => c.lines.where((l) => l.product.id == product.id).firstOrNull?.quantity ?? 0),
    );
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
              // How many are already in the cart (the cart may be out of
              // sight on a phone).
              Badge(
                isLabelVisible: inCart > 0,
                label: Text('$inCart'),
                backgroundColor: theme.colorScheme.primary,
                textColor: theme.colorScheme.onPrimary,
                child: ProductThumb(imagePath: product.imagePath, size: 48, radius: 10),
              ),
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
                            ? StatusColors.of(context).warning
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
  const _CartPanel({this.onCheckedOut});

  /// Called once a sale is paid (the cart shown in a sheet closes then).
  final VoidCallback? onCheckedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartControllerProvider);
    final busy = ref.watch(cartBusyProvider);
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
              : LayoutBuilder(
                  builder: (context, constraints) => ListView.builder(
                    itemCount: cart.lines.length,
                    itemBuilder: (context, index) {
                      final line = cart.lines[index];
                      return _CartLineTile(
                        line: line,
                        onHand: stock == null ? null : (stock[line.product.id] ?? 0),
                        canDiscount: canDiscount,
                        keepMargin: keepMargin,
                        narrow: constraints.maxWidth < 400,
                      );
                    },
                  ),
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
                      onPressed: cart.isEmpty || busy || session.store == null || session.currentBranchId == null
                          ? null
                          : () => holdCurrentCart(context, ref),
                      child: busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.posHoldSale),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: cart.isEmpty || busy
                          ? null
                          : () async {
                              final sold = await _startCheckout(context, ref);
                              if (sold && onCheckedOut != null) onCheckedOut!();
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

/// One line of the cart: quantity steppers, price and discount, line total.
/// On a narrow screen (a phone) the name gets its own row and the controls
/// go underneath, instead of squeezing the name into what is left.
class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({
    required this.line,
    required this.onHand,
    required this.canDiscount,
    required this.keepMargin,
    required this.narrow,
  });

  final CartLine line;
  final int? onHand;
  final bool canDiscount;
  final bool keepMargin;
  final bool narrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final atStock = onHand != null && line.quantity >= onHand!;
    final details = [
      Money.format(line.unitPriceMinorUnits),
      if (line.discountAmountMinorUnits > 0) '-${Money.format(line.discountAmountMinorUnits)}',
      if (onHand != null) l10n.posStockBadge(onHand!),
    ].join(' · ');

    final minus = IconButton(
      icon: const Icon(Icons.remove_circle_outline),
      visualDensity: narrow ? VisualDensity.compact : null,
      onPressed: () => setCartQuantityWithinStock(context, ref, line, line.quantity - 1),
    );
    final plus = IconButton(
      icon: const Icon(Icons.add_circle_outline),
      visualDensity: narrow ? VisualDensity.compact : null,
      onPressed: atStock ? null : () => setCartQuantityWithinStock(context, ref, line, line.quantity + 1),
    );
    final quantity = InkWell(
      onTap: () => _showQuantityDialog(context, ref, line),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
    final discount = canDiscount
        ? IconButton(
            icon: Icon(
              Icons.local_offer_outlined,
              color: line.discountAmountMinorUnits > 0 ? theme.colorScheme.primary : null,
            ),
            visualDensity: narrow ? VisualDensity.compact : null,
            tooltip: l10n.posLineDiscount,
            onPressed: () => _showLineDiscountDialog(context, ref, line, keepMargin),
          )
        : null;
    final onTap = canDiscount ? () => _showLineDiscountDialog(context, ref, line, keepMargin) : null;

    if (!narrow) {
      return ListTile(
        onTap: onTap,
        leading: minus,
        title: Row(
          children: [
            Expanded(child: Text(line.product.name, overflow: TextOverflow.ellipsis)),
            quantity,
          ],
        ),
        subtitle: Text(details),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [plus, if (discount != null) discount, Text(Money.format(line.lineTotalMinorUnits))],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(line.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
            Text(details, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                minus,
                quantity,
                plus,
                if (discount != null) discount,
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    Money.format(line.lineTotalMinorUnits),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      // A percent is kept as one, so it follows the quantity afterwards.
      onApply: (isPercent, value) => cart.applyLineDiscount(
        line.product.id,
        isPercent: isPercent,
        value: isPercent ? value : Money.toMinorUnits(value.toDouble()),
        keepMargin: keepMargin,
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
      scrollable: true,
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
