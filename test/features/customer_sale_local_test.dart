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

void main() {
  test('a sale to a registered customer is linked to them, including its debt', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final accounting = DriftAccountingRepository(db);
    await accounting.seedDefaultChartOfAccounts('s');
    final debts = DriftDebtsRepository(db);
    final pos = DriftPosRepository(db);
    final inventory = DriftInventoryRepository(db);
    final useCase = OrchestratedCompleteSaleUseCase(
      posRepository: pos,
      inventoryRepository: inventory,
      accountingPostingService: AccountingPostingService(accounting),
      debtsRepository: debts,
    );
    await inventory.createProduct(
      const ProductRecord(id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 300000),
    );
    // Two customers with the same name: the chosen one must get the debt.
    await debts.createCustomer('s', 'Ali');
    final ali = await debts.createCustomer('s', 'Ali', phone: '07700000000');

    const line = SaleLineInput(productId: 'tea', quantity: 2, unitPriceMinorUnits: 300000, costPriceSnapshotMinorUnits: 0);
    await useCase.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.payLater,
      lines: const [line],
      customerNameForPayLater: 'Ali',
      extras: {'customer_id': ali.id},
    );
    await useCase.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.cash,
      lines: const [line],
      amountTenderedMinorUnits: 600000,
      changeGivenMinorUnits: 0,
      extras: {'customer_id': ali.id},
    );

    final open = await debts.watchOpenDebts('s').first;
    expect(open.single.customerId, ali.id);
    expect(await pos.salesTotalsByCustomer('s'), {ali.id: 1200000});
  });
}
