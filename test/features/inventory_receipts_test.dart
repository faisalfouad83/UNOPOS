import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/inventory/data/inventory_repository_drift.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';

void main() {
  late AppDatabase db;
  late DriftInventoryRepository repo;
  late ProductRecord tea;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftInventoryRepository(db);
    tea = await repo.createProduct(
      const ProductRecord(id: '', storeId: 's1', sku: 'T', name: 'Tea', sellPriceMinorUnits: 300000),
    );
  });
  tearDown(() => db.close());

  Future<int> stock(String branchId) async => (await repo.getStockItem(tea.id, branchId))?.quantityOnHand ?? 0;

  test('a purchase order is received once', () async {
    final po = await repo.createPurchaseOrder(
      storeId: 's1',
      branchId: 'b1',
      supplierId: 'sup',
      paidImmediately: false,
      lines: [SupplierPurchaseLine(productId: tea.id, quantity: 6, unitCostMinorUnits: 200000)],
    );
    expect(await repo.receivePurchaseOrder(po.id, 'u1'), 1200000);
    await expectLater(
      repo.receivePurchaseOrder(po.id, 'u1'),
      throwsA(isA<ReceiptRefusedException>().having((e) => e.reason, 'reason', ReceiptRefusal.alreadyReceived)),
    );
    expect(await stock('b1'), 6);
  });

  test('a stock transfer is received once', () async {
    await repo.recordStockMovement(
      storeId: 's1',
      productId: tea.id,
      branchId: 'b1',
      type: StockMovementType.purchaseIn,
      quantity: 10,
      createdByUserId: 'u1',
    );
    final id = await repo.createStockTransfer(
      storeId: 's1',
      fromBranchId: 'b1',
      toBranchId: 'b2',
      requestedByUserId: 'u1',
      productQuantities: [MapEntry(tea.id, 4)],
    );
    await repo.receiveStockTransfer(id, 'u2');
    await expectLater(repo.receiveStockTransfer(id, 'u2'), throwsA(isA<ReceiptRefusedException>()));
    expect((await stock('b1'), await stock('b2')), (6, 4));
  });

  test('server refusals are recognised by their message', () {
    expect(
      ReceiptRefusedException.from(Exception('purchase order already received'))?.reason,
      ReceiptRefusal.alreadyReceived,
    );
    expect(ReceiptRefusedException.from(Exception('stock transfer was cancelled'))?.reason, ReceiptRefusal.cancelled);
    expect(ReceiptRefusedException.from(Exception('quantity must be positive')), isNull);
  });

  test('a store has one default tax rate', () async {
    await repo.createTaxRate('s1', 'VAT', 15, isDefault: true);
    await repo.createTaxRate('s1', 'Reduced', 5, isDefault: true);
    await repo.createTaxRate('s1', 'Zero', 0);
    final rates = await repo.watchTaxRates('s1').first;
    expect(rates.where((r) => r.isDefault).map((r) => r.name), ['Reduced']);
  });
}
