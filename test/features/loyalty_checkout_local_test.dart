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
import 'package:unopos/features/pos/domain/loyalty.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';

void main() {
  test('local checkout redeems and earns loyalty points with exact totals', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final accounting = DriftAccountingRepository(db);
    await accounting.seedDefaultChartOfAccounts('s');
    final inventory = DriftInventoryRepository(db);
    final debts = DriftDebtsRepository(db);
    final useCase = OrchestratedCompleteSaleUseCase(
      posRepository: DriftPosRepository(db),
      inventoryRepository: inventory,
      accountingPostingService: AccountingPostingService(accounting),
      debtsRepository: debts,
    );

    final tea = await inventory.createProduct(
      const ProductRecord(id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 300000, costPriceMinorUnits: 200000),
    );
    final customer = await debts.createCustomer('s', 'Zaid', phone: '07701234567');
    await debts.adjustLoyaltyPoints(customer.id, 50);

    // 2 x 3,000 = 6,000 IQD; redeem 20 points worth 50 IQD each = 1,000 off.
    const pointValue = 5000, spendPerPoint = 100000;
    final lines = Loyalty.applyDiscount([CartLine(product: tea, quantity: 2)], 20 * pointValue);
    final result = await useCase.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.cash,
      lines: lines.map((l) => l.toSaleLineInput()).toList(),
      amountTenderedMinorUnits: 500000,
      changeGivenMinorUnits: 0,
      extras: {
        'loyalty_customer_id': customer.id,
        'points_redeemed': 20,
        'loyalty_spend_per_point_minor': spendPerPoint,
      },
    );

    expect(result.sale.grandTotalMinorUnits, 500000);
    expect(result.loyaltyPointsEarned, 5);
    expect(result.loyaltyBalance, 50 - 20 + 5);
    final stored = (await debts.watchCustomers('s').first).single;
    expect(stored.loyaltyPoints, 35);
  });
}
