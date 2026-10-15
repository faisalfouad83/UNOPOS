import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/features/accounting/data/accounting_repository_drift.dart';
import 'package:unopos/features/accounting/domain/accounting_posting_service.dart';
import 'package:unopos/features/auth/domain/auth_models.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/debts/data/debts_repository_drift.dart';
import 'package:unopos/features/inventory/data/inventory_repository_drift.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/pos/data/pos_repository_drift.dart';
import 'package:unopos/features/pos/domain/complete_sale_use_case.dart';
import 'package:unopos/features/pos/domain/invoice_query.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/pos/domain/process_sale_return_use_case.dart';
import 'package:unopos/features/pos/presentation/cart_controller.dart';
import 'package:unopos/features/pos/presentation/pos_screen.dart';

const _tea = ProductRecord(id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 100000);
const _teaLine =
    SaleLineInput(productId: 'tea', quantity: 1, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 0);

SaleLineRecord _line(String id, int quantity, {int returned = 0}) => SaleLineRecord(
      id: id,
      saleId: 'sale',
      productId: 'tea',
      quantity: quantity,
      unitPriceMinorUnits: 100000,
      lineTotalMinorUnits: 100000 * quantity,
      quantityReturned: returned,
    );

SaleRecord _sale(List<SaleLineRecord> lines, {SalePaymentMethod method = SalePaymentMethod.cash, int? tendered}) =>
    SaleRecord(
      id: 'sale',
      storeId: 's',
      branchId: 'b',
      saleNumber: 'S-000001',
      status: SaleStatus.completed,
      grandTotalMinorUnits: lines.fold(0, (s, l) => s + l.lineTotalMinorUnits),
      paymentMethod: method,
      amountTenderedMinorUnits: tendered,
      cashierId: 'c',
      createdAt: DateTime(2026),
      lines: lines,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('held sales', () {
    late ProviderContainer container;
    late CartController cart;
    final held = SaleRecord(
      id: 'h1',
      storeId: 's',
      branchId: 'b',
      saleNumber: 'S-000009',
      status: SaleStatus.held,
      cashierId: 'c',
      grandTotalMinorUnits: 100000,
      createdAt: DateTime(2026),
      lines: [_line('l1', 1)],
    );

    setUp(() {
      container = ProviderContainer();
      container.listen(cartControllerProvider, (_, __) {});
      container.read(sessionControllerProvider.notifier)
        ..setStore(
            StoreRecord(id: 's', storeLoginId: 's', passwordHash: '', displayName: 's', createdAt: DateTime(2026)))
        ..setCurrentBranch('b');
      cart = container.read(cartControllerProvider.notifier);
    });
    tearDown(() => container.dispose());

    test('a cart emptied line by line no longer closes the held sale it came from', () {
      cart.loadHeldSale(held, const [_tea]);
      expect(container.read(cartControllerProvider).resumingHeldSale?.id, 'h1');
      // The cashier takes the item out and rings up another customer.
      cart.setQuantity('tea', 0);
      expect(container.read(cartControllerProvider).resumingHeldSale, isNull);
      cart.addProduct(_tea);
      expect(container.read(cartControllerProvider).resumingHeldSale, isNull);
    });

    test('a held sale closed elsewhere is let go, keeping what is in the cart', () {
      cart.loadHeldSale(held, const [_tea]);
      cart.detachHeldSale('other');
      expect(container.read(cartControllerProvider).resumingHeldSale?.id, 'h1');
      cart.detachHeldSale('h1');
      expect(container.read(cartControllerProvider).resumingHeldSale, isNull);
      expect(container.read(cartControllerProvider).lines, hasLength(1));
    });

    test('a held sale is only resumed once all its lines are there', () {
      expect(heldSaleIsComplete(held), isTrue);
      expect(
          heldSaleIsComplete(SaleRecord(
            id: 'h2',
            storeId: 's',
            branchId: 'b',
            saleNumber: 'S-000010',
            status: SaleStatus.held,
            cashierId: 'c',
            grandTotalMinorUnits: 300000,
            createdAt: DateTime(2026),
            lines: [_line('l1', 1)],
          )),
          isFalse);
      expect(
          heldSaleIsComplete(SaleRecord(
            id: 'h3',
            storeId: 's',
            branchId: 'b',
            saleNumber: 'S-000011',
            status: SaleStatus.held,
            cashierId: 'c',
            createdAt: DateTime(2026),
          )),
          isFalse);
    });
  });

  test('holding again a held sale sold elsewhere says so', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final accounting = DriftAccountingRepository(db);
    await accounting.seedDefaultChartOfAccounts('s');
    final pos = DriftPosRepository(db);
    final inventory = DriftInventoryRepository(db);
    await inventory.createProduct(_tea);
    final sell = OrchestratedCompleteSaleUseCase(
      posRepository: pos,
      inventoryRepository: inventory,
      accountingPostingService: AccountingPostingService(accounting),
      debtsRepository: DriftDebtsRepository(db),
    );
    final held = await sell.holdSale(storeId: 's', branchId: 'b', cashierId: 'c', lines: const [_teaLine]);
    await sell.checkout(
      storeId: 's',
      branchId: 'b',
      cashierId: 'c',
      paymentMethod: SalePaymentMethod.card,
      resumingHeldSale: held,
      lines: const [_teaLine],
    );
    await expectLater(
      sell.holdSale(storeId: 's', branchId: 'b', cashierId: 'c', lines: const [_teaLine], replacing: held),
      throwsA(isA<HeldSaleClosedException>()),
    );
  });

  test('an offline sale refused because its held sale was closed elsewhere is sent again on its own', () async {
    final outbox = Outbox();
    await outbox.add(
      OutboxOp(
        id: 'sale-1',
        kind: OutboxKind.checkout,
        createdAt: DateTime(2026),
        table: 'sales',
        row: {'id': 'sale-1', 'status': 'completed', '_releases': 'h1'},
        params: {
          'p_client_sale_id': 'sale-1',
          'p_extras': {'release_held_sale_id': 'h1', 'customer_id': 'c1'},
        },
      ),
    );
    await outbox.add(OutboxOp(id: 'other', kind: OutboxKind.rpc, createdAt: DateTime(2026), rpc: 'start_break'));
    for (final op in outbox.ops) {
      await outbox.replace(op.copyWith(failed: true, lastError: op.id == 'other' ? 'no' : 'held sale already closed'));
    }

    expect(await resendRefusedHeldSaleCheckouts(outbox), 1);
    final sale = outbox.pending.single;
    expect(sale.id, 'sale-1');
    expect(sale.params!['p_extras'], {'customer_id': 'c1'});
    expect(sale.row!.containsKey('_releases'), isFalse);
    expect(outbox.failed.single.id, 'other');
  });

  group('returns', () {
    test('a return waiting to be sent shows on the sale, so it can\'t be returned twice', () async {
      final sale = _sale([_line('a', 2), _line('b', 1)]);
      final outbox = Outbox();
      await outbox.add(
        OutboxOp(
          id: 'r1',
          kind: OutboxKind.rpc,
          createdAt: DateTime(2026),
          rpc: 'process_sale_return',
          increments: returnIncrements(sale, [ReturnLineInput(saleLine: sale.lines.first, quantityReturned: 2)]),
        ),
      );
      final lines = outbox.applyTo('sale_lines', [
        {'id': 'a', 'sale_id': 'sale', 'quantity_returned': 0},
        {'id': 'b', 'sale_id': 'sale', 'quantity_returned': 0},
      ]);
      expect(lines.map((l) => l['quantity_returned']), [2, 0]);
      expect(
          outbox.applyTo('sales', [
            {'id': 'sale', 'status': 'completed'},
          ]).single['status'],
          'partiallyRefunded');

      // The rest of it: the sale is fully returned.
      final rest = returnIncrements(
        _sale([_line('a', 2, returned: 2), _line('b', 1)]),
        [ReturnLineInput(saleLine: _line('b', 1), quantityReturned: 1)],
      );
      expect(rest.last['set'], {'status': 'refunded'});
    });

    test('more than what is left (returns waiting included) is refused', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final accounting = DriftAccountingRepository(db);
      final returns = OrchestratedProcessSaleReturnUseCase(
        posRepository: DriftPosRepository(db),
        inventoryRepository: DriftInventoryRepository(db),
        accountingPostingService: AccountingPostingService(accounting),
        debtsRepository: DriftDebtsRepository(db),
      );
      final line = _line('a', 2, returned: 1);
      await expectLater(
        returns.processReturn(
          originalSale: _sale([line]),
          processedByUserId: 'c',
          refundToCash: true,
          returnLines: [ReturnLineInput(saleLine: line, quantityReturned: 2)],
        ),
        throwsA(isA<ReturnExceedsRemainingException>()),
      );
    });

    test('a sale paid later tells what came off the balance and what goes back', () {
      final preview = returnPreview(
        _sale([_line('a', 2)], method: SalePaymentMethod.payLater),
        [ReturnLineInput(saleLine: _line('a', 2), quantityReturned: 1)],
        processedByUserId: 'c',
        refundToCash: true,
        handedBackMinorUnits: 40000,
      );
      expect(preview['refund_minor_units'], 100000);
      expect(preview['refund_cash_minor_units'], 40000);
      expect(preview['original_sale_id'], 'sale');
    });
  });

  test('a pay-later invoice whose debt is not known yet shows what is still owed', () {
    final unpaid = InvoiceRecord(sale: _sale([_line('a', 2)], method: SalePaymentMethod.payLater));
    expect(unpaid.status, InvoiceStatus.unpaid);
    expect(unpaid.remainingMinorUnits, 200000);

    final part = InvoiceRecord(sale: _sale([_line('a', 2)], method: SalePaymentMethod.payLater, tendered: 50000));
    expect(part.status, InvoiceStatus.partiallyPaid);
    expect(part.remainingMinorUnits, 150000);
    expect(part.paidMinorUnits, 50000);

    final settled = InvoiceRecord(sale: _sale([_line('a', 2)], method: SalePaymentMethod.payLater), debtSettled: true);
    expect(settled.status, InvoiceStatus.paid);
    expect(settled.remainingMinorUnits, 0);
  });
}
