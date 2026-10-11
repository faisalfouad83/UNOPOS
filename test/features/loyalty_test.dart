import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/domain/loyalty.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

CartLine _line(String id, int price, int qty, {double tax = 0, int discount = 0}) => CartLine(
      product: ProductRecord(id: id, storeId: 's', sku: id, name: id, sellPriceMinorUnits: price),
      quantity: qty,
      taxRatePercent: tax,
      discountAmountMinorUnits: discount,
    );

void main() {
  test('points earned per full amount spent', () {
    expect(Loyalty.pointsEarned(350000, 100000), 3); // 3,500 IQD at 1 point per 1,000
    expect(Loyalty.pointsEarned(350000, 0), 0);
  });

  test('redeemable points are capped by balance and by the total', () {
    expect(Loyalty.maxRedeemable(balance: 40, pointValueMinor: 5000, payableMinorUnits: 1000000), 40);
    expect(Loyalty.maxRedeemable(balance: 400, pointValueMinor: 5000, payableMinorUnits: 100000), 20);
    expect(Loyalty.maxRedeemable(balance: 40, pointValueMinor: 0, payableMinorUnits: 100000), 0);
  });

  test('a points discount is spread across lines and keeps totals exact', () {
    final lines = [_line('a', 300000, 1), _line('b', 100000, 1, discount: 10000), _line('c', 50001, 1)];
    final discounted = Loyalty.applyDiscount(lines, 100000);
    final added = [for (var i = 0; i < 3; i++) discounted[i].discountAmountMinorUnits - lines[i].discountAmountMinorUnits];
    expect(added.fold(0, (a, b) => a + b), 100000);
    expect(added[0], greaterThan(added[1]));
    final before = lines.fold(0, (s, l) => s + l.lineTotalMinorUnits);
    final after = discounted.fold(0, (s, l) => s + l.lineTotalMinorUnits);
    expect(before - after, 100000);
  });

  test('tax is recalculated on the discounted price', () {
    final discounted = Loyalty.applyDiscount([_line('a', 100000, 1, tax: 10)], 20000);
    expect(discounted.single.taxMinorUnits, 8000);
    expect(discounted.single.lineTotalMinorUnits, 88000);
  });

  test('the discount never exceeds what the lines are worth', () {
    final discounted = Loyalty.applyDiscount([_line('a', 10000, 1)], 999999);
    expect(discounted.single.lineTotalMinorUnits, 0);
  });
}
