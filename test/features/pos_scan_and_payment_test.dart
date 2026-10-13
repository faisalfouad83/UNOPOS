import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/domain/barcode_scan.dart';
import 'package:unopos/features/pos/domain/payment_math.dart';

const _tea = ProductRecord(id: 'tea', storeId: 's', sku: 'TEA-1', barcode: '6291001', name: 'Green tea');
const _milk = ProductRecord(id: 'milk', storeId: 's', sku: 'MLK', barcode: '6291002', name: 'Milk');
const _old = ProductRecord(id: 'old', storeId: 's', sku: 'OLD', barcode: '6291003', name: 'Old', isActive: false);

void main() {
  group('scanned codes', () {
    test('an exact barcode wins, then an exact SKU (any case)', () {
      expect(matchScannedProduct(const [_tea, _milk], '6291002')?.id, 'milk');
      expect(matchScannedProduct(const [_tea, _milk], ' 6291001 ')?.id, 'tea');
      expect(matchScannedProduct(const [_tea, _milk], 'tea-1')?.id, 'tea');
    });

    test('unknown and inactive products are not matched', () {
      expect(matchScannedProduct(const [_tea, _milk, _old], '999'), isNull);
      expect(matchScannedProduct(const [_tea, _milk, _old], '6291003'), isNull);
      expect(matchScannedProduct(const [_tea], ''), isNull);
    });

    test('a typed search that leaves exactly one product adds it', () {
      expect(singleSearchMatch(const [_tea, _milk], 'green')?.id, 'tea');
      expect(singleSearchMatch(const [_tea, _milk], '6291'), isNull); // both match
      expect(singleSearchMatch(const [_tea, _milk], 'bread'), isNull);
    });

    test('codes ending in Enter, Tab or CR/LF are split apart', () {
      expect(splitScannedCodes('6291001\r\n6291002\n'), ['6291001', '6291002']);
      expect(splitScannedCodes('6291001\t'), ['6291001']);
      expect(splitScannedCodes('\r\n'), isEmpty);
    });
  });

  group('payment amounts', () {
    test('the exact total comes first, then rounded IQD notes above it', () {
      // 3,750 IQD (minor units are ×100).
      final s = paymentSuggestions(375000, currencyCode: 'IQD');
      expect(s.first, 375000);
      expect(s, containsAllInOrder([375000, 400000, 500000, 1000000]));
      expect(s.every((v) => v >= 375000), isTrue);
      expect(s.toSet().length, s.length);
      expect(s.length, lessThanOrEqualTo(6));
    });

    test('a total already on a round amount is not repeated', () {
      expect(paymentSuggestions(500000, currencyCode: 'IQD').where((v) => v == 500000).length, 1);
    });

    test('USD uses dollar notes', () {
      expect(paymentSuggestions(1250, currencyCode: 'USD'), containsAllInOrder([1250, 1500, 2000, 5000]));
    });

    test('change when paying more, remaining when paying less', () {
      const over = PaymentBreakdown(dueMinorUnits: 375000, paidMinorUnits: 500000);
      expect(over.changeMinorUnits, 125000);
      expect(over.remainingMinorUnits, 0);
      expect(over.isPaidInFull, isTrue);

      const under = PaymentBreakdown(dueMinorUnits: 375000, paidMinorUnits: 100000);
      expect(under.changeMinorUnits, 0);
      expect(under.remainingMinorUnits, 275000);
      expect(under.isPaidInFull, isFalse);
    });
  });
}
