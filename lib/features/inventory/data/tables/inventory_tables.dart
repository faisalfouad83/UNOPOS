import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get parentCategoryId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TaxRates extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  RealColumn get ratePercent => real()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get sku => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  IntColumn get costPriceMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get sellPriceMinorUnits => integer().withDefault(const Constant(0))();
  TextColumn get taxRateId => text().nullable()();
  IntColumn get reorderLevel => integer().withDefault(const Constant(0))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-branch quantity on hand for a product. One row per (productId, branchId).
class StockItems extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get branchId => text()();
  IntColumn get quantityOnHand => integer().withDefault(const Constant(0))();
  IntColumn get reservedQuantity => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCountedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Immutable audit trail of every stock change — the source of truth that
/// [StockItems].quantityOnHand is derived from/reconciled against.
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get branchId => text()();
  TextColumn get type => text()(); // purchaseIn/saleOut/transferIn/transferOut/adjustmentIn/adjustmentOut/returnIn/returnOut
  IntColumn get quantity => integer()();
  IntColumn get unitCostMinorUnits => integer().withDefault(const Constant(0))();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get createdByUserId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class StockTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get fromBranchId => text()();
  TextColumn get toBranchId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending/inTransit/received/cancelled
  TextColumn get requestedByUserId => text()();
  TextColumn get receivedByUserId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get receivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StockTransferLines extends Table {
  TextColumn get id => text()();
  TextColumn get stockTransferId => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text()();
  TextColumn get supplierId => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))(); // draft/ordered/partiallyReceived/received/cancelled
  DateTimeColumn get orderDate => dateTime()();
  DateTimeColumn get expectedDate => dateTime().nullable()();
  IntColumn get totalCostMinorUnits => integer().withDefault(const Constant(0))();
  BoolColumn get paidImmediately => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrderLines extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseOrderId => text()();
  TextColumn get productId => text()();
  IntColumn get quantityOrdered => integer()();
  IntColumn get quantityReceived => integer().withDefault(const Constant(0))();
  IntColumn get unitCostMinorUnits => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Discounts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // percentOff/amountOff
  IntColumn get value => integer()(); // percent*100 or minor units, depending on type
  TextColumn get appliedScope => text()(); // product/category/cart
  TextColumn get scopeTargetId => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
