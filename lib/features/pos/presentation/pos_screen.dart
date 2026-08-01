import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../shifts/presentation/close_shift_dialog.dart';
import '../../shifts/presentation/open_shift_dialog.dart';
import '../../shifts/presentation/shift_providers.dart';
import '../domain/pos_models.dart';
import 'cart_controller.dart';
import 'checkout_sheet.dart';

typedef _ProductQueryKey = ({String storeId, String query});
typedef _BranchKey = ({String storeId, String branchId});

final _posProductsProvider = StreamProvider.autoDispose.family<List<ProductRecord>, _ProductQueryKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(key.storeId, searchQuery: key.query.isEmpty ? null : key.query);
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
      icon: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        child: const Icon(Icons.pause_circle_outline),
      ),
      onPressed: () => _showHeldSales(context, ref, held.value ?? const []),
    );
  }

  void _showHeldSales(BuildContext context, WidgetRef ref, List<SaleRecord> heldSales) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.posHeldSales, style: Theme.of(context).textTheme.titleLarge)),
            if (heldSales.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(l10n.posEmptyCart)),
            ...heldSales.map((sale) => ListTile(
                  title: Text((sale.holdLabel?.isNotEmpty ?? false) ? sale.holdLabel! : sale.saleNumber),
                  subtitle: Text(Money.format(sale.grandTotalMinorUnits, currencySymbol: r'$')),
                  trailing: TextButton(
                    child: Text(l10n.posResumeSale),
                    onPressed: () async {
                      final products = await ref.read(inventoryRepositoryProvider).watchProducts(storeId).first;
                      ref.read(cartControllerProvider.notifier).loadHeldSale(sale, products);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PosBody extends ConsumerStatefulWidget {
  const _PosBody({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_PosBody> createState() => _PosBodyState();
}

class _PosBodyState extends ConsumerState<_PosBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = AppBreakpoints.isCompact(width);

    final productGrid = _ProductGrid(
      storeId: widget.storeId,
      query: _query,
      searchController: _searchController,
      onQueryChanged: (v) => setState(() => _query = v),
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
  const _ProductGrid({
    required this.storeId,
    required this.query,
    required this.searchController,
    required this.onQueryChanged,
  });
  final String storeId;
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(_posProductsProvider((storeId: storeId, query: query)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.posSearchProducts,
            ),
            onChanged: onQueryChanged,
          ),
        ),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(l10n.errorGeneric)),
            data: (products) {
              if (products.isEmpty) return Center(child: Text(l10n.errorGeneric));
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
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => ref.read(cartControllerProvider.notifier).addProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(product.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                Money.format(product.sellPriceMinorUnits, currencySymbol: r'$'),
                style: Theme.of(context).textTheme.labelLarge,
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
    final session = ref.watch(sessionControllerProvider);

    return Column(
      children: [
        Expanded(
          child: cart.isEmpty
              ? Center(child: Text(l10n.posEmptyCart))
              : ListView.builder(
                  itemCount: cart.lines.length,
                  itemBuilder: (context, index) {
                    final line = cart.lines[index];
                    return ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            ref.read(cartControllerProvider.notifier).setQuantity(line.product.id, line.quantity - 1),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(line.product.name, overflow: TextOverflow.ellipsis)),
                          Text('${line.quantity}'),
                        ],
                      ),
                      subtitle: Text(Money.format(line.unitPriceMinorUnits, currencySymbol: r'$')),
                      trailing: SizedBox(
                        width: 96,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  ref.read(cartControllerProvider.notifier).setQuantity(line.product.id, line.quantity + 1),
                            ),
                            Text(Money.format(line.lineTotalMinorUnits, currencySymbol: r'$')),
                          ],
                        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.commonTotal, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    Money.format(cart.grandTotalMinorUnits, currencySymbol: r'$'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: cart.isEmpty || session.store == null || session.currentBranchId == null
                          ? null
                          : () async {
                              await ref.read(completeSaleUseCaseProvider).holdSale(
                                    storeId: session.store!.id,
                                    branchId: session.currentBranchId!,
                                    cashierId: session.employee!.id,
                                    lines: cart.lines.map((l) => l.toSaleLineInput()).toList(),
                                  );
                              ref.read(cartControllerProvider.notifier).clear();
                            },
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
                              final settings = await ref.read(settingsRepositoryProvider).ensureSettings(session.store!.id);
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
