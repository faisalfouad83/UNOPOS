import 'dart:math';

import 'inventory_repository.dart';

/// Generates barcodes for products that arrive without one, so they can
/// still be printed as labels and scanned at checkout.
///
/// Codes are EAN-13 in the GS1 "restricted circulation" range (prefix 20),
/// which is reserved for in-store use — it never collides with a real
/// manufacturer barcode, and every ordinary retail scanner reads it.
class BarcodeGenerator {
  const BarcodeGenerator._();

  static const String _inStorePrefix = '20';
  static final Random _random = Random.secure();

  /// A random in-store EAN-13 (13 digits, valid check digit).
  static String newInStoreEan13() {
    final buffer = StringBuffer(_inStorePrefix);
    for (var i = 0; i < 10; i++) {
      buffer.write(_random.nextInt(10));
    }
    final first12 = buffer.toString();
    return '$first12${ean13CheckDigit(first12)}';
  }

  /// Like [newInStoreEan13], but retries until the code isn't already
  /// assigned to another product in this store.
  static Future<String> newUniqueBarcode(InventoryRepository repo, String storeId) async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final code = newInStoreEan13();
      if (await repo.findByBarcode(storeId, code) == null) return code;
    }
    throw StateError('Could not generate a unique barcode');
  }

  /// Standard EAN-13 checksum over the first 12 digits.
  static int ean13CheckDigit(String first12) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = first12.codeUnitAt(i) - 48;
      sum += i.isEven ? digit : digit * 3;
    }
    return (10 - sum % 10) % 10;
  }

  static bool isValidEan13(String code) {
    if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;
    return ean13CheckDigit(code.substring(0, 12)) == code.codeUnitAt(12) - 48;
  }
}
