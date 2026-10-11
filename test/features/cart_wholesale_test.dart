import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

void main() {
  const tea = ProductRecord(
    id: 'tea',
    storeId: 's',
    sku: 'tea',
    name: 'Tea',
    sellPriceMinorUnits: 300000,
    wholesalePriceMinorUnits: 250000,
  );
  const sugar = ProductRecord(id: 'sugar', storeId: 's', sku: 'sugar', name: 'Sugar', sellPriceMinorUnits: 150000);

  test('wholesale mode reprices lines that have a wholesale price', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartControllerProvider.notifier);

    cart.addProduct(tea);
    cart.addProduct(sugar);
    expect(container.read(cartControllerProvider).grandTotalMinorUnits, 450000);

    cart.setWholesale(true);
    // Tea drops to its wholesale price; Sugar has none and stays retail.
    expect(container.read(cartControllerProvider).grandTotalMinorUnits, 400000);

    cart.addProduct(tea); // new adds use the current mode
    expect(container.read(cartControllerProvider).grandTotalMinorUnits, 650000);

    cart.setWholesale(false);
    expect(container.read(cartControllerProvider).grandTotalMinorUnits, 750000);
  });

  test('switching to wholesale keeps a line discount within the new price', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartControllerProvider.notifier);
    cart.addProduct(tea);
    cart.setLineDiscount('tea', 280000);
    cart.setWholesale(true);
    expect(container.read(cartControllerProvider).lines.single.discountAmountMinorUnits, 250000);
  });

  test('clearing the cart goes back to retail', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartControllerProvider.notifier);
    cart.setWholesale(true);
    cart.clear();
    expect(container.read(cartControllerProvider).wholesale, isFalse);
  });
}
