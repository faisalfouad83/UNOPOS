class CategoryRecord {
  const CategoryRecord({required this.id, required this.storeId, required this.name, this.parentCategoryId});
  final String id;
  final String storeId;
  final String name;
  final String? parentCategoryId;
}

class TaxRateRecord {
  const TaxRateRecord({
    required this.id,
    required this.storeId,
    required this.name,
    required this.ratePercent,
    this.isDefault = false,
  });
  final String id;
  final String storeId;
  final String name;
  final double ratePercent;
  final bool isDefault;
}

class ProductRecord {
  const ProductRecord({
    required this.id,
    required this.storeId,
    this.categoryId,
    required this.sku,
    this.barcode,
    required this.name,
    this.unit = 'pcs',
    this.costPriceMinorUnits = 0,
    this.sellPriceMinorUnits = 0,
    this.taxRateId,
    this.reorderLevel = 0,
    this.imagePath,
    this.isActive = true,
  });

  final String id;
  final String storeId;
  final String? categoryId;
  final String sku;
  final String? barcode;
  final String name;
  final String unit;
  final int costPriceMinorUnits;
  final int sellPriceMinorUnits;
  final String? taxRateId;
  final int reorderLevel;
  final String? imagePath;
  final bool isActive;
}

class StockItemRecord {
  const StockItemRecord({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.branchId,
    this.quantityOnHand = 0,
    this.reservedQuantity = 0,
  });
  final String id;
  final String storeId;
  final String productId;
  final String branchId;
  final int quantityOnHand;
  final int reservedQuantity;
}

enum StockMovementType {
  purchaseIn,
  saleOut,
  transferIn,
  transferOut,
  adjustmentIn,
  adjustmentOut,
  returnIn,
  returnOut,
}

class StockMovementRecord {
  const StockMovementRecord({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.branchId,
    required this.type,
    required this.quantity,
    this.unitCostMinorUnits = 0,
    this.referenceType,
    this.referenceId,
    required this.createdByUserId,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String productId;
  final String branchId;
  final StockMovementType type;
  final int quantity;
  final int unitCostMinorUnits;
  final String? referenceType;
  final String? referenceId;
  final String createdByUserId;
  final DateTime createdAt;
}

class SupplierPurchaseLine {
  const SupplierPurchaseLine({
    required this.productId,
    required this.quantity,
    required this.unitCostMinorUnits,
  });
  final String productId;
  final int quantity;
  final int unitCostMinorUnits;
}

enum DiscountType { percentOff, amountOff }

class DiscountRecord {
  const DiscountRecord({
    required this.id,
    required this.storeId,
    required this.name,
    required this.type,
    required this.value,
    this.appliedScope = 'cart',
    this.scopeTargetId,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  final String id;
  final String storeId;
  final String name;
  final DiscountType type;

  /// Percent (e.g. 10 for 10%) when [type] is percentOff, or minor units
  /// when [type] is amountOff.
  final int value;
  final String appliedScope;
  final String? scopeTargetId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  /// Computes the discount amount in minor units for a line with the given
  /// gross total.
  int amountForMinorUnits(int grossMinorUnits) {
    if (type == DiscountType.amountOff) return value.clamp(0, grossMinorUnits);
    final amount = (grossMinorUnits * value / 100).round();
    return amount.clamp(0, grossMinorUnits);
  }
}

class StockTransferRecord {
  const StockTransferRecord({
    required this.id,
    required this.storeId,
    required this.fromBranchId,
    required this.toBranchId,
    this.status = 'pending',
    required this.requestedByUserId,
    this.receivedByUserId,
    required this.createdAt,
    this.receivedAt,
    this.lines = const [],
  });

  final String id;
  final String storeId;
  final String fromBranchId;
  final String toBranchId;
  final String status;
  final String requestedByUserId;
  final String? receivedByUserId;
  final DateTime createdAt;
  final DateTime? receivedAt;
  final List<StockTransferLineRecord> lines;
}

class StockTransferLineRecord {
  const StockTransferLineRecord({required this.productId, required this.quantity});
  final String productId;
  final int quantity;
}

class PurchaseOrderRecord {
  const PurchaseOrderRecord({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.supplierId,
    this.status = 'draft',
    required this.orderDate,
    this.expectedDate,
    this.totalCostMinorUnits = 0,
    this.paidImmediately = false,
  });
  final String id;
  final String storeId;
  final String branchId;
  final String supplierId;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDate;
  final int totalCostMinorUnits;
  final bool paidImmediately;
}
