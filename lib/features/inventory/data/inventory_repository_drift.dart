import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/inventory_models.dart';
import '../domain/inventory_repository.dart';

class DriftInventoryRepository implements InventoryRepository {
  DriftInventoryRepository(this._db);

  final AppDatabase _db;

  CategoryRecord _mapCategory(Category row) =>
      CategoryRecord(id: row.id, storeId: row.storeId, name: row.name, parentCategoryId: row.parentCategoryId);

  TaxRateRecord _mapTaxRate(TaxRate row) => TaxRateRecord(
        id: row.id,
        storeId: row.storeId,
        name: row.name,
        ratePercent: row.ratePercent,
        isDefault: row.isDefault,
      );

  ProductRecord _mapProduct(Product row) => ProductRecord(
        id: row.id,
        storeId: row.storeId,
        categoryId: row.categoryId,
        sku: row.sku,
        barcode: row.barcode,
        name: row.name,
        unit: row.unit,
        costPriceMinorUnits: row.costPriceMinorUnits,
        sellPriceMinorUnits: row.sellPriceMinorUnits,
        taxRateId: row.taxRateId,
        reorderLevel: row.reorderLevel,
        imagePath: row.imagePath,
        isActive: row.isActive,
      );

  StockItemRecord _mapStockItem(StockItem row) => StockItemRecord(
        id: row.id,
        storeId: row.storeId,
        productId: row.productId,
        branchId: row.branchId,
        quantityOnHand: row.quantityOnHand,
        reservedQuantity: row.reservedQuantity,
      );

  PurchaseOrderRecord _mapPo(PurchaseOrder row) => PurchaseOrderRecord(
        id: row.id,
        storeId: row.storeId,
        branchId: row.branchId,
        supplierId: row.supplierId,
        status: row.status,
        orderDate: row.orderDate,
        expectedDate: row.expectedDate,
        totalCostMinorUnits: row.totalCostMinorUnits,
        paidImmediately: row.paidImmediately,
      );

  @override
  Future<CategoryRecord> createCategory(String storeId, String name, {String? parentCategoryId}) async {
    final id = IdGenerator.newId();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(id: id, storeId: storeId, name: name, parentCategoryId: Value(parentCategoryId)),
        );
    return CategoryRecord(id: id, storeId: storeId, name: name, parentCategoryId: parentCategoryId);
  }

  @override
  Stream<List<CategoryRecord>> watchCategories(String storeId) {
    return (_db.select(_db.categories)..where((t) => t.storeId.equals(storeId)))
        .watch()
        .map((rows) => rows.map(_mapCategory).toList());
  }

  @override
  Future<TaxRateRecord> createTaxRate(String storeId, String name, double ratePercent, {bool isDefault = false}) async {
    final id = IdGenerator.newId();
    await _db.into(_db.taxRates).insert(
          TaxRatesCompanion.insert(id: id, storeId: storeId, name: name, ratePercent: ratePercent, isDefault: Value(isDefault)),
        );
    return TaxRateRecord(id: id, storeId: storeId, name: name, ratePercent: ratePercent, isDefault: isDefault);
  }

  @override
  Stream<List<TaxRateRecord>> watchTaxRates(String storeId) {
    return (_db.select(_db.taxRates)..where((t) => t.storeId.equals(storeId)))
        .watch()
        .map((rows) => rows.map(_mapTaxRate).toList());
  }

  @override
  Future<ProductRecord> createProduct(ProductRecord product) async {
    final id = product.id.isEmpty ? IdGenerator.newId() : product.id;
    await _db.into(_db.products).insert(
          ProductsCompanion.insert(
            id: id,
            storeId: product.storeId,
            categoryId: Value(product.categoryId),
            sku: product.sku,
            barcode: Value(product.barcode),
            name: product.name,
            unit: Value(product.unit),
            costPriceMinorUnits: Value(product.costPriceMinorUnits),
            sellPriceMinorUnits: Value(product.sellPriceMinorUnits),
            taxRateId: Value(product.taxRateId),
            reorderLevel: Value(product.reorderLevel),
            imagePath: Value(product.imagePath),
            createdAt: DateTime.now(),
          ),
        );
    return ProductRecord(
      id: id,
      storeId: product.storeId,
      categoryId: product.categoryId,
      sku: product.sku,
      barcode: product.barcode,
      name: product.name,
      unit: product.unit,
      costPriceMinorUnits: product.costPriceMinorUnits,
      sellPriceMinorUnits: product.sellPriceMinorUnits,
      taxRateId: product.taxRateId,
      reorderLevel: product.reorderLevel,
      imagePath: product.imagePath,
    );
  }

  @override
  Future<void> updateProduct(ProductRecord product) async {
    await (_db.update(_db.products)..where((t) => t.id.equals(product.id))).write(
      ProductsCompanion(
        categoryId: Value(product.categoryId),
        sku: Value(product.sku),
        barcode: Value(product.barcode),
        name: Value(product.name),
        unit: Value(product.unit),
        costPriceMinorUnits: Value(product.costPriceMinorUnits),
        sellPriceMinorUnits: Value(product.sellPriceMinorUnits),
        taxRateId: Value(product.taxRateId),
        reorderLevel: Value(product.reorderLevel),
        imagePath: Value(product.imagePath),
        isActive: Value(product.isActive),
      ),
    );
  }

  @override
  Future<void> setProductActive(String productId, bool isActive) async {
    await (_db.update(_db.products)..where((t) => t.id.equals(productId)))
        .write(ProductsCompanion(isActive: Value(isActive)));
  }

  @override
  Stream<List<ProductRecord>> watchProducts(String storeId, {String? categoryId, String? searchQuery}) {
    final query = _db.select(_db.products)..where((t) => t.storeId.equals(storeId) & t.isActive.equals(true));
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      query.where((t) => t.name.like(q) | t.sku.like(q) | t.barcode.like(q));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_mapProduct).toList());
  }

  @override
  Future<ProductRecord?> findByBarcode(String storeId, String barcode) async {
    final row = await (_db.select(_db.products)
          ..where((t) => t.storeId.equals(storeId) & t.barcode.equals(barcode) & t.isActive.equals(true)))
        .getSingleOrNull();
    return row == null ? null : _mapProduct(row);
  }

  @override
  Future<ProductRecord?> getProduct(String productId) async {
    final row = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    return row == null ? null : _mapProduct(row);
  }

  @override
  Stream<List<StockItemRecord>> watchStock(String storeId, String branchId) {
    return (_db.select(_db.stockItems)
          ..where((t) => t.storeId.equals(storeId) & t.branchId.equals(branchId)))
        .watch()
        .map((rows) => rows.map(_mapStockItem).toList());
  }

  @override
  Future<StockItemRecord?> getStockItem(String productId, String branchId) async {
    final row = await (_db.select(_db.stockItems)
          ..where((t) => t.productId.equals(productId) & t.branchId.equals(branchId)))
        .getSingleOrNull();
    return row == null ? null : _mapStockItem(row);
  }

  static const Set<StockMovementType> _increasingTypes = {
    StockMovementType.purchaseIn,
    StockMovementType.transferIn,
    StockMovementType.adjustmentIn,
    StockMovementType.returnIn,
  };

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
    return _db.transaction(() async {
      final existing = await (_db.select(_db.stockItems)
            ..where((t) => t.productId.equals(productId) & t.branchId.equals(branchId)))
          .getSingleOrNull();

      final signedQuantity = _increasingTypes.contains(type) ? quantity : -quantity;
      final newQuantity = (existing?.quantityOnHand ?? 0) + signedQuantity;

      if (existing == null) {
        await _db.into(_db.stockItems).insert(
              StockItemsCompanion.insert(
                id: IdGenerator.newId(),
                storeId: storeId,
                productId: productId,
                branchId: branchId,
                quantityOnHand: Value(newQuantity),
              ),
            );
      } else {
        await (_db.update(_db.stockItems)..where((t) => t.id.equals(existing.id)))
            .write(StockItemsCompanion(quantityOnHand: Value(newQuantity)));
      }

      await _db.into(_db.stockMovements).insert(
            StockMovementsCompanion.insert(
              id: IdGenerator.newId(),
              storeId: storeId,
              productId: productId,
              branchId: branchId,
              type: type.name,
              quantity: quantity,
              unitCostMinorUnits: Value(unitCostMinorUnits),
              referenceType: Value(referenceType),
              referenceId: Value(referenceId),
              createdByUserId: createdByUserId,
              createdAt: DateTime.now(),
            ),
          );

      return newQuantity;
    });
  }

  @override
  Stream<List<ProductRecord>> watchLowStock(String storeId, String branchId) {
    final query = _db.select(_db.products).join([
      innerJoin(
        _db.stockItems,
        _db.stockItems.productId.equalsExp(_db.products.id) & _db.stockItems.branchId.equals(branchId),
      ),
    ])
      ..where(_db.products.storeId.equals(storeId) & _db.products.isActive.equals(true));

    return query.watch().map((rows) {
      final result = <ProductRecord>[];
      for (final row in rows) {
        final product = row.readTable(_db.products);
        final stock = row.readTable(_db.stockItems);
        if (stock.quantityOnHand <= product.reorderLevel) {
          result.add(_mapProduct(product));
        }
      }
      return result;
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
    final transferId = IdGenerator.newId();
    await _db.transaction(() async {
      await _db.into(_db.stockTransfers).insert(
            StockTransfersCompanion.insert(
              id: transferId,
              storeId: storeId,
              fromBranchId: fromBranchId,
              toBranchId: toBranchId,
              requestedByUserId: requestedByUserId,
              createdAt: DateTime.now(),
            ),
          );
      for (final entry in productQuantities) {
        await _db.into(_db.stockTransferLines).insert(
              StockTransferLinesCompanion.insert(
                id: IdGenerator.newId(),
                stockTransferId: transferId,
                productId: entry.key,
                quantity: entry.value,
              ),
            );
      }
    });
    return transferId;
  }

  @override
  Future<void> receiveStockTransfer(String transferId, String receivedByUserId) async {
    final transfer = await (_db.select(_db.stockTransfers)..where((t) => t.id.equals(transferId))).getSingle();
    final lines = await (_db.select(_db.stockTransferLines)..where((t) => t.stockTransferId.equals(transferId))).get();

    for (final line in lines) {
      await recordStockMovement(
        storeId: transfer.storeId,
        productId: line.productId,
        branchId: transfer.fromBranchId,
        type: StockMovementType.transferOut,
        quantity: line.quantity,
        referenceType: 'STOCK_TRANSFER',
        referenceId: transferId,
        createdByUserId: receivedByUserId,
      );
      await recordStockMovement(
        storeId: transfer.storeId,
        productId: line.productId,
        branchId: transfer.toBranchId,
        type: StockMovementType.transferIn,
        quantity: line.quantity,
        referenceType: 'STOCK_TRANSFER',
        referenceId: transferId,
        createdByUserId: receivedByUserId,
      );
    }

    await (_db.update(_db.stockTransfers)..where((t) => t.id.equals(transferId))).write(
      StockTransfersCompanion(
        status: const Value('received'),
        receivedByUserId: Value(receivedByUserId),
        receivedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<List<StockTransferRecord>> watchStockTransfers(String storeId) {
    final query = _db.select(_db.stockTransfers)
      ..where((t) => t.storeId.equals(storeId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().asyncMap((rows) async {
      final result = <StockTransferRecord>[];
      for (final row in rows) {
        final lines = await (_db.select(_db.stockTransferLines)..where((t) => t.stockTransferId.equals(row.id))).get();
        result.add(StockTransferRecord(
          id: row.id,
          storeId: row.storeId,
          fromBranchId: row.fromBranchId,
          toBranchId: row.toBranchId,
          status: row.status,
          requestedByUserId: row.requestedByUserId,
          receivedByUserId: row.receivedByUserId,
          createdAt: row.createdAt,
          receivedAt: row.receivedAt,
          lines: lines.map((l) => StockTransferLineRecord(productId: l.productId, quantity: l.quantity)).toList(),
        ));
      }
      return result;
    });
  }

  DiscountRecord _mapDiscount(Discount row) => DiscountRecord(
        id: row.id,
        storeId: row.storeId,
        name: row.name,
        type: row.type == 'amountOff' ? DiscountType.amountOff : DiscountType.percentOff,
        value: row.value,
        appliedScope: row.appliedScope,
        scopeTargetId: row.scopeTargetId,
        startDate: row.startDate,
        endDate: row.endDate,
        isActive: row.isActive,
      );

  @override
  Future<DiscountRecord> createDiscount({
    required String storeId,
    required String name,
    required DiscountType type,
    required int value,
    String appliedScope = 'cart',
    String? scopeTargetId,
  }) async {
    final id = IdGenerator.newId();
    await _db.into(_db.discounts).insert(
          DiscountsCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            type: type.name,
            value: value,
            appliedScope: appliedScope,
            scopeTargetId: Value(scopeTargetId),
          ),
        );
    return DiscountRecord(id: id, storeId: storeId, name: name, type: type, value: value, appliedScope: appliedScope, scopeTargetId: scopeTargetId);
  }

  @override
  Stream<List<DiscountRecord>> watchDiscounts(String storeId) {
    return (_db.select(_db.discounts)
          ..where((t) => t.storeId.equals(storeId) & t.isActive.equals(true)))
        .watch()
        .map((rows) => rows.map(_mapDiscount).toList());
  }

  @override
  Future<void> setDiscountActive(String discountId, bool isActive) async {
    await (_db.update(_db.discounts)..where((t) => t.id.equals(discountId)))
        .write(DiscountsCompanion(isActive: Value(isActive)));
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
    final id = IdGenerator.newId();
    final total = lines.fold<int>(0, (sum, l) => sum + l.quantity * l.unitCostMinorUnits);
    final orderDate = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.purchaseOrders).insert(
            PurchaseOrdersCompanion.insert(
              id: id,
              storeId: storeId,
              branchId: branchId,
              supplierId: supplierId,
              orderDate: orderDate,
              expectedDate: Value(expectedDate),
              totalCostMinorUnits: Value(total),
              paidImmediately: Value(paidImmediately),
            ),
          );
      for (final line in lines) {
        await _db.into(_db.purchaseOrderLines).insert(
              PurchaseOrderLinesCompanion.insert(
                id: IdGenerator.newId(),
                purchaseOrderId: id,
                productId: line.productId,
                quantityOrdered: line.quantity,
                unitCostMinorUnits: line.unitCostMinorUnits,
              ),
            );
      }
    });

    return PurchaseOrderRecord(
      id: id,
      storeId: storeId,
      branchId: branchId,
      supplierId: supplierId,
      orderDate: orderDate,
      expectedDate: expectedDate,
      totalCostMinorUnits: total,
      paidImmediately: paidImmediately,
    );
  }

  @override
  Future<int> receivePurchaseOrder(String purchaseOrderId, String receivedByUserId) async {
    final po = await (_db.select(_db.purchaseOrders)..where((t) => t.id.equals(purchaseOrderId))).getSingle();
    final lines = await (_db.select(_db.purchaseOrderLines)..where((t) => t.purchaseOrderId.equals(purchaseOrderId))).get();

    for (final line in lines) {
      await recordStockMovement(
        storeId: po.storeId,
        productId: line.productId,
        branchId: po.branchId,
        type: StockMovementType.purchaseIn,
        quantity: line.quantityOrdered,
        unitCostMinorUnits: line.unitCostMinorUnits,
        referenceType: 'PURCHASE_ORDER',
        referenceId: purchaseOrderId,
        createdByUserId: receivedByUserId,
      );
      await (_db.update(_db.purchaseOrderLines)..where((t) => t.id.equals(line.id)))
          .write(PurchaseOrderLinesCompanion(quantityReceived: Value(line.quantityOrdered)));
    }

    await (_db.update(_db.purchaseOrders)..where((t) => t.id.equals(purchaseOrderId)))
        .write(const PurchaseOrdersCompanion(status: Value('received')));

    return po.totalCostMinorUnits;
  }

  @override
  Stream<List<PurchaseOrderRecord>> watchPurchaseOrders(String storeId) {
    return (_db.select(_db.purchaseOrders)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.orderDate)]))
        .watch()
        .map((rows) => rows.map(_mapPo).toList());
  }
}
