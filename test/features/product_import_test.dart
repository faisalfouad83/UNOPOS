import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/inventory/data/inventory_repository_drift.dart';
import 'package:unopos/features/inventory/domain/barcode_generator.dart';
import 'package:unopos/features/inventory/domain/product_import.dart';
import 'package:unopos/features/inventory/domain/product_importer.dart';

void main() {
  test('reads Arabic headers in any order, with Arabic digits and units', () {
    final result = ProductImportParser.parseTable([
      ['الكمية', 'الاسم', 'سعر البيع', 'الوحدة', 'الباركود', 'تاريخ الانتهاء'],
      ['١٢', 'شاي', '١٬٥٠٠', 'كارتون', '6201234567890.0', '30/6/2027'],
    ]);
    expect(result.issues, isEmpty);
    final row = result.rows.single;
    expect(row.name, 'شاي');
    expect(row.sellPriceMinorUnits, 150000);
    expect(row.quantity, 12);
    expect(row.unit, 'carton');
    expect(row.barcode, '6201234567890');
    expect(row.expiryDate, DateTime(2027, 6, 30));
  });

  test('flags rows missing a name or price and skips blank rows', () {
    final result = ProductImportParser.parseTable([
      ['Name', 'Price'],
      ['Tea', '1500'],
      ['', ''],
      ['', '200'],
      ['Sugar', ''],
    ]);
    expect(result.rows.map((r) => r.name), ['Tea']);
    expect(result.issues.map((i) => (i.rowNumber, i.field)), [
      (4, ProductImportColumn.name),
      (5, ProductImportColumn.sellPrice),
    ]);
  });

  test('a sheet without a price column is rejected at the header', () {
    final result = ProductImportParser.parseTable([
      ['Name', 'Barcode'],
      ['Tea', '123'],
    ]);
    expect(result.rows, isEmpty);
    expect(result.issues.single.rowNumber, 0);
  });

  test('CSV with quotes and semicolons', () {
    final result = ProductImportParser.parseCsv('name;price;category\r\n"Tea, black";1500;"Food ""dry"""\r\n');
    expect(result.rows.single.name, 'Tea, black');
    expect(result.rows.single.category, 'Food "dry"');
  });

  test('the template round-trips through the xlsx reader', () {
    final result = ProductImportParser.parseXlsx(ProductImportParser.templateXlsx());
    expect(result.issues, isEmpty);
    final row = result.rows.single;
    expect(row.sellPriceMinorUnits, 300000);
    expect(row.wholesalePriceMinorUnits, 275000);
    expect(row.quantity, 24);
    expect(row.unit, 'pcs');
    expect(row.expiryDate, DateTime(2027, 6, 30));
  });

  test('importing creates products, categories and stock, then updates by barcode', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftInventoryRepository(db);

    final first = ProductImportParser.parseTable([
      ['Name', 'Price', 'Cost', 'Wholesale', 'Barcode', 'Category', 'Qty', 'Expiry'],
      ['Tea', '3000', '2000', '2700', '6201234567890', 'Food', '10', '2027-01-31'],
      ['Sugar', '1500', '', '', '', 'food', '', ''],
    ]);
    final summary = await ProductImporter(repo).run(
      storeId: 's1',
      rows: first.rows,
      branchId: 'b1',
      userId: 'u1',
    );
    expect((summary.created, summary.updated), (2, 0));
    expect(summary.failedRows, isEmpty);

    final products = await repo.watchProducts('s1').first;
    final tea = products.firstWhere((p) => p.name == 'Tea');
    final sugar = products.firstWhere((p) => p.name == 'Sugar');
    expect(tea.wholesalePriceMinorUnits, 270000);
    expect(tea.expiryDate, DateTime(2027, 1, 31));
    expect(BarcodeGenerator.isValidEan13(sugar.barcode!), isTrue, reason: 'missing barcode is generated');
    expect(tea.categoryId, sugar.categoryId, reason: 'category matched case-insensitively');
    expect((await repo.watchCategories('s1').first).length, 1);
    expect((await repo.getStockItem(tea.id, 'b1'))?.quantityOnHand, 10);

    final second = ProductImportParser.parseTable([
      ['Name', 'Price', 'Barcode'],
      ['Tea (new box)', '3250', '6201234567890'],
    ]);
    final again = await ProductImporter(repo).run(storeId: 's1', rows: second.rows);
    expect((again.created, again.updated), (0, 1));
    final updated = await repo.getProduct(tea.id);
    expect(updated?.name, 'Tea (new box)');
    expect(updated?.sellPriceMinorUnits, 325000);
    expect(updated?.costPriceMinorUnits, 200000, reason: 'blank cost keeps the old one');
  });
}
