import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xl;

import 'product_code.dart';

/// One product row read from an import file. Prices are in minor units.
class ProductImportRow {
  const ProductImportRow({
    required this.rowNumber,
    required this.name,
    required this.sellPriceMinorUnits,
    this.costPriceMinorUnits,
    this.wholesalePriceMinorUnits,
    this.barcode,
    this.sku,
    this.category,
    this.unit,
    this.quantity,
    this.expiryDate,
  });

  /// 1-based row in the sheet, for error messages.
  final int rowNumber;
  final String name;
  final int sellPriceMinorUnits;

  /// Null when the sheet gives no cost: a product already in the list
  /// keeps its own, a new one gets 0.
  final int? costPriceMinorUnits;
  final int? wholesalePriceMinorUnits;
  final String? barcode;
  final String? sku;
  final String? category;

  /// A unit code ('pcs', 'kg', …); null when the sheet doesn't give one it
  /// recognises: a product already in the list keeps its unit, a new one
  /// is counted in pieces.
  final String? unit;

  /// The stock on hand to have in the branch being imported into, if given.
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

enum ProductImportColumn {
  name,
  sellPrice,
  costPrice,
  wholesalePrice,
  barcode,
  sku,
  category,
  unit,
  quantity,
  expiryDate
}

/// Reads product lists from Excel (.xlsx) or CSV. The first row is the
/// header; columns are matched by name in English, Arabic or Kurdish (in
/// any order, extra columns ignored), so a store's existing spreadsheet
/// usually imports without being rearranged.
///
/// A row whose name or price is missing, or whose optional columns hold
/// something that can't be read for sure (a negative price, a barcode with
/// a wrong check digit, …), is reported instead of being imported with a
/// guessed value.
class ProductImportParser {
  const ProductImportParser._();

  static const Map<ProductImportColumn, List<String>> _headerAliases = {
    ProductImportColumn.name: [
      'name',
      'product',
      'product name',
      'item',
      'الاسم',
      'اسم المنتج',
      'المنتج',
      'المادة',
      'ناو',
      'ناوی کاڵا'
    ],
    ProductImportColumn.sellPrice: [
      'price',
      'sell price',
      'selling price',
      'retail price',
      'سعر البيع',
      'السعر',
      'سعر المفرد',
      'نرخ',
      'نرخی فرۆشتن'
    ],
    ProductImportColumn.costPrice: [
      'cost',
      'cost price',
      'purchase price',
      'سعر الشراء',
      'الكلفة',
      'سعر الكلفة',
      'نرخی کڕین'
    ],
    ProductImportColumn.wholesalePrice: ['wholesale', 'wholesale price', 'سعر الجملة', 'جملة', 'نرخی کۆ'],
    ProductImportColumn.barcode: ['barcode', 'bar code', 'ean', 'الباركود', 'باركود', 'بارکۆد'],
    ProductImportColumn.sku: ['sku', 'code', 'item code', 'الرمز', 'كود', 'رمز المنتج', 'کۆد'],
    ProductImportColumn.category: ['category', 'group', 'الفئة', 'القسم', 'الصنف', 'پۆل'],
    ProductImportColumn.unit: ['unit', 'الوحدة', 'وحدة', 'یەکە'],
    ProductImportColumn.quantity: ['quantity', 'qty', 'stock', 'الكمية', 'العدد', 'المخزون', 'بڕ'],
    ProductImportColumn.expiryDate: [
      'expiry',
      'expiry date',
      'expires',
      'exp',
      'تاريخ الانتهاء',
      'الانتهاء',
      'تاريخ الصلاحية',
      'بەسەرچوون'
    ],
  };

  static const Map<String, String> _unitAliases = {
    'pcs': 'pcs',
    'piece': 'pcs',
    'pieces': 'pcs',
    'pc': 'pcs',
    'قطعة': 'pcs',
    'حبة': 'pcs',
    'دانە': 'pcs',
    'bottle': 'bottle',
    'قنينة': 'bottle',
    'بطل': 'bottle',
    'بوتڵ': 'bottle',
    'carton': 'carton',
    'كارتون': 'carton',
    'كرتون': 'carton',
    'کارتۆن': 'carton',
    'box': 'box',
    'صندوق': 'box',
    'علبة': 'box',
    'قوطی': 'box',
    'pack': 'pack',
    'عبوة': 'pack',
    'رزمة': 'pack',
    'packet': 'packet',
    'باكيت': 'packet',
    'پاکەت': 'packet',
    'tikka': 'tikka',
    'تكة': 'tikka',
    'تكه': 'tikka',
    'bale': 'bale',
    'بالة': 'bale',
    'باله': 'bale',
    'شليف': 'bale',
    'g': 'g',
    'gram': 'g',
    'gm': 'g',
    'غرام': 'g',
    'غم': 'g',
    'گرام': 'g',
    'ml': 'ml',
    'milliliter': 'ml',
    'مل': 'ml',
    'ملي لتر': 'ml',
    'ملليلتر': 'ml',
    'ملیلیتر': 'ml',
    'kg': 'kg',
    'kilo': 'kg',
    'كغم': 'kg',
    'كيلو': 'kg',
    'كيلوغرام': 'kg',
    'کیلۆ': 'kg',
    'l': 'l',
    'liter': 'l',
    'litre': 'l',
    'لتر': 'l',
    'لیتر': 'l',
  };

  /// Direction marks and zero-width spaces that spreadsheets with Arabic
  /// text often carry invisibly around values.
  static final _invisible = RegExp('[\u200B\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]');

  static String _clean(String s) => s.replaceAll(_invisible, '').trim();

  static String _norm(String s) => _clean(s).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// A header cell as it's matched: "Price (IQD)", "السعر:" and "Name *"
  /// match like "price", "السعر" and "name".
  static String _header(String s) =>
      _norm(s.replaceAll(RegExp(r'[(\[][^)\]]*[)\]]'), ' ')).replaceAll(RegExp(r'[\s:*]+$'), '');

  /// Parses [table] (rows of cell text, header first).
  static ProductImportParseResult parseTable(List<List<String?>> table) {
    final issues = <ProductImportIssue>[];
    final rows = <ProductImportRow>[];
    final headerIndex = table.indexWhere((r) => r.any((c) => _clean(c ?? '').isNotEmpty));
    if (headerIndex < 0) {
      return const ProductImportParseResult(rows: [], issues: [ProductImportIssue(0, ProductImportColumn.name)]);
    }

    final header = table[headerIndex].map((c) => _header(c ?? '')).toList();
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
        final v = _clean(cells[i] ?? '');
        return v.isEmpty ? null : v;
      }

      if (cells.every((c) => _clean(c ?? '').isEmpty)) continue;
      final rowNumber = r + 1;
      final name = cell(ProductImportColumn.name)?.replaceAll(RegExp(r'\s+'), ' ');
      final price = _money(cell(ProductImportColumn.sellPrice));
      if (name == null) {
        issues.add(ProductImportIssue(rowNumber, ProductImportColumn.name));
        continue;
      }
      if (price == null) {
        issues.add(ProductImportIssue(rowNumber, ProductImportColumn.sellPrice));
        continue;
      }

      // Optional columns: left empty (or holding no number at all, like
      // "-") they're simply not given; anything else must read cleanly.
      ProductImportColumn? bad;
      int? optionalMoney(ProductImportColumn c) {
        final text = cell(c);
        if (text == null || !_hasDigit(text)) return null;
        final value = _money(text);
        if (value == null) bad ??= c;
        return value;
      }

      final cost = optionalMoney(ProductImportColumn.costPrice);
      final wholesale = optionalMoney(ProductImportColumn.wholesalePrice);

      int? quantity;
      final quantityText = cell(ProductImportColumn.quantity);
      if (quantityText != null && _hasDigit(quantityText)) {
        final n = parseNumber(quantityText);
        if (n == null || n < 0) {
          bad ??= ProductImportColumn.quantity;
        } else {
          quantity = n.round();
        }
      }

      final barcode = _code(cell(ProductImportColumn.barcode));
      if (barcode != null && validateProductCode(barcode) != null) bad ??= ProductImportColumn.barcode;
      // An internal code may be any short code; only a barcode must carry
      // a correct check digit.
      final sku = _code(cell(ProductImportColumn.sku));
      final skuProblem = sku == null ? null : validateProductCode(sku);
      if (skuProblem != null && skuProblem != ProductCodeError.badCheckDigit) bad ??= ProductImportColumn.sku;

      if (bad != null) {
        issues.add(ProductImportIssue(rowNumber, bad!));
        continue;
      }

      final unitText = cell(ProductImportColumn.unit);
      rows.add(ProductImportRow(
        rowNumber: rowNumber,
        name: name,
        sellPriceMinorUnits: price,
        costPriceMinorUnits: cost,
        wholesalePriceMinorUnits: wholesale,
        barcode: barcode,
        sku: sku,
        category: cell(ProductImportColumn.category)?.replaceAll(RegExp(r'\s+'), ' '),
        unit: unitText == null ? null : _unitAliases[_norm(unitText)],
        quantity: quantity,
        expiryDate: _date(cell(ProductImportColumn.expiryDate)),
      ));
    }
    return ProductImportParseResult(rows: rows, issues: issues);
  }

  static const _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const _easternArabicDigits = '۰۱۲۳۴۵۶۷۸۹';

  /// Arabic-Indic and Eastern Arabic (Persian/Kurdish) digits as 0-9.
  static String _asciiDigits(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      final a = _arabicIndicDigits.indexOf(ch);
      final e = _easternArabicDigits.indexOf(ch);
      buffer.write(a >= 0 ? '$a' : (e >= 0 ? '$e' : ch));
    }
    return buffer.toString();
  }

  static bool _hasDigit(String text) => RegExp(r'\d').hasMatch(_asciiDigits(text));

  /// Reads a number the way people type one into a spreadsheet: "1500",
  /// "1,500", "١٬٥٠٠", "3,5", "٣٫٥", "1.500,50", "د.ع 3000", "3000 IQD",
  /// "-200" or "(200)". Currency names and symbols around the number are
  /// ignored. A single comma followed by exactly three digits ("1,500") is
  /// a thousands separator, otherwise ("3,5", "0,500") a decimal comma;
  /// when both "," and "." appear, the last one is the decimal point.
  ///
  /// Null when there is no number, more than one ("10-20"), or separators
  /// that don't make a number ("1,5.3"). Negative numbers come back
  /// negative; it's for the caller to refuse them.
  static double? parseNumber(String text) {
    var s = _asciiDigits(_clean(text))
        .replaceAll('٫', '.') // Arabic decimal separator
        .replaceAll(RegExp('[٬،]'), ',') // Arabic thousands separator, Arabic comma
        .replaceAll(RegExp("[\u00A0\u2007\u2009\u202F'’]"), ''); // grouping spaces and apostrophes
    s = s.trim();
    final plain = double.tryParse(s);
    if (plain != null && plain.isFinite && RegExp(r'^[-+]?\d').hasMatch(s)) return plain;

    final runs = RegExp(r'\d[\d.,]*').allMatches(s).toList();
    if (runs.length != 1) return null;
    final run = runs.single;
    var digits = run.group(0)!.replaceFirst(RegExp(r'[.,]+$'), '');
    final before = s.substring(0, run.start);
    final after = s.substring(run.start + digits.length);
    // ".5" is a number, the dot in "د.ع 5" is not.
    if (RegExp(r'(^|[\s\-−+(])[.,]$').hasMatch(before)) digits = '0.$digits';

    final value = _readDigits(digits);
    if (value == null) return null;
    final negative = RegExp('[-−]').hasMatch(before) ||
        RegExp('^\\s*[-−]').hasMatch(after) ||
        (before.contains('(') && after.contains(')'));
    return negative ? -value : value;
  }

  /// [run] is digits with "," and "." in it; see [parseNumber].
  static double? _readDigits(String run) {
    bool groups(List<String> parts) =>
        parts.first.isNotEmpty && parts.first.length <= 3 && parts.skip(1).every((p) => RegExp(r'^\d{3}$').hasMatch(p));

    final lastDot = run.lastIndexOf('.');
    final lastComma = run.lastIndexOf(',');
    if (lastDot >= 0 && lastComma >= 0) {
      final decimal = lastDot > lastComma ? '.' : ',';
      final group = decimal == '.' ? ',' : '.';
      final at = run.lastIndexOf(decimal);
      final whole = run.substring(0, at);
      final fraction = run.substring(at + 1);
      if (whole.contains(decimal) || fraction.contains(group) || !groups(whole.split(group))) return null;
      return double.tryParse('${whole.replaceAll(group, '')}.$fraction');
    }
    if (lastDot < 0 && lastComma < 0) return double.tryParse(run);
    final separator = lastComma >= 0 ? ',' : '.';
    final parts = run.split(separator);
    if (parts.length > 2) return groups(parts) ? double.tryParse(parts.join()) : null;
    final (whole, fraction) = (parts[0], parts[1]);
    final thousands = separator == ',' && fraction.length == 3 && groups(parts) && !whole.startsWith('0');
    return double.tryParse(thousands ? '$whole$fraction' : '$whole.$fraction');
  }

  /// Money in minor units; null when unreadable or negative.
  static int? _money(String? text) {
    if (text == null) return null;
    final n = parseNumber(text);
    return n == null || n < 0 ? null : (n * 100).round();
  }

  /// Barcodes typed into Excel often come back as numbers ("6.2e12" or
  /// "6201234567890.0"), or are copied with the spaces printed under the
  /// bars ("6 201234 567890"); normalize those back to their digits.
  static String? _code(String? text) {
    if (text == null) return null;
    var c = _asciiDigits(text).trim();
    if (RegExp(r'^[\d\s]+$').hasMatch(c)) c = c.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'^\d+\.0+$').hasMatch(c)) return c.substring(0, c.indexOf('.'));
    if (RegExp(r'^\d+(\.\d+)?[eE]\+?\d+$').hasMatch(c)) {
      final n = double.tryParse(c);
      if (n != null) return n.toStringAsFixed(0);
    }
    return c.isEmpty ? null : c;
  }

  static DateTime? _date(String? text) {
    if (text == null) return null;
    final t = _asciiDigits(text).trim();
    // A date worked out by a formula arrives as Excel's day number (days
    // since 30 Dec 1899); 20000-80000 covers 1954-2119.
    if (RegExp(r'^\d{5}(\.\d+)?$').hasMatch(t)) {
      final serial = double.parse(t);
      if (serial < 20000 || serial >= 80000) return null;
      final d = DateTime.utc(1899, 12, 30).add(Duration(days: serial.floor()));
      return DateTime(d.year, d.month, d.day);
    }
    final iso = DateTime.tryParse(t);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    // d/m/yyyy or d-m-yyyy, the usual way dates are written locally.
    final m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$').firstMatch(t);
    if (m == null) return null;
    final (day, month, year) = (int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    final date = DateTime(year, month, day);
    return date.month == month && date.day == day ? date : null;
  }

  static ProductImportParseResult parseXlsx(List<int> bytes) {
    final book = xl.Excel.decodeBytes(bytes);
    final names = book.tables.keys.toList();
    final name = names.firstWhere((n) => book.tables[n]!.maxRows > 0, orElse: () => names.first);
    Map<String, String>? results;
    final table = [
      for (final row in book.tables[name]!.rows)
        [
          for (final cell in row)
            switch (cell?.value) {
              // The reader keeps only a formula's text: use the result
              // the file was saved with instead.
              xl.FormulaCellValue() => (results ??= _formulaResults(bytes, name))[cell!.cellIndex.cellId],
              final value => _cellText(value),
            },
        ],
    ];
    return parseTable(table);
  }

  static String? _cellText(xl.CellValue? value) => switch (value) {
        null => null,
        xl.DateCellValue() => _isoDate(value.asDateTimeLocal()),
        xl.DateTimeCellValue() => _isoDate(value.asDateTimeLocal()),
        xl.DoubleCellValue(:final value) =>
          value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString(),
        _ => value.toString(),
      };

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// What each formula cell of sheet [sheetName] showed when the file was
  /// last saved ("C2" → "4500"), read from the file itself. Cells whose
  /// formula ended in an error (#DIV/0!, …) or that were never worked out
  /// are left out, so they read as empty.
  static Map<String, String> _formulaResults(List<int> bytes, String sheetName) {
    try {
      final zip = ZipDecoder().decodeBytes(bytes);
      String read(String path) {
        final file = zip.findFile(path);
        return file == null ? '' : utf8.decode(file.content as List<int>, allowMalformed: true);
      }

      String? attr(String tag, String name) => RegExp('\\s$name=["\']([^"\']*)["\']').firstMatch(tag)?.group(1);

      String? relationId;
      for (final m in RegExp(r'<(?:\w+:)?sheet\s[^>]*>').allMatches(read('xl/workbook.xml'))) {
        if (_xmlText(attr(m.group(0)!, 'name') ?? '') == sheetName) {
          relationId = attr(m.group(0)!, r'\w+:id');
          break;
        }
      }
      String? target;
      for (final m in RegExp(r'<(?:\w+:)?Relationship\s[^>]*>').allMatches(read('xl/_rels/workbook.xml.rels'))) {
        if (relationId != null && attr(m.group(0)!, 'Id') == relationId) target = attr(m.group(0)!, 'Target');
      }
      if (target == null) return const {};
      final sheet = read(target.startsWith('/') ? target.substring(1) : 'xl/$target');

      final results = <String, String>{};
      final cells = RegExp(r'<(?:\w+:)?c(\s[^>]*[^/])>(.*?)</(?:\w+:)?c>', dotAll: true);
      final value = RegExp(r'<(?:\w+:)?v(?:\s[^>]*)?>([^<]*)</(?:\w+:)?v>');
      for (final m in cells.allMatches(sheet)) {
        final attrs = m.group(1)!;
        final body = m.group(2)!;
        if (!RegExp(r'<(?:\w+:)?f[\s>/]').hasMatch(body) || attr(attrs, 't') == 'e') continue;
        final ref = attr(attrs, 'r');
        final v = value.firstMatch(body)?.group(1);
        if (ref != null && v != null) results[ref] = _xmlText(v);
      }
      return results;
    } catch (_) {
      return const {};
    }
  }

  static String _xmlText(String s) => s
      .replaceAllMapped(RegExp(r'&#(x[0-9a-fA-F]+|\d+);'), (m) {
        final code = m[1]!;
        return String.fromCharCode(code.startsWith('x') ? int.parse(code.substring(1), radix: 16) : int.parse(code));
      })
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');

  static ProductImportParseResult parseCsv(String text) => parseTable(_splitCsv(text));

  /// Reads a CSV file's bytes: UTF-8 (with or without the BOM Excel adds
  /// for "CSV UTF-8"), UTF-16 ("Unicode text"), or — what Excel on an
  /// Arabic Windows saves as plain "CSV" — Windows-1256.
  static ProductImportParseResult parseCsvBytes(List<int> bytes) => parseCsv(decodeText(bytes));

  /// See [parseCsvBytes].
  static String decodeText(List<int> bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    }
    if (bytes.length >= 2 && ((bytes[0] == 0xFF && bytes[1] == 0xFE) || (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
      final littleEndian = bytes[0] == 0xFF;
      return String.fromCharCodes([
        for (var i = 2; i + 1 < bytes.length; i += 2)
          littleEndian ? bytes[i] | (bytes[i + 1] << 8) : (bytes[i] << 8) | bytes[i + 1],
      ]);
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return String.fromCharCodes([for (final b in bytes) b < 0x80 ? b : _cp1256[b - 0x80]]);
    }
  }

  /// Windows-1256 (Arabic) bytes 0x80-0xFF as Unicode; 0x00-0x7F is ASCII.
  static const _cp1256 = [
    0x20AC, 0x067E, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, //
    0x02C6, 0x2030, 0x0679, 0x2039, 0x0152, 0x0686, 0x0698, 0x0688,
    0x06AF, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
    0x06A9, 0x2122, 0x0691, 0x203A, 0x0153, 0x200C, 0x200D, 0x06BA,
    0x00A0, 0x060C, 0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7,
    0x00A8, 0x00A9, 0x06BE, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF,
    0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x00B6, 0x00B7,
    0x00B8, 0x00B9, 0x061B, 0x00BB, 0x00BC, 0x00BD, 0x00BE, 0x061F,
    0x06C1, 0x0621, 0x0622, 0x0623, 0x0624, 0x0625, 0x0626, 0x0627,
    0x0628, 0x0629, 0x062A, 0x062B, 0x062C, 0x062D, 0x062E, 0x062F,
    0x0630, 0x0631, 0x0632, 0x0633, 0x0634, 0x0635, 0x0636, 0x00D7,
    0x0637, 0x0638, 0x0639, 0x063A, 0x0640, 0x0641, 0x0642, 0x0643,
    0x00E0, 0x0644, 0x00E2, 0x0645, 0x0646, 0x0647, 0x0648, 0x00E7,
    0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x0649, 0x064A, 0x00EE, 0x00EF,
    0x064B, 0x064C, 0x064D, 0x064E, 0x00F4, 0x064F, 0x0650, 0x00F7,
    0x0651, 0x00F9, 0x0652, 0x00FB, 0x00FC, 0x200E, 0x200F, 0x06D2,
  ];

  /// Minimal RFC 4180 CSV reader (quoted fields, escaped quotes, comma,
  /// semicolon or tab separated, CRLF) — enough for spreadsheets saved as
  /// CSV.
  static List<List<String?>> _splitCsv(String text) {
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    final firstLine = text.split('\n').first;
    var delimiter = ',';
    for (final d in [';', '\t']) {
      if (d.allMatches(firstLine).length > delimiter.allMatches(firstLine).length) delimiter = d;
    }
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
      for (final h in [
        'الاسم',
        'سعر البيع',
        'سعر الشراء',
        'سعر الجملة',
        'الباركود',
        'الفئة',
        'الوحدة',
        'الكمية',
        'تاريخ الانتهاء'
      ])
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
