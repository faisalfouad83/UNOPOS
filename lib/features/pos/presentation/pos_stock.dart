import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theming/store_themes.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import 'cart_controller.dart';

typedef _BranchKey = ({String storeId, String branchId});

final _branchStockProvider = StreamProvider.autoDispose.family<List<StockItemRecord>, _BranchKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchStock(key.storeId, key.branchId);
});

/// What the current branch has on hand, by product id (a product with no
/// stock record has none). Null until the first copy has loaded — the till
/// doesn't block sales on a figure it doesn't have yet.
final posStockProvider = Provider.autoDispose<Map<String, int>?>((ref) {
  final key = ref.watch(
    sessionControllerProvider.select(
      (s) => s.store == null || s.currentBranchId == null ? null : (storeId: s.store!.id, branchId: s.currentBranchId!),
    ),
  );
  if (key == null) return null;
  // Already includes this device's unsent sales and stock changes.
  final stock = ref.watch(_branchStockProvider(key)).valueOrNull;
  if (stock == null) return null;
  return {for (final s in stock) s.productId: s.quantityOnHand};
});

/// On hand for [productId]; null when stock hasn't loaded yet.
int? stockOnHand(WidgetRef ref, String productId) {
  final stock = ref.read(posStockProvider);
  return stock == null ? null : (stock[productId] ?? 0);
}

/// Adds [product] to the cart within the branch's stock and tells the
/// cashier how many are left (or that it ran out).
void addToCartWithinStock(
  BuildContext context,
  WidgetRef ref,
  ProductRecord product, {
  double taxRatePercent = 0,
}) {
  final available = stockOnHand(ref, product.id);
  final result = ref
      .read(cartControllerProvider.notifier)
      .addProduct(product, taxRatePercent: taxRatePercent, available: available);
  if (available == null) return;
  final inCart =
      ref.read(cartControllerProvider).lines.where((l) => l.product.id == product.id).firstOrNull?.quantity ?? 0;
  _tellStock(context, product.name, result, available: available, left: available - inCart);
}

/// Sets a cart line's quantity, never above the branch's stock.
void setCartQuantityWithinStock(BuildContext context, WidgetRef ref, CartLine line, int quantity) {
  final available = stockOnHand(ref, line.product.id);
  final result = ref
      .read(cartControllerProvider.notifier)
      .setQuantity(line.product.id, quantity, available: quantity > line.quantity ? available : null);
  if (result != StockCheck.ok && available != null) {
    _tellStock(context, line.product.name, result, available: available, left: 0);
  }
}

/// Lowers cart lines to what is on hand now (another till may have sold
/// some meanwhile). Returns false — after telling the cashier — when
/// anything had to change, so they can look before taking payment.
bool fitCartToStock(BuildContext context, WidgetRef ref) {
  final stock = ref.read(posStockProvider);
  if (stock == null) return true;
  final changed = ref.read(cartControllerProvider.notifier).fitToStock(stock);
  if (changed.isEmpty) return true;
  final l10n = AppLocalizations.of(context);
  final names = changed.map((l) => '${l.product.name} (${stock[l.product.id] ?? 0})').join('، ');
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.posStockCartAdjusted(names)),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 6),
    ),
  );
  return false;
}

void _tellStock(BuildContext context, String name, StockCheck result, {required int available, required int left}) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  final text = switch (result) {
    StockCheck.outOfStock => l10n.posStockOut(name),
    StockCheck.capped => l10n.posStockMaxReached(name, available),
    StockCheck.ok => l10n.posStockLeft(name, left),
  };
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: result == StockCheck.ok ? (left <= 0 ? StatusColors.of(context).warning : null) : scheme.error,
      duration: Duration(milliseconds: result == StockCheck.ok ? 1500 : 3000),
    ),
  );
}
