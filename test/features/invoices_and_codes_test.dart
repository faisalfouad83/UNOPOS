import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/accounting/data/accounting_repository_drift.dart';
import 'package:unopos/features/accounting/domain/accounting_posting_service.dart';
import 'package:unopos/features/debts/data/debts_repository_drift.dart';
import 'package:unopos/features/inventory/data/inventory_repository_drift.dart';
import 'package:unopos/features/inventory/domain/barcode_generator.dart';
import 'package:unopos/features/inventory/domain/inventory_models.dart';
import 'package:unopos/features/inventory/domain/product_code.dart';
import 'package:unopos/features/pos/data/pos_repository_drift.dart';
import 'package:unopos/features/pos/domain/complete_sale_use_case.dart';
import 'package:unopos/features/pos/domain/invoice_query.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/printing/data/receipt_pdf.dart';
import 'package:unopos/features/printing/domain/receipt_models.dart';

const _tea = ProductRecord(
    id: 'tea', storeId: 's', sku: 'tea', name: 'Tea', sellPriceMinorUnits: 100000, costPriceMinorUnits: 60000);

void main() {
  group('product codes', () {
    test('real barcodes with a correct check digit are accepted', () {
      expect(validateProductCode('4006381333931'), isNull); // EAN-13
      expect(validateProductCode('96385074'), isNull); // EAN-8
      expect(validateProductCode('036000291452'), isNull); // UPC-A
      expect(validateProductCode(BarcodeGenerator.newInStoreEan13()), isNull);
      expect(validateProductCode('TEA-500g'), isNull);
    });

    test('typos and junk are rejected', () {
      expect(validateProductCode('4006381333932'), ProductCodeError.badCheckDigit);
      expect(validateProductCode('tea bag'), ProductCodeError.invalidCharacters);
      expect(validateProductCode('x' * 65), ProductCodeError.tooLong);
    });
  });

  group('invoice list', () {
    late AppDatabase db;
    late DriftPosRepository pos;
    late OrchestratedCompleteSaleUseCase sell;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      final accounting = DriftAccountingRepository(db);
      await accounting.seedDefaultChartOfAccounts('s');
      pos = DriftPosRepository(db);
      final inventory = DriftInventoryRepository(db);
      sell = OrchestratedCompleteSaleUseCase(
        posRepository: pos,
        inventoryRepository: inventory,
        accountingPostingService: AccountingPostingService(accounting),
        debtsRepository: DriftDebtsRepository(db),
      );
      await inventory.createProduct(_tea);
    });
    tearDown(() => db.close());

    Future<CheckoutResult> sale(String branch, String cashier, SalePaymentMethod method, int qty, {int paidNow = 0}) =>
        sell.checkout(
          storeId: 's',
          branchId: branch,
          cashierId: cashier,
          paymentMethod: method,
          customerNameForPayLater: method == SalePaymentMethod.payLater ? 'Ali' : null,
          lines: [
            SaleLineInput(
                productId: 'tea', quantity: qty, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000)
          ],
          amountTenderedMinorUnits: method == SalePaymentMethod.cash ? qty * 100000 : null,
          changeGivenMinorUnits: method == SalePaymentMethod.cash ? 0 : null,
          extras: {if (paidNow > 0) 'paid_now_minor_units': paidNow},
        );

    test('a completed sale shows up with its real totals, paid and remaining', () async {
      final cash = await sale('b1', 'c1', SalePaymentMethod.cash, 2);
      await sale('b1', 'c2', SalePaymentMethod.payLater, 3, paidNow: 100000);
      await sale('b2', 'c1', SalePaymentMethod.card, 1);

      final all = await pos.listInvoices(const InvoiceQuery(storeId: 's'));
      expect(all, hasLength(3));

      final byNumber = await pos.listInvoices(InvoiceQuery(storeId: 's', number: cash.sale.saleNumber.substring(2)));
      expect(byNumber.single.sale.id, cash.sale.id);
      expect(byNumber.single.totalMinorUnits, 200000);
      expect(byNumber.single.paidMinorUnits, 200000);
      expect(byNumber.single.status, InvoiceStatus.completed);

      final credit =
          (await pos.listInvoices(const InvoiceQuery(storeId: 's', paymentMethod: SalePaymentMethod.payLater))).single;
      expect(credit.paidMinorUnits, 100000);
      expect(credit.remainingMinorUnits, 200000);
      expect(credit.status, InvoiceStatus.partiallyPaid);
    });

    test('filters by branch, cashier and status; sorts; pages', () async {
      await sale('b1', 'c1', SalePaymentMethod.cash, 1);
      await sale('b1', 'c2', SalePaymentMethod.cash, 5);
      await sale('b2', 'c1', SalePaymentMethod.payLater, 2);

      expect(await pos.listInvoices(const InvoiceQuery(storeId: 's', branchId: 'b1')), hasLength(2));
      expect(await pos.listInvoices(const InvoiceQuery(storeId: 's', cashierId: 'c1')), hasLength(2));
      expect(await pos.listInvoices(const InvoiceQuery(storeId: 's', status: InvoiceStatus.unpaid)), hasLength(1));
      expect(await pos.listInvoices(const InvoiceQuery(storeId: 'other')), isEmpty);

      final byAmount = await pos.listInvoices(const InvoiceQuery(storeId: 's', sort: InvoiceSort.amountDesc));
      expect(byAmount.first.totalMinorUnits, 500000);

      final page1 = await pos.listInvoices(const InvoiceQuery(storeId: 's', limit: 2));
      final page2 = await pos.listInvoices(const InvoiceQuery(storeId: 's', limit: 2, offset: 2));
      expect(page1, hasLength(2));
      expect(page2, hasLength(1));
      expect({...page1.map((r) => r.sale.id), ...page2.map((r) => r.sale.id)}, hasLength(3));
    });

    test('held sales are not invoices', () async {
      await sell.holdSale(
        storeId: 's',
        branchId: 'b1',
        cashierId: 'c1',
        lines: const [
          SaleLineInput(productId: 'tea', quantity: 1, unitPriceMinorUnits: 100000, costPriceSnapshotMinorUnits: 60000)
        ],
      );
      expect(await pos.listInvoices(const InvoiceQuery(storeId: 's')), isEmpty);
    });
  });

  group('receipt templates', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final doc = ReceiptDocument(
      storeName: 'متجر الاختبار',
      branchName: 'Main',
      saleNumber: 'S-000001',
      dateTime: DateTime(2026, 10, 13, 12),
      cashierName: 'Ali',
      lines: [
        for (var i = 0; i < 40; i++)
          ReceiptLine(name: 'منتج $i', quantity: 1, unitPriceMinorUnits: 100000, lineTotalMinorUnits: 100000),
      ],
      subtotalMinorUnits: 4000000,
      discountTotalMinorUnits: 0,
      taxTotalMinorUnits: 0,
      grandTotalMinorUnits: 4000000,
      paymentMethodLabel: 'Cash',
      currencySymbol: 'IQD',
    );

    for (final paper in ReceiptPaper.values) {
      for (final style in ReceiptStyle.values) {
        test('${paper.name} / ${style.name} renders', () async {
          final layout = ReceiptLayout(paper: paper, style: style, paperWidthMm: 80);
          final bytes = await ReceiptPdf.build(
            ReceiptDocument(
              storeName: doc.storeName,
              branchName: doc.branchName,
              saleNumber: doc.saleNumber,
              dateTime: doc.dateTime,
              cashierName: doc.cashierName,
              lines: doc.lines,
              subtotalMinorUnits: doc.subtotalMinorUnits,
              discountTotalMinorUnits: 0,
              taxTotalMinorUnits: 0,
              grandTotalMinorUnits: doc.grandTotalMinorUnits,
              paymentMethodLabel: doc.paymentMethodLabel,
              currencySymbol: doc.currencySymbol,
              layout: layout,
            ),
          );
          expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        });
      }
    }

    test('a roll is exactly as long as the receipt; sheets are A4/A5', () {
      expect(ReceiptPdf.pageFormat(const ReceiptLayout()).height, double.infinity);
      expect(ReceiptPdf.pageFormat(const ReceiptLayout(paper: ReceiptPaper.a4)).width, PdfPageFormat.a4.width);
      expect(ReceiptPdf.pageFormat(const ReceiptLayout(paper: ReceiptPaper.a5)).width, PdfPageFormat.a5.width);
    });
  });
}
