import '../../../core/utils/id_generator.dart';
import 'barcode_generator.dart';
import 'inventory_models.dart';
import 'inventory_repository.dart';
import 'product_import.dart';

class ProductImportSummary {
  const ProductImportSummary({this.created = 0, this.updated = 0, this.failedRows = const []});
  final int created;
  final int updated;

  /// Sheet row numbers that couldn't be saved, including rows whose codes
  /// belong to different products (they are left for the user to sort out).
  final List<int> failedRows;
}

/// Saves parsed import rows, so that importing the same file again changes
/// nothing:
///
/// * A row updates the product with its barcode; failing that, the one
///   with its code (SKU); a row with neither updates the one product with
///   exactly its name. Otherwise a new product is created, with a generated
///   barcode if the sheet had none.
/// * A row is never saved over a different product: when its barcode and
///   code point at two products, its code belongs to a product with another
///   barcode, or several products have its name, the row is reported.
/// * Columns left empty keep what the product already has (cost, unit,
///   wholesale price, expiry, category).
/// * The quantity is the stock to have in [branchId]: a new product starts
///   with it, an existing one is adjusted up or down to it (recorded as a
///   stock adjustment). It is never added on top of what is there.
///
/// Categories are created by name as needed.
class ProductImporter {
  ProductImporter(this._repo);

  final InventoryRepository _repo;

  static String _nameKey(String name) => name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<ProductImportSummary> run({
    required String storeId,
    required List<ProductImportRow> rows,
    String? branchId,
    String? userId,
    void Function(int done, int total)? onProgress,
  }) async {
    final products = <String, ProductRecord>{for (final p in await _repo.watchProducts(storeId).first) p.id: p};
    final byBarcode = <String, String>{};
    final bySku = <String, String>{};
    final byName = <String, Set<String>>{};
    void index(ProductRecord p) {
      final barcode = p.barcode?.trim() ?? '';
      if (barcode.isNotEmpty) byBarcode[barcode] = p.id;
      if (p.sku.trim().isNotEmpty) bySku[p.sku.trim().toLowerCase()] = p.id;
      (byName[_nameKey(p.name)] ??= {}).add(p.id);
    }

    void unindex(ProductRecord p) {
      byBarcode.removeWhere((_, id) => id == p.id);
      bySku.removeWhere((_, id) => id == p.id);
      byName[_nameKey(p.name)]?.remove(p.id);
    }

    products.values.forEach(index);
    final categories = {
      for (final c in await _repo.watchCategories(storeId).first) c.name.trim().toLowerCase(): c.id,
    };

    var created = 0, updated = 0;
    final failed = <int>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      try {
        final (match, conflict) = _match(row, products, byBarcode, bySku, byName);
        if (conflict) {
          failed.add(row.rowNumber);
          onProgress?.call(i + 1, rows.length);
          continue;
        }

        String? categoryId;
        final categoryName = row.category?.trim();
        if (categoryName != null && categoryName.isNotEmpty) {
          categoryId =
              categories[categoryName.toLowerCase()] ??= (await _repo.createCategory(storeId, categoryName)).id;
        }

        final ProductRecord saved;
        if (match != null) {
          saved = ProductRecord(
            id: match.id,
            storeId: storeId,
            categoryId: categoryId ?? match.categoryId,
            sku: row.sku ?? match.sku,
            barcode: row.barcode ?? match.barcode,
            name: row.name,
            unit: row.unit ?? match.unit,
            costPriceMinorUnits: row.costPriceMinorUnits ?? match.costPriceMinorUnits,
            sellPriceMinorUnits: row.sellPriceMinorUnits,
            taxRateId: match.taxRateId,
            reorderLevel: match.reorderLevel,
            imagePath: match.imagePath,
            isActive: match.isActive,
            wholesalePriceMinorUnits: row.wholesalePriceMinorUnits ?? match.wholesalePriceMinorUnits,
            expiryDate: row.expiryDate ?? match.expiryDate,
          );
          if (!_same(saved, match)) await _repo.updateProduct(saved);
          unindex(match);
          updated++;
        } else {
          final barcode = row.barcode ?? await BarcodeGenerator.newUniqueBarcode(_repo, storeId);
          saved = await _repo.createProduct(ProductRecord(
            id: IdGenerator.newId(),
            storeId: storeId,
            categoryId: categoryId,
            sku: row.sku ?? barcode,
            barcode: barcode,
            name: row.name,
            unit: row.unit ?? 'pcs',
            costPriceMinorUnits: row.costPriceMinorUnits ?? 0,
            sellPriceMinorUnits: row.sellPriceMinorUnits,
            wholesalePriceMinorUnits: row.wholesalePriceMinorUnits,
            expiryDate: row.expiryDate,
          ));
          created++;
        }
        products[saved.id] = saved;
        index(saved);

        final quantity = row.quantity;
        if (quantity != null && branchId != null && userId != null) {
          final onHand = match == null ? 0 : (await _repo.getStockItem(saved.id, branchId))?.quantityOnHand ?? 0;
          final change = quantity - onHand;
          if (change != 0) {
            await _repo.recordStockMovement(
              storeId: storeId,
              productId: saved.id,
              branchId: branchId,
              type: change > 0 ? StockMovementType.adjustmentIn : StockMovementType.adjustmentOut,
              quantity: change.abs(),
              unitCostMinorUnits: saved.costPriceMinorUnits,
              referenceType: 'import',
              createdByUserId: userId,
            );
          }
        }
      } catch (_) {
        failed.add(row.rowNumber);
      }
      onProgress?.call(i + 1, rows.length);
    }
    return ProductImportSummary(created: created, updated: updated, failedRows: failed);
  }

  /// The existing product [row] is about, and whether saving it would
  /// overwrite a different product (see [ProductImporter]).
  static (ProductRecord?, bool) _match(
    ProductImportRow row,
    Map<String, ProductRecord> products,
    Map<String, String> byBarcode,
    Map<String, String> bySku,
    Map<String, Set<String>> byName,
  ) {
    final barcodeHit = row.barcode == null ? null : products[byBarcode[row.barcode]];
    // A new product's code defaults to its barcode, so that is looked up too.
    final code = row.sku ?? row.barcode;
    final skuHit = code == null ? null : products[bySku[code.toLowerCase()]];

    if (barcodeHit != null) {
      final conflict = row.sku != null && skuHit != null && skuHit.id != barcodeHit.id;
      return (barcodeHit, conflict);
    }
    if (skuHit != null) {
      final otherBarcode = skuHit.barcode?.trim() ?? '';
      final conflict = row.barcode != null && otherBarcode.isNotEmpty && otherBarcode != row.barcode;
      return (skuHit, conflict);
    }
    if (row.barcode == null && row.sku == null) {
      final ids = byName[_nameKey(row.name)] ?? const <String>{};
      if (ids.length > 1) return (null, true);
      if (ids.length == 1) return (products[ids.single], false);
    }
    return (null, false);
  }

  static bool _same(ProductRecord a, ProductRecord b) =>
      a.categoryId == b.categoryId &&
      a.sku == b.sku &&
      a.barcode == b.barcode &&
      a.name == b.name &&
      a.unit == b.unit &&
      a.costPriceMinorUnits == b.costPriceMinorUnits &&
      a.sellPriceMinorUnits == b.sellPriceMinorUnits &&
      a.wholesalePriceMinorUnits == b.wholesalePriceMinorUnits &&
      a.expiryDate == b.expiryDate;
}
