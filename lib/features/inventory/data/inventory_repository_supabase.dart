import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';
import '../domain/stock_overlay.dart';

import '../domain/inventory_models.dart';
import '../domain/inventory_repository.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  SupabaseInventoryRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

  static String _now() => DateTime.now().toUtc().toIso8601String();

  CategoryRecord _mapCategory(Map<String, dynamic> row) => CategoryRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        parentCategoryId: row['parent_category_id'] as String?,
      );

  TaxRateRecord _mapTaxRate(Map<String, dynamic> row) => TaxRateRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        ratePercent: (row['rate_percent'] as num).toDouble(),
        isDefault: row['is_default'] as bool? ?? false,
      );

  ProductRecord _mapProduct(Map<String, dynamic> row) => ProductRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        categoryId: row['category_id'] as String?,
        sku: row['sku'] as String,
        barcode: row['barcode'] as String?,
        name: row['name'] as String,
        unit: row['unit'] as String? ?? 'pcs',
        costPriceMinorUnits: (row['cost_price_minor_units'] as num?)?.toInt() ?? 0,
        sellPriceMinorUnits: (row['sell_price_minor_units'] as num?)?.toInt() ?? 0,
        taxRateId: row['tax_rate_id'] as String?,
        reorderLevel: (row['reorder_level'] as num?)?.toInt() ?? 0,
        imagePath: row['image_path'] as String?,
        isActive: row['is_active'] as bool? ?? true,
        wholesalePriceMinorUnits: (row['wholesale_price_minor_units'] as num?)?.toInt(),
        expiryDate: row['expiry_date'] == null ? null : DateTime.parse(row['expiry_date'] as String).toLocal(),
      );

  static String? _dateOnly(DateTime? d) => d == null
      ? null
      : '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  StockItemRecord _mapStockItem(Map<String, dynamic> row) => StockItemRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        productId: row['product_id'] as String,
        branchId: row['branch_id'] as String,
        quantityOnHand: (row['quantity_on_hand'] as num?)?.toInt() ?? 0,
        reservedQuantity: (row['reserved_quantity'] as num?)?.toInt() ?? 0,
      );

  DiscountRecord _mapDiscount(Map<String, dynamic> row) => DiscountRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        type: row['type'] == 'amountOff' ? DiscountType.amountOff : DiscountType.percentOff,
        value: (row['value'] as num).toInt(),
        appliedScope: row['applied_scope'] as String? ?? 'cart',
        scopeTargetId: row['scope_target_id'] as String?,
        startDate: row['start_date'] == null ? null : DateTime.parse(row['start_date'] as String).toLocal(),
        endDate: row['end_date'] == null ? null : DateTime.parse(row['end_date'] as String).toLocal(),
        isActive: row['is_active'] as bool? ?? true,
      );

  PurchaseOrderRecord _mapPo(Map<String, dynamic> row) => PurchaseOrderRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        supplierId: row['supplier_id'] as String,
        status: row['status'] as String? ?? 'draft',
        orderDate: DateTime.parse(row['order_date'] as String).toLocal(),
        expectedDate: row['expected_date'] == null ? null : DateTime.parse(row['expected_date'] as String).toLocal(),
        totalCostMinorUnits: (row['total_cost_minor_units'] as num?)?.toInt() ?? 0,
        paidImmediately: row['paid_immediately'] as bool? ?? false,
      );

  @override
  Future<CategoryRecord> createCategory(String storeId, String name, {String? parentCategoryId}) async {
    final row = await _writer.insert('categories', {
      'store_id': storeId,
      'name': name,
      'parent_category_id': parentCategoryId,
    });
    return _mapCategory(row);
  }

  @override
  Stream<List<CategoryRecord>> watchCategories(String storeId) {
    return resilientRows(
      'categories.$storeId',
      () => _client.from('categories').stream(primaryKey: ['id']),
      table: 'categories',
    ).map((rows) => rows.map(_mapCategory).toList());
  }

  @override
  Future<TaxRateRecord> createTaxRate(String storeId, String name, double ratePercent, {bool isDefault = false}) async {
    if (isDefault) {
      await _writer.update('tax_rates', {'is_default': false}, column: 'store_id', value: storeId);
    }
    final row = await _writer.insert('tax_rates', {
      'store_id': storeId,
      'name': name,
      'rate_percent': ratePercent,
      'is_default': isDefault,
    });
    return _mapTaxRate(row);
  }

  @override
  Stream<List<TaxRateRecord>> watchTaxRates(String storeId) {
    return resilientRows(
      'tax_rates.$storeId',
      () => _client.from('tax_rates').stream(primaryKey: ['id']),
      table: 'tax_rates',
    ).map((rows) => rows.map(_mapTaxRate).toList());
  }

  @override
  Future<ProductRecord> createProduct(ProductRecord product) async {
    final row = await _writer.insert('products', {
      if (product.id.isNotEmpty) 'id': product.id,
      'is_active': true,
      'store_id': product.storeId,
      'category_id': product.categoryId,
      'sku': product.sku,
      'barcode': product.barcode,
      'name': product.name,
      'unit': product.unit,
      'cost_price_minor_units': product.costPriceMinorUnits,
      'sell_price_minor_units': product.sellPriceMinorUnits,
      'tax_rate_id': product.taxRateId,
      'reorder_level': product.reorderLevel,
      'image_path': product.imagePath,
      'wholesale_price_minor_units': product.wholesalePriceMinorUnits,
      'expiry_date': _dateOnly(product.expiryDate),
    });
    return _mapProduct(row);
  }

  @override
  Future<void> updateProduct(ProductRecord product) async {
    await _writer.update(
        'products',
        {
          'category_id': product.categoryId,
          'sku': product.sku,
          'barcode': product.barcode,
          'name': product.name,
          'unit': product.unit,
          'cost_price_minor_units': product.costPriceMinorUnits,
          'sell_price_minor_units': product.sellPriceMinorUnits,
          'tax_rate_id': product.taxRateId,
          'reorder_level': product.reorderLevel,
          'image_path': product.imagePath,
          'is_active': product.isActive,
          'wholesale_price_minor_units': product.wholesalePriceMinorUnits,
          'expiry_date': _dateOnly(product.expiryDate),
        },
        value: product.id);
  }

  @override
  Future<void> setProductActive(String productId, bool isActive) async {
    await _writer.update('products', {'is_active': isActive}, value: productId);
  }

  @override
  Stream<List<ProductRecord>> watchProducts(String storeId, {String? categoryId, String? searchQuery}) {
    // .stream() supports only one server-side filter. It goes to store_id,
    // not is_active: a filtered stream never delivers the change that
    // takes a row out of the filter, so a product switched off would stay
    // on screen. is_active, categoryId and searchQuery are applied below.
    return resilientRows(
      'products.$storeId',
      () => _client.from('products').stream(primaryKey: ['id']).eq('store_id', storeId).order('name'),
      table: 'products',
      where: (r) => r['is_active'] != false && r['store_id'] == storeId,
    ).map((rows) {
      var filtered = rows.where((r) => r['is_active'] != false).toList();
      if (categoryId != null) {
        filtered = filtered.where((r) => r['category_id'] == categoryId).toList();
      }
      final q = searchQuery?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        filtered = filtered.where((r) {
          final name = (r['name'] as String? ?? '').toLowerCase();
          final sku = (r['sku'] as String? ?? '').toLowerCase();
          final barcode = (r['barcode'] as String? ?? '').toLowerCase();
          return name.contains(q) || sku.contains(q) || barcode.contains(q);
        }).toList();
      }
      return filtered.map(_mapProduct).toList();
    });
  }

  @override
  Future<ProductRecord?> findByBarcode(String storeId, String barcode) async {
    final rows = await _productsOrCached(storeId);
    final row = rows.where((r) => r['barcode'] == barcode && r['is_active'] != false).firstOrNull;
    return row == null ? null : _mapProduct(row);
  }

  @override
  Future<ProductRecord?> getProduct(String productId) async {
    final rows = await fetchRowsOrCached(
      'product.$productId',
      () async => (await _client.from('products').select().eq('id', productId)).cast<Map<String, dynamic>>(),
      table: 'products',
      where: (r) => r['id'] == productId,
    );
    return (rows == null || rows.isEmpty) ? null : _mapProduct(rows.first);
  }

  /// The store's active products, fresh when online, else this device's copy.
  Future<List<Map<String, dynamic>>> _productsOrCached(String storeId) async {
    return await fetchRowsOrCached(
          'products.$storeId',
          () async => (await _client.from('products').select().eq('is_active', true).order('name'))
              .cast<Map<String, dynamic>>(),
          table: 'products',
          where: (r) => r['is_active'] != false && r['store_id'] == storeId,
        ) ??
        const [];
  }

  @override
  Stream<List<StockItemRecord>> watchStock(String storeId, String branchId) {
    // Cached so the till still knows what is on the shelf while offline.
    // Stock changes made on this device and not yet sent (sales, receipts,
    // transfers, returns, adjustments) are applied on top, so the numbers
    // are right offline — and just after sending, until the server's new
    // figures arrive.
    DateTime? serverAt;
    return resilientRows(
      'stock.$storeId.$branchId',
      () => _client.from('stock_items').stream(primaryKey: ['id']).eq('branch_id', branchId).map((rows) {
            serverAt = DateTime.now();
            return rows;
          }),
      table: 'stock_items',
    ).map(
      (rows) => withUnsyncedStock(
        rows.map(_mapStockItem).toList(),
        Outbox.shared.stockChanges(asOf: serverAt),
        storeId: storeId,
        branchId: branchId,
      ),
    );
  }

  @override
  Future<StockItemRecord?> getStockItem(String productId, String branchId) async {
    DateTime? fetchedAt;
    var rows = await fetchRowsOrCached(
      'stock_item.$productId.$branchId',
      () async {
        final started = DateTime.now();
        final fresh = (await _client.from('stock_items').select().eq('product_id', productId).eq('branch_id', branchId))
            .cast<Map<String, dynamic>>();
        fetchedAt = started;
        return fresh;
      },
    );
    // Offline and never looked up on its own: the branch's stock list kept
    // on the device has it.
    final storeId = _writer.storeId;
    if (rows == null && storeId != null) {
      rows = (await OfflineCache.readRows('stock.$storeId.$branchId'))
          ?.where((r) => r['product_id'] == productId)
          .toList();
    }
    final items = withUnsyncedStock(
      (rows ?? const []).map(_mapStockItem).toList(),
      Outbox.shared.stockChanges(asOf: fetchedAt),
      storeId: rows?.firstOrNull?['store_id'] as String? ?? storeId ?? '',
      branchId: branchId,
    );
    return items.where((i) => i.productId == productId).firstOrNull;
  }

  /// Rows of [table] for the signed-in store: fresh when online, else this
  /// device's copy, with changes not yet sent laid over.
  Future<List<Map<String, dynamic>>> _storeRowsOrCached(String table) async {
    final storeId = _writer.storeId;
    if (storeId == null) return const [];
    try {
      return await fetchRowsOrCached(
            '$table.$storeId',
            () async => (await _client.from(table).select().eq('store_id', storeId)).cast<Map<String, dynamic>>(),
            table: table,
            where: (r) => r['store_id'] == storeId,
          ) ??
          const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<int> recordStockMovement({
    required String storeId,
    required String productId,
    required String branchId,
    required StockMovementType type,
    required int quantity,
    int unitCostMinorUnits = 0,
    String? referenceType,
    String? referenceId,
    required String createdByUserId,
  }) async {
    // Works offline: the movement is applied to the stock shown at once and
    // recorded on the server — exactly once — when the connection is back.
    final result = await _writer.rpc('record_stock_movement', offline: () => 0, {
      'p_product_id': productId,
      'p_branch_id': branchId,
      'p_type': type.name,
      'p_quantity': quantity,
      'p_unit_cost_minor_units': unitCostMinorUnits,
      'p_reference_type': referenceType,
      'p_reference_id': referenceId,
      'p_created_by_user_id': createdByUserId,
    });
    return (result as num).toInt();
  }

  @override
  Stream<List<ProductRecord>> watchLowStock(String storeId, String branchId) {
    // Realtime triggers off stock_items (the table that actually changes);
    // each emission re-queries the low_stock_items view, since the
    // quantity_on_hand <= reorder_level comparison is column-to-column and
    // can't be expressed as a PostgREST stream filter.
    return resilientRows(
      'stock.$storeId.$branchId',
      () => _client.from('stock_items').stream(primaryKey: ['id']).eq('branch_id', branchId),
    ).asyncMap((_) async {
      final rows = await fetchRowsOrCached(
        'low_stock.$storeId.$branchId',
        () async => (await _client.from('low_stock_items').select().eq('store_id', storeId).eq('branch_id', branchId))
            .cast<Map<String, dynamic>>(),
      );
      return (rows ?? const []).map(_mapProduct).toList();
    });
  }

  @override
  Future<String> createStockTransfer({
    required String storeId,
    required String fromBranchId,
    required String toBranchId,
    required String requestedByUserId,
    required List<MapEntry<String, int>> productQuantities,
  }) async {
    // The header and its lines are separate rows. The header is written as
    // not receivable ('cancelled', which the server refuses to receive),
    // then the lines, then it is opened ('pending') — all through the same
    // writer, so in this order even when kept to send later. A transfer cut
    // off half-way is never received with lines missing.
    final header = await _writer.insert('stock_transfers', {
      'store_id': storeId,
      'from_branch_id': fromBranchId,
      'to_branch_id': toBranchId,
      'requested_by_user_id': requestedByUserId,
      'status': 'cancelled',
      'created_at': _now(),
    });
    final transferId = header['id'] as String;
    for (final e in productQuantities) {
      await _writer.insert('stock_transfer_lines', {
        'store_id': storeId,
        'stock_transfer_id': transferId,
        'product_id': e.key,
        'quantity': e.value,
      });
    }
    await _writer.update('stock_transfers', {'status': 'pending'}, value: transferId);
    return transferId;
  }

  @override
  Future<void> receiveStockTransfer(String transferId, String receivedByUserId) async {
    // Kept to send later: the stock it moves shows on both branches at once.
    final stock = <Map<String, dynamic>>[];
    if (!_writer.sendsNow) {
      final transfer = (await _storeRowsOrCached('stock_transfers')).where((t) => t['id'] == transferId).firstOrNull;
      if (transfer != null) {
        for (final l in await _storeRowsOrCached('stock_transfer_lines')) {
          if (l['stock_transfer_id'] != transferId) continue;
          final qty = (l['quantity'] as num).toInt();
          if (qty <= 0) continue;
          stock
            ..add(stockIncrement(l['product_id'] as String, transfer['from_branch_id'] as String, -qty))
            ..add(stockIncrement(l['product_id'] as String, transfer['to_branch_id'] as String, qty));
        }
      }
    }
    try {
      await _writer.rpc(
        'receive_stock_transfer',
        {'p_transfer_id': transferId, 'p_received_by_user_id': receivedByUserId},
        offline: () => null,
        increments: [
          {
            'table': 'stock_transfers',
            'id': transferId,
            'set': {'status': 'received', 'received_by_user_id': receivedByUserId, 'received_at': _now()},
          },
          ...stock,
        ],
      );
    } catch (e) {
      final refusal = ReceiptRefusedException.from(e);
      if (refusal != null) throw refusal;
      rethrow;
    }
  }

  @override
  Stream<List<StockTransferRecord>> watchStockTransfers(String storeId) {
    return resilientRows(
      'stock_transfers.$storeId',
      () => _client.from('stock_transfers').stream(primaryKey: ['id']).order('created_at', ascending: false),
      table: 'stock_transfers',
    ).asyncMap((rows) async {
      if (rows.isEmpty) return <StockTransferRecord>[];
      final ids = rows.map((r) => r['id'] as String).toSet();
      final lineRows = await fetchRowsOrCached(
            'stock_transfer_lines.$storeId',
            () async => (await _client.from('stock_transfer_lines').select()).cast<Map<String, dynamic>>(),
            table: 'stock_transfer_lines',
          ) ??
          const [];

      final linesByTransfer = <String, List<StockTransferLineRecord>>{};
      for (final lr in lineRows.where((l) => ids.contains(l['stock_transfer_id']))) {
        final tid = lr['stock_transfer_id'] as String;
        (linesByTransfer[tid] ??= []).add(
          StockTransferLineRecord(productId: lr['product_id'] as String, quantity: (lr['quantity'] as num).toInt()),
        );
      }

      return rows
          .map((row) => StockTransferRecord(
                id: row['id'] as String,
                storeId: row['store_id'] as String,
                fromBranchId: row['from_branch_id'] as String,
                toBranchId: row['to_branch_id'] as String,
                status: row['status'] as String? ?? 'pending',
                requestedByUserId: row['requested_by_user_id'] as String,
                receivedByUserId: row['received_by_user_id'] as String?,
                createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
                receivedAt: row['received_at'] == null ? null : DateTime.parse(row['received_at'] as String).toLocal(),
                lines: linesByTransfer[row['id']] ?? const [],
              ))
          .toList();
    });
  }

  @override
  Future<DiscountRecord> createDiscount({
    required String storeId,
    required String name,
    required DiscountType type,
    required int value,
    String appliedScope = 'cart',
    String? scopeTargetId,
  }) async {
    final row = await _writer.insert('discounts', {
      'store_id': storeId,
      'name': name,
      'type': type.name,
      'value': value,
      'applied_scope': appliedScope,
      'scope_target_id': scopeTargetId,
      'is_active': true,
    });
    return _mapDiscount(row);
  }

  @override
  Stream<List<DiscountRecord>> watchDiscounts(String storeId) {
    return resilientRows(
      'discounts.$storeId',
      // Filtered here, not on the server: see watchProducts.
      () => _client.from('discounts').stream(primaryKey: ['id']).eq('store_id', storeId),
      table: 'discounts',
      where: (r) => r['is_active'] != false,
    ).map((rows) => rows.where((r) => r['is_active'] != false).map(_mapDiscount).toList());
  }

  @override
  Future<void> setDiscountActive(String discountId, bool isActive) async {
    await _writer.update('discounts', {'is_active': isActive}, value: discountId);
  }

  @override
  Future<PurchaseOrderRecord> createPurchaseOrder({
    required String storeId,
    required String branchId,
    required String supplierId,
    required List<SupplierPurchaseLine> lines,
    DateTime? expectedDate,
    required bool paidImmediately,
  }) async {
    final total = lines.fold<int>(0, (sum, l) => sum + l.quantity * l.unitCostMinorUnits);
    final header = await _writer.insert('purchase_orders', {
      'store_id': storeId,
      'branch_id': branchId,
      'supplier_id': supplierId,
      'status': 'draft',
      'order_date': _now(),
      'expected_date': expectedDate?.toUtc().toIso8601String(),
      'total_cost_minor_units': total,
      'paid_immediately': paidImmediately,
    });
    for (final l in lines) {
      await _writer.insert('purchase_order_lines', {
        'store_id': storeId,
        'purchase_order_id': header['id'],
        'product_id': l.productId,
        'quantity_ordered': l.quantity,
        'unit_cost_minor_units': l.unitCostMinorUnits,
      });
    }
    return _mapPo(header);
  }

  @override
  Future<int> receivePurchaseOrder(String purchaseOrderId, String receivedByUserId) async {
    // Kept to send later: what it adds shows on the branch's stock at once.
    final stock = <Map<String, dynamic>>[];
    if (!_writer.sendsNow) {
      final po = (await _storeRowsOrCached('purchase_orders')).where((o) => o['id'] == purchaseOrderId).firstOrNull;
      if (po != null) {
        for (final l in await _storeRowsOrCached('purchase_order_lines')) {
          if (l['purchase_order_id'] != purchaseOrderId) continue;
          final qty = (l['quantity_ordered'] as num).toInt();
          if (qty > 0) stock.add(stockIncrement(l['product_id'] as String, po['branch_id'] as String, qty));
        }
      }
    }
    final Object? result;
    try {
      result = await _writer.rpc(
        'receive_purchase_order',
        {'p_purchase_order_id': purchaseOrderId, 'p_received_by_user_id': receivedByUserId},
        offline: () => 0,
        increments: [
          {
            'table': 'purchase_orders',
            'id': purchaseOrderId,
            'set': {'status': 'received'},
          },
          ...stock,
        ],
      );
    } catch (e) {
      final refusal = ReceiptRefusedException.from(e);
      if (refusal != null) throw refusal;
      rethrow;
    }
    return (result as num?)?.toInt() ?? 0;
  }

  @override
  Stream<List<PurchaseOrderRecord>> watchPurchaseOrders(String storeId) {
    var linesKept = false;
    return resilientRows(
      'purchase_orders.$storeId',
      () =>
          _client.from('purchase_orders').stream(primaryKey: ['id']).order('order_date', ascending: false).map((rows) {
                // A copy of the orders' lines, so receiving one offline can show
                // what it adds to the stock.
                if (!linesKept) {
                  linesKept = true;
                  unawaited(_storeRowsOrCached('purchase_order_lines'));
                }
                return rows;
              }),
      table: 'purchase_orders',
    ).map((rows) => rows.map(_mapPo).toList());
  }
}
