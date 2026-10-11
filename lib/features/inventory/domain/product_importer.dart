import '../../../core/utils/id_generator.dart';
import 'barcode_generator.dart';
import 'inventory_models.dart';
import 'inventory_repository.dart';
import 'product_import.dart';

class ProductImportSummary {
  const ProductImportSummary({this.created = 0, this.updated = 0, this.failedRows = const []});
  final int created;
  final int updated;

  /// Sheet row numbers that couldn't be saved.
  final List<int> failedRows;
}

/// Saves parsed import rows. A row updates an existing product when its
/// barcode (or SKU) matches one; otherwise it creates a new product, with a
/// generated barcode if the sheet had none. Categories are created by name
/// as needed, and a quantity column adds opening stock to [branchId].
class ProductImporter {
  ProductImporter(this._repo);

  final InventoryRepository _repo;

  Future<ProductImportSummary> run({
    required String storeId,
    required List<ProductImportRow> rows,
    String? branchId,
    String? userId,
    void Function(int done, int total)? onProgress,
  }) async {
    final existing = await _repo.watchProducts(storeId).first;
    final byBarcode = {for (final p in existing) if (p.barcode?.isNotEmpty ?? false) p.barcode!: p};
    final bySku = {for (final p in existing) if (p.sku.isNotEmpty) p.sku: p};
    final categories = {
      for (final c in await _repo.watchCategories(storeId).first) c.name.trim().toLowerCase(): c.id,
    };

    var created = 0, updated = 0;
    final failed = <int>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      try {
        String? categoryId;
        final categoryName = row.category?.trim();
        if (categoryName != null && categoryName.isNotEmpty) {
          categoryId = categories[categoryName.toLowerCase()] ??=
              (await _repo.createCategory(storeId, categoryName)).id;
        }

        final match = (row.barcode != null ? byBarcode[row.barcode] : null) ?? (row.sku != null ? bySku[row.sku] : null);
        final ProductRecord saved;
        if (match != null) {
          saved = ProductRecord(
            id: match.id,
            storeId: storeId,
            categoryId: categoryId ?? match.categoryId,
            sku: row.sku ?? match.sku,
            barcode: row.barcode ?? match.barcode,
            name: row.name,
            unit: row.unit,
            costPriceMinorUnits: row.costPriceMinorUnits != 0 ? row.costPriceMinorUnits : match.costPriceMinorUnits,
            sellPriceMinorUnits: row.sellPriceMinorUnits,
            taxRateId: match.taxRateId,
            reorderLevel: match.reorderLevel,
            imagePath: match.imagePath,
            wholesalePriceMinorUnits: row.wholesalePriceMinorUnits ?? match.wholesalePriceMinorUnits,
            expiryDate: row.expiryDate ?? match.expiryDate,
          );
          await _repo.updateProduct(saved);
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
            unit: row.unit,
            costPriceMinorUnits: row.costPriceMinorUnits,
            sellPriceMinorUnits: row.sellPriceMinorUnits,
            wholesalePriceMinorUnits: row.wholesalePriceMinorUnits,
            expiryDate: row.expiryDate,
          ));
          created++;
        }
        if (saved.barcode != null) byBarcode[saved.barcode!] = saved;
        bySku[saved.sku] = saved;

        final qty = row.quantity ?? 0;
        if (qty > 0 && branchId != null && userId != null) {
          await _repo.recordStockMovement(
            storeId: storeId,
            productId: saved.id,
            branchId: branchId,
            type: StockMovementType.adjustmentIn,
            quantity: qty,
            unitCostMinorUnits: saved.costPriceMinorUnits,
            referenceType: 'import',
            createdByUserId: userId,
          );
        }
      } catch (_) {
        failed.add(row.rowNumber);
      }
      onProgress?.call(i + 1, rows.length);
    }
    return ProductImportSummary(created: created, updated: updated, failedRows: failed);
  }
}
