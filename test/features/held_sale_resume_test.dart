import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/accounting/data/accounting_repository_drift.dart';
import 'package:unopos/features/accounting/domain/accounting_posting_service.dart';
import 'package:unopos/features/debts/data/debts_repository_drift.dart';
import 'package:unopos/features/inventory/data/inventory_repository_drift.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/data/pos_repository_drift.dart';
import 'package:unopos/features/pos/domain/complete_sale_use_case.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

const _tea = ProductRecord(
  id: 'tea',
  storeId: 's',
  sku: 'tea',
  name: 'Tea',
  sellPriceMinorUnits: 100000,
  wholesalePriceMinorUnits: 80000,
  costPriceMinorUnits: 60000,
  taxRateId: 'vat',
);
const _milk = ProductRecord(id: 'milk', storeId: 's', sku: 'milk', name: 'Milk', sellPriceMinorUnits: 50000);

void main() {
  late AppDatabase db;
  late DriftPosRepository pos;
  late DriftInventoryRepository inventory;
  late DriftDebtsRepository debts;
  late OrchestratedCompleteSaleUseCase sell;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final accounting = DriftAccountingRepository(db);
    await accounting.seedDefaultChartOfAccounts('s');
    pos = DriftPosRepository(db);
    inventory = DriftInventoryRepository(db);
    debts = DriftDebtsRepository(db);
    sell = OrchestratedCompleteSaleUseCase(
      posRepository: pos,
      inventoryRepository: inventory,
      accountingPostingService: AccountingPostingService(accounting),
      debtsRepository: debts,
    );
    await inventory.createProduct(_tea);
    await inventory.createProduct(_milk);
    for (final id in ['tea', 'milk']) {
      await inventory.recordStockMovement(
        storeId: 's',
        productId: id,
        branchId: 'b',
        type: StockMovementType.purchaseIn,
        quantity: 20,
        referenceType: 'TEST',
        referenceId: 't',
        createdByUserId: 'c',
      );
    }
  });
  tearDown(() => db.close());

  test('a resumed sale comes back exactly as held: price, discount, tax, wholesale', () {
    // Held at the wholesale price with a discount, before a price change.
    final held = SaleRecord(
      id: 'h',
      storeId: 's',
      branchId: 'b',
      saleNumber: 'S-000001',
      status: SaleStatus.held,
      cashierId: 'c',
      createdAt: DateTime(2026),
      lines: const [
        SaleLineRecord(
          id: 'l',
          saleId: 'h',
          productId: 'tea',
          quantity: 3,
          unitPriceMinorUnits: 80000,
          discountAmountMinorUnits: 10000,
          taxAmountMinorUnits: 23000,
          lineTotalMinorUnits: 253000,
        ),
      ],
    );
    final lines = heldSaleToCartLines(held, const [_tea], taxPercentById: const {'vat': 10});
    final line = lines.single;
    expect(line.quantity, 3);
    expect(line.unitPriceMinorUnits, 80000);
    expect(line.wholesale, isTrue);
    expect(line.discountAmountMinorUnits, 10000);
    expect(line.taxMinorUnits, 23000);
    expect(line.lineTotalMinorUnits, 253000);
  });

  test('suspending a resumed sale again updates it in place — no copy, same number', () async {
    final held = await sell.holdSale(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      lines: const [
        SaleLineInput(productId: 'tea', quantity: 1, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000),
      ],
    );
    final again = await sell.holdSale(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      replacing: held,
      lines: const [
        SaleLineInput(productId: 'tea', quantity: 2, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000),
        SaleLineInput(productId: 'milk', quantity: 1, unitPriceMinorUnits: 50000, costPriceSnapshotMinorUnits: 0),
      ],
    );
    final list = await pos.watchHeldSales('s', 'b').first;
    expect(list, hasLength(1));
    expect(again.saleNumber, held.saleNumber);
    expect(list.single.lines, hasLength(2));
    expect(list.single.grandTotalMinorUnits, 250000);
  });

  test('checking out a resumed sale charges the cart as it is now and closes the held sale', () async {
    final held = await sell.holdSale(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      lines: const [
        SaleLineInput(productId: 'tea', quantity: 1, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000),
      ],
    );
    // After resuming, the cashier added milk.
    final result = await sell.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.cash,
      resumingHeldSale: held,
      lines: const [
        SaleLineInput(productId: 'tea', quantity: 1, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000),
        SaleLineInput(productId: 'milk', quantity: 1, unitPriceMinorUnits: 50000, costPriceSnapshotMinorUnits: 0),
      ],
      amountTenderedMinorUnits: 150000,
      changeGivenMinorUnits: 0,
    );
    expect(result.sale.grandTotalMinorUnits, 150000);
    expect(await pos.watchHeldSales('s', 'b').first, isEmpty);
    expect((await inventory.getStockItem('milk', 'b'))!.quantityOnHand, 19);
    expect((await inventory.getStockItem('tea', 'b'))!.quantityOnHand, 19);

    // It can't be sold a second time.
    await expectLater(
      sell.checkout(
        storeId: 's',
        branchId: 'b',
        cashierId: 'c',
        paymentMethod: SalePaymentMethod.cash,
        resumingHeldSale: held,
        lines: const [
          SaleLineInput(productId: 'tea', quantity: 1, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000),
        ],
      ),
      throwsA(isA<HeldSaleClosedException>()),
    );
    expect((await inventory.getStockItem('tea', 'b'))!.quantityOnHand, 19);
  });

  test('pay later with money up front: paid part recorded, the rest owed', () async {
    final result = await sell.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.payLater,
      customerNameForPayLater: 'Ali',
      lines: const [
        SaleLineInput(productId: 'tea', quantity: 2, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000),
      ],
      extras: const {'paid_now_minor_units': 50000},
    );
    final debt = (await debts.findBySaleId(result.sale.id))!;
    expect(debt.originalAmountMinorUnits, 200000);
    expect(debt.amountPaidMinorUnits, 50000);
    expect(debt.balanceRemainingMinorUnits, 150000);
    expect(debt.status.name, 'partiallyPaid');
    expect(result.sale.amountTenderedMinorUnits, 50000);
  });
}
