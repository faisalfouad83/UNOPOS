import 'inventory_models.dart';

abstract class InventoryRepository {
  Future<CategoryRecord> createCategory(String storeId, String name, {String? parentCategoryId});
  Stream<List<CategoryRecord>> watchCategories(String storeId);

  Future<TaxRateRecord> createTaxRate(String storeId, String name, double ratePercent, {bool isDefault = false});
  Stream<List<TaxRateRecord>> watchTaxRates(String storeId);

  Future<ProductRecord> createProduct(ProductRecord product);
  Future<void> updateProduct(ProductRecord product);
  Future<void> setProductActive(String productId, bool isActive);
  Stream<List<ProductRecord>> watchProducts(String storeId, {String? categoryId, String? searchQuery});
  Future<ProductRecord?> findByBarcode(String storeId, String barcode);
  Future<ProductRecord?> getProduct(String productId);

  Stream<List<StockItemRecord>> watchStock(String storeId, String branchId);
  Future<StockItemRecord?> getStockItem(String productId, String branchId);

  /// Applies a stock movement (creating the branch/product StockItem row if
  /// needed) and records it in the immutable StockMovements audit trail.
  /// Returns the resulting quantity on hand.
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
  });

  Stream<List<ProductRecord>> watchLowStock(String storeId, String branchId);

  Future<String> createStockTransfer({
    required String storeId,
    required String fromBranchId,
    required String toBranchId,
    required String requestedByUserId,
    required List<MapEntry<String, int>> productQuantities,
  });

  Future<void> receiveStockTransfer(String transferId, String receivedByUserId);

  Stream<List<StockTransferRecord>> watchStockTransfers(String storeId);

  Future<DiscountRecord> createDiscount({
    required String storeId,
    required String name,
    required DiscountType type,
    required int value,
    String appliedScope = 'cart',
    String? scopeTargetId,
  });

  Stream<List<DiscountRecord>> watchDiscounts(String storeId);

  Future<void> setDiscountActive(String discountId, bool isActive);

  Future<PurchaseOrderRecord> createPurchaseOrder({
    required String storeId,
    required String branchId,
    required String supplierId,
    required List<SupplierPurchaseLine> lines,
    DateTime? expectedDate,
    required bool paidImmediately,
  });

  /// Marks a purchase order fully received: posts StockMovements for every
  /// line and returns the order's total cost (used by the caller to post
  /// the corresponding accounting + supplier-balance entries).
  Future<int> receivePurchaseOrder(String purchaseOrderId, String receivedByUserId);

  Stream<List<PurchaseOrderRecord>> watchPurchaseOrders(String storeId);
}
