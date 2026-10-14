import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

void main() {
  const tea = ProductRecord(id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 1000);
  const sugar = ProductRecord(id: 'sugar', storeId: 's', sku: 'sugar', name: 'Sugar', sellPriceMinorUnits: 500);

  late ProviderContainer container;
  late CartController cart;
  int qty(String id) =>
      container.read(cartControllerProvider).lines.where((l) => l.product.id == id).firstOrNull?.quantity ?? 0;

  setUp(() {
    container = ProviderContainer();
    cart = container.read(cartControllerProvider.notifier);
  });
  tearDown(() => container.dispose());

  test('an item with no stock is not added', () {
    expect(cart.addProduct(tea, available: 0), StockCheck.outOfStock);
    expect(container.read(cartControllerProvider).isEmpty, isTrue);
    expect(cart.addProduct(tea, available: -2), StockCheck.outOfStock);
    expect(container.read(cartControllerProvider).isEmpty, isTrue);
  });

  test('adding stops at what is on hand', () {
    expect(cart.addProduct(tea, available: 2), StockCheck.ok);
    expect(cart.addProduct(tea, available: 2), StockCheck.ok);
    expect(cart.addProduct(tea, available: 2), StockCheck.capped);
    expect(qty('tea'), 2);
  });

  test('unknown stock (not loaded yet) does not block', () {
    cart.addProduct(tea);
    cart.addProduct(tea);
    expect(qty('tea'), 2);
  });

  test('a typed or stepped quantity is capped at stock', () {
    cart.addProduct(tea, available: 5);
    expect(cart.setQuantity('tea', 9, available: 5), StockCheck.capped);
    expect(qty('tea'), 5);
    expect(cart.setQuantity('tea', 3, available: 5), StockCheck.ok);
    expect(qty('tea'), 3);
    expect(cart.setQuantity('tea', 0), StockCheck.ok);
    expect(qty('tea'), 0);
  });

  test('fitToStock lowers or removes lines that no longer fit', () {
    cart.addProduct(tea);
    cart.setQuantity('tea', 4);
    cart.addProduct(sugar);
    cart.setQuantity('sugar', 2);
    cart.setLineDiscount('tea', 3500);

    final changed = cart.fitToStock({'tea': 2});
    expect(changed.map((l) => l.product.id), ['tea', 'sugar']);
    expect(qty('tea'), 2);
    expect(qty('sugar'), 0);
    // The discount can't be more than what is left of the line.
    expect(container.read(cartControllerProvider).lines.single.discountAmountMinorUnits, 2000);
    expect(cart.fitToStock({'tea': 2}), isEmpty);
  });
}
