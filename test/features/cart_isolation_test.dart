import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/constants/roles.dart';
import 'package:unopos/features/auth/domain/auth_models.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

StoreRecord _store(String id) =>
    StoreRecord(id: id, storeLoginId: id, passwordHash: '', displayName: id, createdAt: DateTime(2026));

EmployeeRecord _cashier(String store, {String? branchId}) => EmployeeRecord(
      id: 'cashier-$store',
      storeId: store,
      branchId: branchId,
      name: 'Cashier',
      role: StoreRole.cashier,
      pinHash: '',
    );

const _teaA = ProductRecord(id: 'tea', storeId: 'A', sku: 'tea', name: 'Tea A', sellPriceMinorUnits: 100000);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test("store A's cart is gone after switching to store B", () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    container.listen(cartControllerProvider, (_, __) {});

    session.setStore(_store('A'));
    session.setCurrentBranch('A-main');
    await session.signInEmployeeDirectly(_cashier('A'));
    container.read(cartControllerProvider.notifier).addProduct(_teaA);
    expect(container.read(cartControllerProvider).lines, hasLength(1));

    // Employee signs out: the cart goes with them.
    session.signOutToTilePicker();
    expect(container.read(cartControllerProvider).isEmpty, isTrue);

    // Back in, fill the cart again, then move to another store.
    await session.signInEmployeeDirectly(_cashier('A'));
    container.read(cartControllerProvider.notifier).addProduct(_teaA);
    session.setStore(_store('B'));
    expect(container.read(sessionControllerProvider).employee, isNull);
    expect(container.read(sessionControllerProvider).currentBranchId, isNull);
    expect(container.read(cartControllerProvider).isEmpty, isTrue);
  });

  test('changing branch starts an empty cart', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    container.listen(cartControllerProvider, (_, __) {});
    session.setStore(_store('A'));
    session.setCurrentBranch('A-1');
    await session.signInEmployeeDirectly(_cashier('A'));
    container.read(cartControllerProvider.notifier).addProduct(_teaA);
    session.setCurrentBranch('A-2');
    expect(container.read(cartControllerProvider).isEmpty, isTrue);
  });

  test('an account tied to a branch cannot switch to another one', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    session.setStore(_store('A'));
    await session.signInEmployeeDirectly(_cashier('A', branchId: 'A-1'));
    session.setCurrentBranch('A-2');
    expect(container.read(sessionControllerProvider).currentBranchId, 'A-1');
  });

  test('a held sale from another store is never loaded into the cart', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    container.listen(cartControllerProvider, (_, __) {});
    session.setStore(_store('B'));
    session.setCurrentBranch('B-main');
    await session.signInEmployeeDirectly(_cashier('B'));

    final heldInA = SaleRecord(
      id: 'h1',
      storeId: 'A',
      branchId: 'A-main',
      saleNumber: 'S-000001',
      status: SaleStatus.held,
      cashierId: 'cashier-A',
      createdAt: DateTime(2026),
      lines: const [
        SaleLineRecord(
          id: 'l',
          saleId: 'h1',
          productId: 'tea',
          quantity: 2,
          unitPriceMinorUnits: 100000,
          lineTotalMinorUnits: 200000,
        ),
      ],
    );
    container.read(cartControllerProvider.notifier).loadHeldSale(heldInA, const [_teaA]);
    expect(container.read(cartControllerProvider).isEmpty, isTrue);
  });

  test('the chosen branch is remembered for the store on this device', () async {
    var container = ProviderContainer();
    container.read(sessionControllerProvider.notifier)
      ..setStore(_store('A'))
      ..setCurrentBranch('A-2');
    await Future<void>.delayed(Duration.zero);
    container.dispose();

    // "Restart": a new session for the same store gets A-2 back.
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(sessionControllerProvider.notifier).setStore(_store('A'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(sessionControllerProvider).currentBranchId, 'A-2');

    // Another store doesn't inherit it.
    container.read(sessionControllerProvider.notifier).setStore(_store('B'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(sessionControllerProvider).currentBranchId, isNull);
  });
}
