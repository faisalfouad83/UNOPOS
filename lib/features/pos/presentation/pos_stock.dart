import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import '../data/offline_sale_sync.dart';
import 'cart_controller.dart';

typedef _BranchKey = ({String storeId, String branchId});

final _branchStockProvider = StreamProvider.autoDispose.family<List<StockItemRecord>, _BranchKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchStock(key.storeId, key.branchId);
});

/// Quantities sold on this till while offline and not yet sent: the server
/// hasn't taken them off its stock yet, so the till does.
final _unsyncedSoldProvider = FutureProvider.autoDispose.family<Map<String, int>, String>((ref, branchId) async {
  ref.watch(offlineSaleSyncProvider.select((s) => s.pending));
  final sold = <String, int>{};
  for (final sale in await ref.watch(offlineSaleQueueProvider).all()) {
    if (sale.params['p_branch_id'] != branchId) continue;
    for (final line in (sale.params['p_lines'] as List? ?? const [])) {
      final id = line['product_id'] as String;
      sold[id] = (sold[id] ?? 0) + (line['quantity'] as num).toInt();
    }
  }
  return sold;
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
  final stock = ref.watch(_branchStockProvider(key)).valueOrNull;
  if (stock == null) return null;
  final unsynced = ref.watch(_unsyncedSoldProvider(key.branchId)).valueOrNull ?? const {};
  return {for (final s in stock) s.productId: s.quantityOnHand - (unsynced[s.productId] ?? 0)};
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
      backgroundColor: result == StockCheck.ok ? (left <= 0 ? Colors.orange.shade800 : null) : scheme.error,
      duration: Duration(milliseconds: result == StockCheck.ok ? 1500 : 3000),
    ),
  );
}
