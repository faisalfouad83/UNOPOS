import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/inventory/domain/product_expiry.dart';

ProductRecord _p(String id, DateTime? expiry) =>
    ProductRecord(id: id, storeId: 's', sku: id, name: id, expiryDate: expiry);

void main() {
  final today = DateTime(2026, 10, 11, 15, 30);

  test('status by days left', () {
    expect(expiryStatusOf(_p('a', null), now: today), ExpiryStatus.none);
    expect(expiryStatusOf(_p('a', DateTime(2026, 10, 10)), now: today), ExpiryStatus.expired);
    expect(expiryStatusOf(_p('a', DateTime(2026, 10, 11)), now: today), ExpiryStatus.soon, reason: 'expiry day itself');
    expect(expiryStatusOf(_p('a', DateTime(2026, 11, 10)), now: today), ExpiryStatus.soon);
    expect(expiryStatusOf(_p('a', DateTime(2026, 11, 11)), now: today), ExpiryStatus.ok);
    expect(daysUntilExpiry(_p('a', DateTime(2026, 10, 9)), now: today), -2);
  });

  test('near-expiry list is soonest first and skips safe products', () {
    final list = productsNearExpiry([
      _p('later', DateTime(2026, 11, 1)),
      _p('none', null),
      _p('expired', DateTime(2026, 9, 1)),
      _p('safe', DateTime(2027, 1, 1)),
    ], now: today);
    expect(list.map((p) => p.id), ['expired', 'later']);
  });
}
