import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/accounting/data/accounting_repository_drift.dart';
import 'package:unopos/features/accounting/domain/accounting_models.dart';
import 'package:unopos/features/accounting/domain/accounting_posting_service.dart';

void main() {
  late AppDatabase db;
  late DriftAccountingRepository repository;
  late AccountingPostingService service;
  const storeId = 'store-1';
  const branchId = 'branch-1';
  const userId = 'user-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftAccountingRepository(db);
    service = AccountingPostingService(repository);
    await repository.seedDefaultChartOfAccounts(storeId);
  });

  tearDown(() async {
    await db.close();
  });

  group('postJournalEntry primitive', () {
    test('rejects an entry with fewer than two lines', () async {
      expect(
        () => repository.postJournalEntry(
          storeId: storeId,
          branchId: branchId,
          referenceType: JournalReferenceType.manual,
          createdByUserId: userId,
          lines: const [JournalLineInput(accountCode: '1000', debitMinorUnits: 100)],
        ),
        throwsArgumentError,
      );
    });

    test('rejects a line that is both debit and credit', () async {
      expect(
        () => repository.postJournalEntry(
          storeId: storeId,
          branchId: branchId,
          referenceType: JournalReferenceType.manual,
          createdByUserId: userId,
          lines: const [
            JournalLineInput(accountCode: '1000', debitMinorUnits: 100, creditMinorUnits: 100),
            JournalLineInput(accountCode: '4000', creditMinorUnits: 100),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects an unbalanced entry (debits != credits)', () async {
      expect(
        () => repository.postJournalEntry(
          storeId: storeId,
          branchId: branchId,
          referenceType: JournalReferenceType.manual,
          createdByUserId: userId,
          lines: const [
            JournalLineInput(accountCode: '1000', debitMinorUnits: 150),
            JournalLineInput(accountCode: '4000', creditMinorUnits: 100),
          ],
        ),
        throwsA(isA<UnbalancedJournalEntryException>()),
      );
    });

    test('rejects an unknown account code', () async {
      expect(
        () => repository.postJournalEntry(
          storeId: storeId,
          branchId: branchId,
          referenceType: JournalReferenceType.manual,
          createdByUserId: userId,
          lines: const [
            JournalLineInput(accountCode: '9999-DOES-NOT-EXIST', debitMinorUnits: 100),
            JournalLineInput(accountCode: '4000', creditMinorUnits: 100),
          ],
        ),
        throwsA(isA<UnknownAccountCodeException>()),
      );
    });

    test('accepts a balanced entry and it is retrievable', () async {
      final entry = await repository.postJournalEntry(
        storeId: storeId,
        branchId: branchId,
        referenceType: JournalReferenceType.manual,
        createdByUserId: userId,
        memo: 'Opening balance',
        lines: const [
          JournalLineInput(accountCode: '1000', debitMinorUnits: 50000),
          JournalLineInput(accountCode: '3000', creditMinorUnits: 50000),
        ],
      );

      expect(entry.lines, hasLength(2));
      final entries = await repository.watchJournalEntries(storeId).first;
      expect(entries.any((e) => e.id == entry.id), isTrue);
    });
  });

  group('business posting rules', () {
    test('a cash sale keeps the whole ledger balanced', () async {
      await service.postCashSale(
        storeId: storeId,
        branchId: branchId,
        saleId: 'sale-1',
        createdByUserId: userId,
        revenueMinorUnits: 10000,
        cogsMinorUnits: 6000,
        taxMinorUnits: 500,
      );

      final balances = await repository.trialBalance(storeId);

      expect(balances['1000'], 10500); // cash: revenue + tax
      expect(balances['4000'], 10000); // sales revenue
      expect(balances['2100'], 500); // VAT payable
      expect(balances['5000'], 6000); // COGS
      expect(balances['1200'], -6000); // inventory reduced (credit-side movement)
    });

    test('a pay-later sale posts to Accounts Receivable instead of Cash', () async {
      await service.postPayLaterSale(
        storeId: storeId,
        branchId: branchId,
        saleId: 'sale-2',
        createdByUserId: userId,
        revenueMinorUnits: 5000,
        cogsMinorUnits: 3000,
        taxMinorUnits: 0,
      );

      final balances = await repository.trialBalance(storeId);
      expect(balances['1100'], 5000); // Accounts Receivable
      expect(balances['1000'], isNull); // no cash movement
    });

    test('debt payment received reduces Accounts Receivable and increases Cash', () async {
      await service.postPayLaterSale(
        storeId: storeId,
        branchId: branchId,
        saleId: 'sale-3',
        createdByUserId: userId,
        revenueMinorUnits: 4000,
        cogsMinorUnits: 0,
        taxMinorUnits: 0,
      );
      await service.postDebtPaymentReceived(
        storeId: storeId,
        branchId: branchId,
        debtPaymentId: 'payment-1',
        createdByUserId: userId,
        amountMinorUnits: 4000,
        isCash: true,
      );

      final balances = await repository.trialBalance(storeId);
      expect(balances['1100'], 0); // fully collected
      expect(balances['1000'], 4000);
    });

    test('the whole trial balance always nets to zero debit/credit-normal difference', () async {
      await service.postCashSale(
        storeId: storeId,
        branchId: branchId,
        saleId: 'sale-4',
        createdByUserId: userId,
        revenueMinorUnits: 20000,
        cogsMinorUnits: 12000,
        taxMinorUnits: 1000,
      );
      await service.postSupplierPurchase(
        storeId: storeId,
        branchId: branchId,
        purchaseOrderId: 'po-1',
        createdByUserId: userId,
        amountMinorUnits: 8000,
        paidImmediately: false,
      );
      await service.postExpense(
        storeId: storeId,
        branchId: branchId,
        expenseAccountCode: '6000',
        createdByUserId: userId,
        amountMinorUnits: 1500,
        isCash: true,
      );

      final accounts = await repository.listAccounts(storeId);
      final balances = await repository.trialBalance(storeId);
      final typeByCode = {for (final a in accounts) a.code: a.type};

      var debitTotal = 0;
      var creditTotal = 0;
      for (final entry in balances.entries) {
        final type = typeByCode[entry.key];
        final isDebitNormal = type == 'asset' || type == 'expense' || type == 'cogs';
        if (isDebitNormal) {
          debitTotal += entry.value;
        } else {
          creditTotal += entry.value;
        }
      }

      expect(debitTotal, creditTotal);
    });
  });
}
