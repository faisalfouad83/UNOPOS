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
import 'package:unopos/features/pos/domain/invoice_query.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/pos/domain/pos_repository.dart';
import 'package:unopos/features/pos/domain/process_sale_return_use_case.dart';
import 'package:unopos/features/reports/domain/sales_summary.dart';

void main() {
  test('normalizeSaleNumber accepts the digits alone', () {
    expect(normalizeSaleNumber('125'), 'S-000125');
    expect(normalizeSaleNumber(' s-000125 '), 'S-000125');
    expect(normalizeSaleNumber('S-7'), 'S-000007');
    expect(normalizeSaleNumber('#42'), 'S-000042');
  });

  test('a receipt number printed offline is looked up as it is', () {
    expect(normalizeSaleNumber('OFFLINE-3F2A1B'), 'OFFLINE-3F2A1B');
    expect(normalizeSaleNumber(' offline-3f2a1b '), 'OFFLINE-3F2A1B');
    expect(normalizeSaleNumber('H-AB12CD'), 'H-AB12CD');
    expect(const InvoiceQuery(storeId: 's', number: 'offline-3f2a1b').exactNumber, 'OFFLINE-3F2A1B');
    // Letters only after the prefix: still a number, not a customer's name.
    expect(looksLikeSaleNumber('OFFLINE-ABCDEF'), isTrue);
    expect(looksLikeSaleNumber('Ali'), isFalse);
    expect(const InvoiceQuery(storeId: 's', number: '12').exactNumber, 'S-000012');
  });

  test('returning an invoice restocks, nets it out of sales and profit, and stops double returns', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final accounting = DriftAccountingRepository(db);
    await accounting.seedDefaultChartOfAccounts('s');
    final pos = DriftPosRepository(db);
    final inventory = DriftInventoryRepository(db);
    final debts = DriftDebtsRepository(db);
    final posting = AccountingPostingService(accounting);
    final sell = OrchestratedCompleteSaleUseCase(
      posRepository: pos,
      inventoryRepository: inventory,
      accountingPostingService: posting,
      debtsRepository: debts,
    );
    final returns = OrchestratedProcessSaleReturnUseCase(
      posRepository: pos,
      inventoryRepository: inventory,
      accountingPostingService: posting,
      debtsRepository: debts,
    );

    await inventory.createProduct(const ProductRecord(
        id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 100000, costPriceMinorUnits: 60000));
    await inventory.recordStockMovement(
        storeId: 's',
        productId: 'tea',
        branchId: 'b',
        type: StockMovementType.purchaseIn,
        quantity: 10,
        referenceType: 'TEST',
        referenceId: 't',
        createdByUserId: 'c');

    final result = await sell.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.cash,
      lines: const [
        SaleLineInput(productId: 'tea', quantity: 3, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000)
      ],
      amountTenderedMinorUnits: 300000,
      changeGivenMinorUnits: 0,
    );
    expect((await inventory.getStockItem('tea', 'b'))!.quantityOnHand, 7);

    var sale = (await pos.findSaleByNumber('s', '1'))!;
    expect(sale.id, result.sale.id);

    // Return one of three.
    await returns.processReturn(
      originalSale: sale,
      processedByUserId: 'c',
      refundToCash: true,
      returnLines: [ReturnLineInput(saleLine: sale.lines.single, quantityReturned: 1)],
    );
    sale = (await pos.getSale(sale.id))!;
    expect(sale.status, SaleStatus.partiallyRefunded);
    expect(sale.lines.single.quantityReturned, 1);
    expect(sale.netTotalMinorUnits, 200000);
    expect((await inventory.getStockItem('tea', 'b'))!.quantityOnHand, 8);

    var summary = SalesSummary.of(await pos.watchCompletedSales('s').first, ReportPeriod.today);
    expect(summary.revenueMinorUnits, 200000);
    expect(summary.profitMinorUnits, 2 * (100000 - 60000));

    // More than what's left can't be returned.
    await expectLater(
      returns.processReturn(
        originalSale: sale,
        processedByUserId: 'c',
        refundToCash: true,
        returnLines: [ReturnLineInput(saleLine: sale.lines.single, quantityReturned: 3)],
      ),
      throwsA(anything),
    );

    // The rest goes back: the invoice is fully returned and drops out.
    await returns.processReturn(
      originalSale: sale,
      processedByUserId: 'c',
      refundToCash: true,
      returnLines: [ReturnLineInput(saleLine: sale.lines.single, quantityReturned: 2)],
    );
    sale = (await pos.getSale(sale.id))!;
    expect(sale.status, SaleStatus.refunded);
    expect(sale.canReturn, isFalse);
    expect((await inventory.getStockItem('tea', 'b'))!.quantityOnHand, 10);
    summary = SalesSummary.of(await pos.watchCompletedSales('s').first, ReportPeriod.today);
    expect(summary.salesCount, 0);
    expect(summary.revenueMinorUnits, 0);
    expect(summary.profitMinorUnits, 0);
  });
}
