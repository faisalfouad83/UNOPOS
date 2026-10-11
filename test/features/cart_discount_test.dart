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
}
