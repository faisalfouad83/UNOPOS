import '../../../core/offline/outbox.dart';
import 'inventory_models.dart';

/// Stock changes made on this device and not yet sent (sales, receipts,
/// adjustments) for [branchId], by product id. Positive = taken off the
/// shelf.
Map<String, int> unsyncedStockOut(List<OutboxOp> ops, String branchId) {
  const incoming = {'purchaseIn', 'transferIn', 'adjustmentIn', 'returnIn'};
  final out = <String, int>{};
  void add(String id, int qty) => out[id] = (out[id] ?? 0) + qty;
  for (final op in ops) {
    final p = op.params;
    if (p == null || p['p_branch_id'] != branchId) continue;
    if (op.kind == OutboxKind.checkout) {
      for (final line in (p['p_lines'] as List? ?? const [])) {
        add(line['product_id'] as String, (line['quantity'] as num).toInt());
      }
    } else if (op.kind == OutboxKind.rpc && op.rpc == 'record_stock_movement') {
      final qty = (p['p_quantity'] as num).toInt();
      add(p['p_product_id'] as String, incoming.contains(p['p_type']) ? -qty : qty);
    }
  }
  return out;
}

/// [items] (the server's last figures) with this device's unsent stock
/// changes applied; a product first stocked here gets an entry.
List<StockItemRecord> withUnsyncedStock(
  List<StockItemRecord> items,
  List<OutboxOp> ops, {
  required String storeId,
  required String branchId,
}) {
  final out = unsyncedStockOut(ops, branchId);
  if (out.isEmpty) return items;
  final result = [
    for (final i in items)
      out.containsKey(i.productId)
          ? StockItemRecord(
              id: i.id,
              storeId: i.storeId,
              productId: i.productId,
              branchId: i.branchId,
              quantityOnHand: i.quantityOnHand - out[i.productId]!,
              reservedQuantity: i.reservedQuantity,
            )
          : i,
  ];
  final known = {for (final i in items) i.productId};
  for (final e in out.entries) {
    if (known.contains(e.key)) continue;
    result.add(
      StockItemRecord(
        id: 'local-${e.key}-$branchId',
        storeId: storeId,
        productId: e.key,
        branchId: branchId,
        quantityOnHand: -e.value,
      ),
    );
  }
  return result;
}
