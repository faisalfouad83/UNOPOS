import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/inventory/data/inventory_repository_drift.dart';
import 'package:unopos/features/inventory/domain/barcode_generator.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/inventory/domain/product_import.dart';
import 'package:unopos/features/inventory/domain/product_importer.dart';

void main() {
  test('reads Arabic headers in any order, with Arabic digits and units', () {
    final result = ProductImportParser.parseTable([
      ['الكمية', 'الاسم', 'سعر البيع', 'الوحدة', 'الباركود', 'تاريخ الانتهاء'],
      ['١٢', 'شاي', '١٬٥٠٠', 'كارتون', '6201234567893.0', '30/6/2027'],
    ]);
    expect(result.issues, isEmpty);
    final row = result.rows.single;
    expect(row.name, 'شاي');
    expect(row.sellPriceMinorUnits, 150000);
    expect(row.quantity, 12);
    expect(row.unit, 'carton');
    expect(row.barcode, '6201234567893');
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
      ['Tea', '3000', '2000', '2700', '6201234567893', 'Food', '10', '2027-01-31'],
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
      ['Tea (new box)', '3250', '6201234567893'],
    ]);
    final again = await ProductImporter(repo).run(storeId: 's1', rows: second.rows);
    expect((again.created, again.updated), (0, 1));
    final updated = await repo.getProduct(tea.id);
    expect(updated?.name, 'Tea (new box)');
    expect(updated?.sellPriceMinorUnits, 325000);
    expect(updated?.costPriceMinorUnits, 200000, reason: 'blank cost keeps the old one');
  });

  group('numbers as people type them', () {
    double? n(String s) => ProductImportParser.parseNumber(s);

    test('currency text and symbols around the number are ignored', () {
      expect(n('د.ع 3000'), 3000);
      expect(n('3000 د.ع'), 3000);
      expect(n('IQD 1,500'), 1500);
      expect(n(r'$12.50'), 12.5);
      expect(n('٣٠٠٠ دينار'), 3000);
    });

    test('thousands separators and decimal commas', () {
      expect(n('1,500'), 1500);
      expect(n('1,500,000'), 1500000);
      expect(n('١٬٥٠٠'), 1500);
      expect(n('١،٥٠٠'), 1500);
      expect(n('3,5'), 3.5);
      expect(n('٣٫٥'), 3.5);
      expect(n('۳٫۵'), 3.5);
      expect(n('0,500'), 0.5);
      expect(n('1.500,50'), 1500.5);
      expect(n('1,500.50'), 1500.5);
      expect(n('1 500'), 1500);
      expect(n('.5'), 0.5);
    });

    test('negatives are recognised; nonsense is not a number', () {
      expect(n('-200'), -200);
      expect(n('(200)'), -200);
      expect(n('د.ع -3000'), -3000);
      expect(n('10-20'), isNull);
      expect(n('1,5.3'), isNull);
      expect(n('abc'), isNull);
    });
  });

  test('negative or unreadable values are reported, not imported', () {
    final result = ProductImportParser.parseTable([
      ['Name', 'Price', 'Cost', 'Qty', 'Barcode', 'Code'],
      ['Tea', 'د.ع 3000', '2,500', '12', '', ''],
      ['Sugar', '-1500', '', '', '', ''],
      ['Rice', '1500', '-10', '', '', ''],
      ['Oil', '1500', '', '-3', '', ''],
      ['Salt', '1500', '', '', '6201234567896', ''],
      ['Milk', '1500', '', '', '', '   '],
      ['Flour', '1500', '-', '', '', 'A 1'],
    ]);
    expect(result.rows.map((r) => r.name), ['Tea', 'Milk']);
    final tea = result.rows.first;
    expect(tea.sellPriceMinorUnits, 300000);
    expect(tea.costPriceMinorUnits, 250000);
    expect(result.rows[1].sku, isNull, reason: 'a code of spaces is no code');
    expect(result.issues.map((i) => (i.rowNumber, i.field)), [
      (3, ProductImportColumn.sellPrice),
      (4, ProductImportColumn.costPrice),
      (5, ProductImportColumn.quantity),
      (6, ProductImportColumn.barcode),
      (8, ProductImportColumn.sku),
    ]);
  });

  test('an empty or unknown unit is left for the importer to decide', () {
    final result = ProductImportParser.parseTable([
      ['Name', 'Price', 'Unit'],
      ['Tea', '1500', ''],
      ['Rice', '1500', 'كيلو'],
      ['Oil', '1500', 'something'],
    ]);
    expect(result.rows.map((r) => r.unit), [null, 'kg', null]);
  });

  test('formula cells are read as the result the file was saved with', () {
    final zip = ZipDecoder().decodeBytes(ProductImportParser.templateXlsx());
    final sheetFile = zip.findFile('xl/worksheets/sheet1.xml')!;
    var xml = utf8.decode(sheetFile.content as List<int>);
    // Price = cost + 750 (worked out as 3000), cost = an error, quantity a
    // formula never worked out.
    xml = xml
        .replaceFirst('<c r="B2" s="2"><v>3000</v></c>', '<c r="B2" s="2"><f>C2+750</f><v>3000</v></c>')
        .replaceFirst('<c r="C2" s="2"><v>2250</v></c>', '<c r="C2" s="2" t="e"><f>1/0</f><v>#DIV/0!</v></c>')
        .replaceFirst('<c r="H2" s="2"><v>24</v></c>', '<c r="H2" s="2"><f>A1*2</f></c>');
    expect(xml, contains('<f>C2+750</f>'));
    final edited = Archive();
    for (final f in zip.files) {
      if (f.name == sheetFile.name) {
        final bytes = utf8.encode(xml);
        edited.addFile(ArchiveFile(f.name, bytes.length, bytes));
      } else {
        edited.addFile(f);
      }
    }
    final result = ProductImportParser.parseXlsx(ZipEncoder().encode(edited)!);
    expect(result.issues, isEmpty);
    final row = result.rows.single;
    expect(row.sellPriceMinorUnits, 300000);
    expect(row.costPriceMinorUnits, isNull, reason: 'an error result reads as empty');
    expect(row.quantity, isNull);
  });

  group('CSV encodings', () {
    const csv = 'الاسم,سعر البيع\r\nشاي,"1,500"\r\n';

    test('UTF-8 with and without the BOM', () {
      for (final bytes in [
        utf8.encode(csv),
        [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)],
      ]) {
        final row = ProductImportParser.parseCsvBytes(bytes).rows.single;
        expect((row.name, row.sellPriceMinorUnits), ('شاي', 150000));
      }
    });

    test('Windows-1256, as Excel on Arabic Windows saves CSV', () {
      // "الاسم,سعر البيع\r\nشاي,1500\r\n" in Windows-1256.
      final bytes = [
        0xC7, 0xE1, 0xC7, 0xD3, 0xE3, 0x2C, 0xD3, 0xDA, 0xD1, 0x20, 0xC7, 0xE1, 0xC8, 0xED, 0xDA, 0x0D, 0x0A, //
        0xD4, 0xC7, 0xED, 0x2C, 0x31, 0x35, 0x30, 0x30, 0x0D, 0x0A,
      ];
      final result = ProductImportParser.parseCsvBytes(bytes);
      expect(result.issues, isEmpty);
      expect((result.rows.single.name, result.rows.single.sellPriceMinorUnits), ('شاي', 150000));
    });

    test('UTF-16 tab-separated ("Unicode text")', () {
      const text = 'Name\tPrice\r\nTea\t2000\r\n';
      final bytes = [
        0xFF,
        0xFE,
        for (final u in text.codeUnits) ...[u & 0xFF, u >> 8],
      ];
      expect(ProductImportParser.parseCsvBytes(bytes).rows.single.sellPriceMinorUnits, 200000);
    });
  });

  group('importing again', () {
    late AppDatabase db;
    late DriftInventoryRepository repo;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = DriftInventoryRepository(db);
    });
    tearDown(() => db.close());

    Future<ProductImportSummary> import(List<List<String?>> table) async {
      final parsed = ProductImportParser.parseTable(table);
      expect(parsed.issues, isEmpty);
      return ProductImporter(repo).run(storeId: 's1', rows: parsed.rows, branchId: 'b1', userId: 'u1');
    }

    Future<int> stockOf(String name) async {
      final p = (await repo.watchProducts('s1').first).firstWhere((p) => p.name == name);
      return (await repo.getStockItem(p.id, 'b1'))?.quantityOnHand ?? 0;
    }

    test('the same file twice changes nothing: no extra stock, no duplicates', () async {
      final sheet = [
        ['Name', 'Price', 'Barcode', 'Unit', 'Qty'],
        ['Tea', '3000', '6201234567893', 'carton', '10'],
        ['Sugar', '1500', '', '', '5'],
      ];
      expect((await import(sheet)).created, 2);
      final again = await import(sheet);
      expect((again.created, again.updated), (0, 2));
      expect(again.failedRows, isEmpty);
      expect((await repo.watchProducts('s1').first).length, 2, reason: 'the code-less row matched by name');
      expect(await stockOf('Tea'), 10);
      expect(await stockOf('Sugar'), 5);
    });

    test('the quantity sets the stock: up or down to the number in the file', () async {
      await import([
        ['Name', 'Price', 'Barcode', 'Qty'],
        ['Tea', '3000', '6201234567893', '10'],
      ]);
      await import([
        ['Name', 'Price', 'Barcode', 'Qty'],
        ['Tea', '3000', '6201234567893', '4'],
      ]);
      expect(await stockOf('Tea'), 4);
      await import([
        ['Name', 'Price', 'Barcode'],
        ['Tea', '3000', '6201234567893'],
      ]);
      expect(await stockOf('Tea'), 4, reason: 'no quantity column: stock untouched');
    });

    test('an empty unit keeps the product unit', () async {
      await import([
        ['Name', 'Price', 'Barcode', 'Unit'],
        ['Rice', '3000', '6201234567893', 'kg'],
      ]);
      await import([
        ['Name', 'Price', 'Barcode', 'Unit'],
        ['Rice', '3250', '6201234567893', ''],
      ]);
      final rice = (await repo.watchProducts('s1').first).single;
      expect((rice.unit, rice.sellPriceMinorUnits), ('kg', 325000));
    });

    test('a code never overwrites a different product', () async {
      final tea = await repo.createProduct(const ProductRecord(
        id: '',
        storeId: 's1',
        sku: 'T-1',
        barcode: '6201234567893',
        name: 'Tea',
        sellPriceMinorUnits: 300000,
      ));
      await repo.createProduct(const ProductRecord(
        id: '',
        storeId: 's1',
        sku: 'C-1',
        barcode: '4006381333931',
        name: 'Coffee',
        sellPriceMinorUnits: 900000,
      ));
      final summary = await import([
        ['Name', 'Price', 'Barcode', 'Code'],
        // A new barcode, but Tea's code: not saved over Tea.
        ['Green tea', '3500', '5012345678900', 'T-1'],
        // Coffee's barcode with Tea's code.
        ['Coffee', '9500', '4006381333931', 'T-1'],
      ]);
      expect(summary.failedRows, [2, 3]);
      final kept = await repo.getProduct(tea.id);
      expect((kept?.name, kept?.barcode), ('Tea', '6201234567893'));
      expect((await repo.watchProducts('s1').first).length, 2);
    });

    test('a code-less row matching several products by name is reported', () async {
      for (final barcode in ['6201234567893', '4006381333931']) {
        await repo.createProduct(
          ProductRecord(id: '', storeId: 's1', sku: barcode, barcode: barcode, name: 'Tea', sellPriceMinorUnits: 1),
        );
      }
      final summary = await import([
        ['Name', 'Price'],
        ['Tea', '3000'],
      ]);
      expect((summary.created, summary.updated), (0, 0));
      expect(summary.failedRows, [2]);
    });
  });
}
