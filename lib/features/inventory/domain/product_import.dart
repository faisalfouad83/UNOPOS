import 'package:excel/excel.dart' as xl;

/// One product row read from an import file. Prices are in minor units.
class ProductImportRow {
  const ProductImportRow({
    required this.rowNumber,
    required this.name,
    required this.sellPriceMinorUnits,
    this.costPriceMinorUnits = 0,
    this.wholesalePriceMinorUnits,
    this.barcode,
    this.sku,
    this.category,
    this.unit = 'pcs',
    this.quantity,
    this.expiryDate,
  });

  /// 1-based row in the sheet, for error messages.
  final int rowNumber;
  final String name;
  final int sellPriceMinorUnits;
  final int costPriceMinorUnits;
  final int? wholesalePriceMinorUnits;
  final String? barcode;
  final String? sku;
  final String? category;
  final String unit;

  /// Opening stock to add for this product, if given.
  final int? quantity;
  final DateTime? expiryDate;
}

class ProductImportIssue {
  const ProductImportIssue(this.rowNumber, this.field);

  /// 1-based sheet row; 0 for problems with the header row.
  final int rowNumber;

  /// The column that's missing or unreadable (one of [ProductImportColumn]).
  final ProductImportColumn field;
}

class ProductImportParseResult {
  const ProductImportParseResult({required this.rows, required this.issues});
  final List<ProductImportRow> rows;
  final List<ProductImportIssue> issues;
}

enum ProductImportColumn { name, sellPrice, costPrice, wholesalePrice, barcode, sku, category, unit, quantity, expiryDate }

/// Reads product lists from Excel (.xlsx) or CSV. The first row is the
/// header; columns are matched by name in English, Arabic or Kurdish (in
/// any order, extra columns ignored), so a store's existing spreadsheet
/// usually imports without being rearranged.
class ProductImportParser {
  const ProductImportParser._();

  static const Map<ProductImportColumn, List<String>> _headerAliases = {
    ProductImportColumn.name: ['name', 'product', 'product name', 'item', 'الاسم', 'اسم المنتج', 'المنتج', 'المادة', 'ناو', 'ناوی کاڵا'],
    ProductImportColumn.sellPrice: ['price', 'sell price', 'selling price', 'retail price', 'سعر البيع', 'السعر', 'سعر المفرد', 'نرخ', 'نرخی فرۆشتن'],
    ProductImportColumn.costPrice: ['cost', 'cost price', 'purchase price', 'سعر الشراء', 'الكلفة', 'سعر الكلفة', 'نرخی کڕین'],
    ProductImportColumn.wholesalePrice: ['wholesale', 'wholesale price', 'سعر الجملة', 'جملة', 'نرخی کۆ'],
    ProductImportColumn.barcode: ['barcode', 'bar code', 'ean', 'الباركود', 'باركود', 'بارکۆد'],
    ProductImportColumn.sku: ['sku', 'code', 'item code', 'الرمز', 'كود', 'رمز المنتج', 'کۆد'],
    ProductImportColumn.category: ['category', 'group', 'الفئة', 'القسم', 'الصنف', 'پۆل'],
    ProductImportColumn.unit: ['unit', 'الوحدة', 'وحدة', 'یەکە'],
    ProductImportColumn.quantity: ['quantity', 'qty', 'stock', 'الكمية', 'العدد', 'المخزون', 'بڕ'],
    ProductImportColumn.expiryDate: ['expiry', 'expiry date', 'expires', 'exp', 'تاريخ الانتهاء', 'الانتهاء', 'تاريخ الصلاحية', 'بەسەرچوون'],
  };

  static const Map<String, String> _unitAliases = {
    'pcs': 'pcs', 'piece': 'pcs', 'pieces': 'pcs', 'pc': 'pcs', 'قطعة': 'pcs', 'حبة': 'pcs', 'دانە': 'pcs',
    'bottle': 'bottle', 'قنينة': 'bottle', 'بطل': 'bottle', 'بوتڵ': 'bottle',
    'carton': 'carton', 'كارتون': 'carton', 'كرتون': 'carton', 'کارتۆن': 'carton',
    'box': 'box', 'صندوق': 'box', 'علبة': 'box', 'قوطی': 'box',
    'pack': 'pack', 'عبوة': 'pack', 'رزمة': 'pack',
    'packet': 'packet', 'باكيت': 'packet', 'پاکەت': 'packet',
    'tikka': 'tikka', 'تكة': 'tikka', 'تكه': 'tikka',
    'bale': 'bale', 'بالة': 'bale', 'باله': 'bale', 'شليف': 'bale',
    'g': 'g', 'gram': 'g', 'gm': 'g', 'غرام': 'g', 'غم': 'g', 'گرام': 'g',
    'ml': 'ml', 'milliliter': 'ml', 'مل': 'ml', 'ملي لتر': 'ml', 'ملليلتر': 'ml', 'ملیلیتر': 'ml',
    'kg': 'kg', 'kilo': 'kg', 'كغم': 'kg', 'كيلو': 'kg', 'كيلوغرام': 'kg', 'کیلۆ': 'kg',
    'l': 'l', 'liter': 'l', 'litre': 'l', 'لتر': 'l', 'لیتر': 'l',
  };

  static String _norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Parses [table] (rows of cell text, header first).
  static ProductImportParseResult parseTable(List<List<String?>> table) {
    final issues = <ProductImportIssue>[];
    final rows = <ProductImportRow>[];
    final headerIndex = table.indexWhere((r) => r.any((c) => (c ?? '').trim().isNotEmpty));
    if (headerIndex < 0) {
      return const ProductImportParseResult(rows: [], issues: [ProductImportIssue(0, ProductImportColumn.name)]);
    }

    final header = table[headerIndex].map((c) => _norm(c ?? '')).toList();
    final columns = <ProductImportColumn, int>{};
    for (final entry in _headerAliases.entries) {
      final i = header.indexWhere((h) => entry.value.contains(h));
      if (i >= 0) columns[entry.key] = i;
    }
    for (final required in [ProductImportColumn.name, ProductImportColumn.sellPrice]) {
      if (!columns.containsKey(required)) issues.add(ProductImportIssue(0, required));
    }
    if (issues.isNotEmpty) return ProductImportParseResult(rows: const [], issues: issues);

    for (var r = headerIndex + 1; r < table.length; r++) {
      final cells = table[r];
      String? cell(ProductImportColumn c) {
        final i = columns[c];
        if (i == null || i >= cells.length) return null;
        final v = cells[i]?.trim();
        return (v == null || v.isEmpty) ? null : v;
      }

      if (cells.every((c) => (c ?? '').trim().isEmpty)) continue;
      final rowNumber = r + 1;
      final name = cell(ProductImportColumn.name);
      final price = _money(cell(ProductImportColumn.sellPrice));
      if (name == null) {
        issues.add(ProductImportIssue(rowNumber, ProductImportColumn.name));
        continue;
      }
      if (price == null) {
        issues.add(ProductImportIssue(rowNumber, ProductImportColumn.sellPrice));
        continue;
      }
      final unitText = cell(ProductImportColumn.unit);
      rows.add(ProductImportRow(
        rowNumber: rowNumber,
        name: name,
        sellPriceMinorUnits: price,
        costPriceMinorUnits: _money(cell(ProductImportColumn.costPrice)) ?? 0,
        wholesalePriceMinorUnits: _money(cell(ProductImportColumn.wholesalePrice)),
        barcode: _code(cell(ProductImportColumn.barcode)),
        sku: _code(cell(ProductImportColumn.sku)),
        category: cell(ProductImportColumn.category),
        unit: unitText == null ? 'pcs' : (_unitAliases[_norm(unitText)] ?? 'pcs'),
        quantity: _number(cell(ProductImportColumn.quantity))?.round(),
        expiryDate: _date(cell(ProductImportColumn.expiryDate)),
      ));
    }
    return ProductImportParseResult(rows: rows, issues: issues);
  }

  /// "1,500", "١٥٠٠", "1500.50 IQD" → number.
  static double? _number(String? text) {
    if (text == null) return null;
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final ch in text.split('')) {
      final a = arabicDigits.indexOf(ch);
      final p = persianDigits.indexOf(ch);
      if (a >= 0) {
        buffer.write(a);
      } else if (p >= 0) {
        buffer.write(p);
      } else if (ch == '٫') {
        buffer.write('.');
      } else if (RegExp(r'[0-9.\-]').hasMatch(ch)) {
        buffer.write(ch);
      }
    }
    return double.tryParse(buffer.toString());
  }

  static int? _money(String? text) {
    final n = _number(text);
    return n == null ? null : (n * 100).round();
  }

  /// Barcodes typed into Excel often come back as numbers ("6.2e12" or
  /// "6201234567890.0"); normalize those back to their digits.
  static String? _code(String? text) {
    if (text == null) return null;
    if (RegExp(r'^\d+\.0+$').hasMatch(text)) return text.substring(0, text.indexOf('.'));
    if (RegExp(r'^\d+(\.\d+)?[eE]\+?\d+$').hasMatch(text)) {
      final n = double.tryParse(text);
      if (n != null) return n.toStringAsFixed(0);
    }
    return text;
  }

  static DateTime? _date(String? text) {
    if (text == null) return null;
    final iso = DateTime.tryParse(text);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    // d/m/yyyy or d-m-yyyy, the usual way dates are written locally.
    final m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$').firstMatch(text);
    if (m != null) return DateTime(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
    return null;
  }

  static ProductImportParseResult parseXlsx(List<int> bytes) {
    final book = xl.Excel.decodeBytes(bytes);
    final sheet = book.tables.values.firstWhere((s) => s.maxRows > 0, orElse: () => book.tables.values.first);
    final table = [
      for (final row in sheet.rows) [for (final cell in row) _cellText(cell?.value)],
    ];
    return parseTable(table);
  }

  static String? _cellText(xl.CellValue? value) => switch (value) {
        null => null,
        xl.DateCellValue() => _isoDate(value.asDateTimeLocal()),
        xl.DateTimeCellValue() => _isoDate(value.asDateTimeLocal()),
        xl.DoubleCellValue(:final value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString(),
        _ => value.toString(),
      };

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static ProductImportParseResult parseCsv(String text) => parseTable(_splitCsv(text));

  /// Minimal RFC 4180 CSV reader (quoted fields, escaped quotes, commas or
  /// semicolons, CRLF) — enough for spreadsheets saved as CSV.
  static List<List<String?>> _splitCsv(String text) {
    if (text.startsWith('﻿')) text = text.substring(1);
    final firstLine = text.split('\n').first;
    final delimiter = ';'.allMatches(firstLine).length > ','.allMatches(firstLine).length ? ';' : ',';
    final rows = <List<String?>>[];
    var row = <String?>[];
    final field = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(ch);
        }
      } else if (ch == '"') {
        inQuotes = true;
      } else if (ch == delimiter) {
        row.add(field.toString());
        field.clear();
      } else if (ch == '\n' || ch == '\r') {
        if (ch == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        row.add(field.toString());
        field.clear();
        rows.add(row);
        row = <String?>[];
      } else {
        field.write(ch);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      rows.add(row);
    }
    return rows;
  }

  /// A ready-to-fill .xlsx with the header row (Arabic + English names
  /// both work) and one example product.
  static List<int> templateXlsx() {
    final book = xl.Excel.createExcel();
    final sheet = book[book.getDefaultSheet()!];
    sheet.appendRow([
      for (final h in ['الاسم', 'سعر البيع', 'سعر الشراء', 'سعر الجملة', 'الباركود', 'الفئة', 'الوحدة', 'الكمية', 'تاريخ الانتهاء'])
        xl.TextCellValue(h),
    ]);
    sheet.appendRow([
      xl.TextCellValue('شاي 500 غم'),
      xl.IntCellValue(3000),
      xl.IntCellValue(2250),
      xl.IntCellValue(2750),
      xl.TextCellValue(''),
      xl.TextCellValue('مواد غذائية'),
      xl.TextCellValue('قطعة'),
      xl.IntCellValue(24),
      xl.TextCellValue('2027-06-30'),
    ]);
    return book.encode()!;
  }
}
