import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/barcode_generator.dart';

void main() {
  test('EAN-13 check digit matches a known real barcode', () {
    // 4006381333931 is a widely published valid EAN-13.
    expect(BarcodeGenerator.ean13CheckDigit('400638133393'), 1);
    expect(BarcodeGenerator.isValidEan13('4006381333931'), isTrue);
    expect(BarcodeGenerator.isValidEan13('4006381333932'), isFalse);
  });

  test('generated codes are valid in-store EAN-13s', () {
    for (var i = 0; i < 200; i++) {
      final code = BarcodeGenerator.newInStoreEan13();
      expect(code, hasLength(13));
      expect(code, startsWith('20'));
      expect(BarcodeGenerator.isValidEan13(code), isTrue, reason: code);
    }
  });
}
