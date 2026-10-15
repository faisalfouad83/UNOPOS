import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

const _tea = ProductRecord(
    id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 300000, costPriceMinorUnits: 200000);
const _sugar = ProductRecord(
    id: 'sugar', storeId: 's', sku: 'sugar', name: 'Sugar', sellPriceMinorUnits: 100000, costPriceMinorUnits: 80000);

void main() {
  late ProviderContainer container;
  late CartController cart;
  CartState state() => container.read(cartControllerProvider);

  setUp(() {
    container = ProviderContainer();
    cart = container.read(cartControllerProvider.notifier)
      ..addProduct(_tea)
      ..addProduct(_sugar);
  });
  tearDown(() => container.dispose());

  test('line discount by percent and by amount', () {
    final line = state().lines.first;
    cart.setLineDiscount('tea', line.discountFor(isPercent: true, value: 10));
    expect(state().lines.first.discountAmountMinorUnits, 30000);
    cart.setLineDiscount('tea', line.discountFor(isPercent: false, value: 50000));
    expect(state().grandTotalMinorUnits, 350000);
  });

  test('100% line discount is free, or cost + 5% when the store keeps a margin', () {
    final line = state().lines.first;
    expect(line.discountFor(isPercent: true, value: 100), 300000);
    expect(line.discountFor(isPercent: true, value: 100, keepMargin: true), 300000 - 210000);
    // A partial discount isn't affected by the setting.
    expect(line.discountFor(isPercent: true, value: 50, keepMargin: true), 150000);
  });

  test('invoice discount is spread over the lines and shows in the totals', () {
    cart.setInvoiceDiscount(const InvoiceDiscount.percent(10));
    expect(state().grandTotalMinorUnits, 360000);
    expect(state().invoiceDiscountMinorUnits, 40000);
    expect(state().pricedLines.map((l) => l.discountAmountMinorUnits), [30000, 10000]);

    cart.setInvoiceDiscount(const InvoiceDiscount.amount(100000));
    expect(state().grandTotalMinorUnits, 300000);

    cart.setInvoiceDiscount(null);
    expect(state().grandTotalMinorUnits, 400000);
  });

  test('a 100% invoice discount keeps cost + 5% per line when enabled', () {
    cart.setInvoiceDiscount(const InvoiceDiscount.percent(100, keepMargin: true));
    expect(state().grandTotalMinorUnits, 210000 + 84000);
    cart.setInvoiceDiscount(const InvoiceDiscount.percent(100));
    expect(state().grandTotalMinorUnits, 0);
  });

  test('invoice discount applies on top of line discounts', () {
    cart.setLineDiscount('tea', 100000);
    cart.setInvoiceDiscount(const InvoiceDiscount.percent(50));
    expect(state().grandTotalMinorUnits, 150000);
  });
  test('a line discount follows the quantity and never takes a line below zero', () {
    // 500 off three teas, then down to one: the discount can't be more than the line.
    cart.setQuantity('tea', 3);
    cart.setLineDiscount('tea', 500000);
    expect(state().lines.first.lineTotalMinorUnits, 400000);
    cart.setQuantity('tea', 1);
    expect(state().lines.first.discountAmountMinorUnits, 300000);
    expect(state().lines.first.lineTotalMinorUnits, 0);
    expect(state().grandTotalMinorUnits, 100000);

    // A percent stays a percent: 10% of two, then of three.
    cart.applyLineDiscount('sugar', isPercent: true, value: 10);
    cart.setQuantity('sugar', 2);
    expect(state().lines.last.discountAmountMinorUnits, 20000);
    cart.addProduct(_sugar);
    expect(state().lines.last.discountAmountMinorUnits, 30000);
    cart.setQuantity('sugar', 1);
    expect(state().lines.last.discountAmountMinorUnits, 10000);
    expect(state().lines.every((l) => l.lineTotalMinorUnits >= 0), isTrue);
  });

  test('a full discount keeping cost + 5% still does when the quantity changes', () {
    cart.applyLineDiscount('tea', isPercent: true, value: 100, keepMargin: true);
    expect(state().lines.first.lineTotalMinorUnits, 210000);
    cart.setQuantity('tea', 2);
    expect(state().lines.first.lineTotalMinorUnits, 420000);

    // An amount that ends up covering the whole line keeps the floor too.
    cart.setQuantity('tea', 3);
    cart.applyLineDiscount('tea', isPercent: false, value: 500000, keepMargin: true);
    cart.setQuantity('tea', 1);
    expect(state().lines.first.lineTotalMinorUnits, 210000);
  });

  test('stock lowering a line refits its discount', () {
    cart.setQuantity('tea', 4);
    cart.setLineDiscount('tea', 800000);
    cart.fitToStock({'tea': 1, 'sugar': 5});
    expect(state().lines.first.quantity, 1);
    expect(state().lines.first.lineTotalMinorUnits, 0);
  });
}
