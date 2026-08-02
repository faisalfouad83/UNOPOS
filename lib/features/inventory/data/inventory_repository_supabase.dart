import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/inventory_models.dart';
import '../domain/inventory_repository.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  SupabaseInventoryRepository(this._client);

  final SupabaseClient _client;

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
      );

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
        startDate: row['start_date'] == null ? null : DateTime.parse(row['start_date'] as String),
        endDate: row['end_date'] == null ? null : DateTime.parse(row['end_date'] as String),
        isActive: row['is_active'] as bool? ?? true,
      );

  PurchaseOrderRecord _mapPo(Map<String, dynamic> row) => PurchaseOrderRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        supplierId: row['supplier_id'] as String,
        status: row['status'] as String? ?? 'draft',
        orderDate: DateTime.parse(row['order_date'] as String),
        expectedDate: row['expected_date'] == null ? null : DateTime.parse(row['expected_date'] as String),
        totalCostMinorUnits: (row['total_cost_minor_units'] as num?)?.toInt() ?? 0,
        paidImmediately: row['paid_immediately'] as bool? ?? false,
      );

  @override
  Future<CategoryRecord> createCategory(String storeId, String name, {String? parentCategoryId}) async {
    final row = await _client.from('categories').insert({
      'store_id': storeId,
      'name': name,
      'parent_category_id': parentCategoryId,
    }).select().single();
    return _mapCategory(row);
  }

  @override
  Stream<List<CategoryRecord>> watchCategories(String storeId) {
    return _client.from('categories').stream(primaryKey: ['id']).map((rows) => rows.map(_mapCategory).toList());
  }

  @override
  Future<TaxRateRecord> createTaxRate(String storeId, String name, double ratePercent, {bool isDefault = false}) async {
    final row = await _client.from('tax_rates').insert({
      'store_id': storeId,
      'name': name,
      'rate_percent': ratePercent,
      'is_default': isDefault,
    }).select().single();
    return _mapTaxRate(row);
  }

  @override
  Stream<List<TaxRateRecord>> watchTaxRates(String storeId) {
    return _client.from('tax_rates').stream(primaryKey: ['id']).map((rows) => rows.map(_mapTaxRate).toList());
  }

  @override
  Future<ProductRecord> createProduct(ProductRecord product) async {
    final row = await _client.from('products').insert({
      if (product.id.isNotEmpty) 'id': product.id,
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
    }).select().single();
    return _mapProduct(row);
  }

  @override
  Future<void> updateProduct(ProductRecord product) async {
    await _client.from('products').update({
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
    }).eq('id', product.id);
  }

  @override
  Future<void> setProductActive(String productId, bool isActive) async {
    await _client.from('products').update({'is_active': isActive}).eq('id', productId);
  }

  @override
  Stream<List<ProductRecord>> watchProducts(String storeId, {String? categoryId, String? searchQuery}) {
    // .stream() supports only one server-side filter; is_active is always
    // required so it takes that slot, categoryId/searchQuery (both
    // optional) are applied client-side below.
    return _client.from('products').stream(primaryKey: ['id']).eq('is_active', true).order('name').map((rows) {
      var filtered = rows;
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
    final row = await _client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .eq('barcode', barcode)
        .eq('is_active', true)
        .maybeSingle();
    return row == null ? null : _mapProduct(row);
  }

  @override
  Future<ProductRecord?> getProduct(String productId) async {
    final row = await _client.from('products').select().eq('id', productId).maybeSingle();
    return row == null ? null : _mapProduct(row);
  }

  @override
  Stream<List<StockItemRecord>> watchStock(String storeId, String branchId) {
    return _client.from('stock_items').stream(primaryKey: ['id']).eq('branch_id', branchId).map((rows) => rows.map(_mapStockItem).toList());
  }

  @override
  Future<StockItemRecord?> getStockItem(String productId, String branchId) async {
    final row = await _client.from('stock_items').select().eq('product_id', productId).eq('branch_id', branchId).maybeSingle();
    return row == null ? null : _mapStockItem(row);
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
    final result = await _client.rpc('record_stock_movement', params: {
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
    return _client.from('stock_items').stream(primaryKey: ['id']).eq('branch_id', branchId).asyncMap((_) async {
      final rows = await _client.from('low_stock_items').select().eq('store_id', storeId).eq('branch_id', branchId);
      return (rows as List).cast<Map<String, dynamic>>().map(_mapProduct).toList();
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
    final header = await _client.from('stock_transfers').insert({
      'store_id': storeId,
      'from_branch_id': fromBranchId,
      'to_branch_id': toBranchId,
      'requested_by_user_id': requestedByUserId,
    }).select('id').single();
    final transferId = header['id'] as String;

    if (productQuantities.isNotEmpty) {
      await _client.from('stock_transfer_lines').insert(
        productQuantities
            .map((e) => {
                  'store_id': storeId,
                  'stock_transfer_id': transferId,
                  'product_id': e.key,
                  'quantity': e.value,
                })
            .toList(),
      );
    }
    return transferId;
  }

  @override
  Future<void> receiveStockTransfer(String transferId, String receivedByUserId) async {
    await _client.rpc('receive_stock_transfer', params: {
      'p_transfer_id': transferId,
      'p_received_by_user_id': receivedByUserId,
    });
  }

  @override
  Stream<List<StockTransferRecord>> watchStockTransfers(String storeId) {
    return _client.from('stock_transfers').stream(primaryKey: ['id']).order('created_at', ascending: false).asyncMap((rows) async {
      if (rows.isEmpty) return <StockTransferRecord>[];
      final ids = rows.map((r) => r['id'] as String).toList();
      final lineRows = await _client.from('stock_transfer_lines').select().inFilter('stock_transfer_id', ids);

      final linesByTransfer = <String, List<StockTransferLineRecord>>{};
      for (final lr in (lineRows as List).cast<Map<String, dynamic>>()) {
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
                createdAt: DateTime.parse(row['created_at'] as String),
                receivedAt: row['received_at'] == null ? null : DateTime.parse(row['received_at'] as String),
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
    final row = await _client.from('discounts').insert({
      'store_id': storeId,
      'name': name,
      'type': type.name,
      'value': value,
      'applied_scope': appliedScope,
      'scope_target_id': scopeTargetId,
    }).select().single();
    return _mapDiscount(row);
  }

  @override
  Stream<List<DiscountRecord>> watchDiscounts(String storeId) {
    return _client.from('discounts').stream(primaryKey: ['id']).eq('is_active', true).map((rows) => rows.map(_mapDiscount).toList());
  }

  @override
  Future<void> setDiscountActive(String discountId, bool isActive) async {
    await _client.from('discounts').update({'is_active': isActive}).eq('id', discountId);
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
    final header = await _client.from('purchase_orders').insert({
      'store_id': storeId,
      'branch_id': branchId,
      'supplier_id': supplierId,
      'expected_date': expectedDate?.toIso8601String(),
      'total_cost_minor_units': total,
      'paid_immediately': paidImmediately,
    }).select().single();

    if (lines.isNotEmpty) {
      await _client.from('purchase_order_lines').insert(
        lines
            .map((l) => {
                  'store_id': storeId,
                  'purchase_order_id': header['id'],
                  'product_id': l.productId,
                  'quantity_ordered': l.quantity,
                  'unit_cost_minor_units': l.unitCostMinorUnits,
                })
            .toList(),
      );
    }
    return _mapPo(header);
  }

  @override
  Future<int> receivePurchaseOrder(String purchaseOrderId, String receivedByUserId) async {
    final result = await _client.rpc('receive_purchase_order', params: {
      'p_purchase_order_id': purchaseOrderId,
      'p_received_by_user_id': receivedByUserId,
    });
    return (result as num).toInt();
  }

  @override
  Stream<List<PurchaseOrderRecord>> watchPurchaseOrders(String storeId) {
    return _client.from('purchase_orders').stream(primaryKey: ['id']).order('order_date', ascending: false).map((rows) => rows.map(_mapPo).toList());
  }
}
