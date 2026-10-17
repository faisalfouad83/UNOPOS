import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/offline/connectivity.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/core/offline/sync_service.dart';
import 'package:unopos/features/accounting/data/accounting_repository_drift.dart';
import 'package:unopos/features/accounting/data/accounting_repository_supabase.dart';
import 'package:unopos/features/accounting/domain/account_totals.dart';
import 'package:unopos/features/accounting/domain/accounting_models.dart';
import 'package:unopos/features/accounting/domain/accounting_posting_service.dart';
import 'package:unopos/features/accounting/domain/financial_statements.dart';

Map<String, dynamic> _row(String code, String type, {int pd = 0, int pc = 0, int cd = 0, int cc = 0}) => {
      'account_code': code,
      'account_name': 'Account $code',
      'account_type': type,
      'period_debit': pd,
      'period_credit': pc,
      'closing_debit': cd,
      'closing_credit': cc,
    };

/// A month in which: the owner put in 1,000,000 cash earlier; this month
/// sold 300,000 (cost 180,000) — 200,000 cash, 100,000 on credit — gave a
/// 10,000 refund in cash (goods back in stock at cost 6,000), received
/// 40,000 of the credit, paid 50,000 rent in cash and bought 120,000 of
/// stock on credit. Earlier (before the month) stock of 500,000 was bought
/// for cash.
List<Map<String, dynamic>> _serverRows() => [
      // Cash: +1,000,000 owner, −500,000 stock (before); +200,000 sales,
      // −10,000 refund, +40,000 debt payment, −50,000 rent (this month).
      _row('1000', 'asset', pd: 240000, pc: 60000, cd: 1240000, cc: 560000),
      _row('1010', 'asset'),
      _row('1100', 'asset', pd: 100000, pc: 40000, cd: 100000, cc: 40000),
      // Stock: +500,000 (before); −180,000 sold, +6,000 returned, +120,000 bought.
      _row('1200', 'asset', pd: 126000, pc: 180000, cd: 626000, cc: 180000),
      _row('2000', 'liability', pc: 120000, cc: 120000),
      _row('3000', 'equity', cc: 1000000),
      _row('4000', 'revenue', pc: 300000, cc: 300000),
      _row('4100', 'revenue', pd: 10000, cd: 10000),
      _row('5000', 'cogs', pd: 180000, pc: 6000, cd: 180000, cc: 6000),
      _row('6000', 'expense', pd: 50000, cd: 50000),
    ];

List<Map<String, dynamic>> _movementRows() => [
      {'account_code': '1000', 'reference_type': 'SALE', 'debit': 200000, 'credit': 0},
      {'account_code': '1000', 'reference_type': 'RETURN', 'debit': 0, 'credit': 10000},
      {'account_code': '1000', 'reference_type': 'DEBT_PAYMENT', 'debit': 40000, 'credit': 0},
      {'account_code': '1000', 'reference_type': 'EXPENSE', 'debit': 0, 'credit': 50000},
    ];

AccountTotals _monthTotals() => AccountTotals.fromServerRows(
      from: DateTime(2026, 10, 1),
      to: DateTime(2026, 11, 1),
      accountRows: _serverRows(),
      movementRows: _movementRows(),
    );

void main() {
  group('statements from account totals', () {
    test('profit and loss', () {
      final pl = ProfitAndLoss.from(_monthTotals());
      expect(pl.grossSales, 300000);
      expect(pl.returns, 10000);
      expect(pl.discounts, 0);
      expect(pl.netSales, 290000);
      expect(pl.cogs, 174000);
      expect(pl.grossProfit, 116000);
      expect(pl.totalExpenses, 50000);
      expect(pl.netProfit, 66000);
    });

    test('balance sheet balances, with this period and earlier profit on the owner side', () {
      final bs = BalanceSheet.from(_monthTotals());
      // Cash 680,000 + receivables 60,000 + stock 446,000.
      expect(bs.totalAssets, 1186000);
      expect(bs.totalLiabilities, 120000);
      expect(bs.totalEquityAccounts, 1000000);
      expect(bs.periodProfit, 66000);
      expect(bs.earlierProfit, 0);
      expect(bs.balances, isTrue);
      expect(bs.difference, 0);
    });

    test('cash flow (direct) adds up to the cash accounts', () {
      final t = _monthTotals();
      final cf = CashFlow.from(t);
      expect(cf.opening, 500000);
      expect(cf.inflows, {'SALE': 200000, 'DEBT_PAYMENT': 40000});
      expect(cf.outflows, {'RETURN': 10000, 'EXPENSE': 50000});
      expect(cf.netChange, 180000);
      expect(cf.closing, 680000);
      expect(CashFlow.closingFromAccounts(t), cf.closing);
    });

    test('owner overview and trial balance', () {
      final t = _monthTotals();
      final o = OwnerOverview.from(t);
      expect(o.cashReceived, 240000);
      expect(o.cashPaidOut, 60000);
      expect(o.receivables, 60000);
      expect(o.payables, 120000);
      expect(o.cash, 680000);
      expect(o.bank, 0);
      final tb = TrialBalance.from(t);
      expect(tb.balances, isTrue);
      expect(tb.totalDebit, 680000 + 60000 + 446000 + 10000 + 174000 + 50000);
    });

    test('kept as JSON and read back unchanged', () {
      final t = _monthTotals();
      final back = AccountTotals.fromJson(jsonDecode(jsonEncode(t.toJson())) as Map<String, dynamic>,
          source: TotalsSource.offlineEstimate);
      expect(back.isEstimate, isTrue);
      expect(back.accounts.keys, t.accounts.keys);
      expect(BalanceSheet.from(back).totalAssets, BalanceSheet.from(t).totalAssets);
      expect(CashFlow.from(back).closing, 680000);
    });
  });

  group('offline estimate', () {
    JournalEntryRecord expense(DateTime at, int amount) => JournalEntryRecord(
          id: '@@op:x:id',
          storeId: 's',
          branchId: 'b',
          entryDate: at,
          referenceType: JournalReferenceType.expense,
          createdByUserId: 'u',
          createdAt: at,
          lines: [
            PostedJournalLine(
                id: '1', accountId: '', accountCode: '6000', debitMinorUnits: amount, creditMinorUnits: 0),
            PostedJournalLine(
                id: '2', accountId: '', accountCode: '1000', debitMinorUnits: 0, creditMinorUnits: amount),
          ],
        );

    test('entries not yet sent are laid over the server figures', () {
      final t = _monthTotals().withEntries([expense(DateTime(2026, 10, 20), 5000)]);
      expect(t.unsentEntries, 1);
      expect(ProfitAndLoss.from(t).netProfit, 61000);
      expect(OwnerOverview.from(t).cash, 675000);
      expect(CashFlow.from(t).outflows['EXPENSE'], 55000);
      expect(BalanceSheet.from(t).balances, isTrue);
    });

    test('an entry before the period moves balances but not the period', () {
      final t = _monthTotals().withEntries([expense(DateTime(2026, 9, 20), 5000)]);
      expect(ProfitAndLoss.from(t).netProfit, 66000);
      expect(OwnerOverview.from(t).cash, 675000);
      expect(BalanceSheet.from(t).earlierProfit, -5000);
      expect(BalanceSheet.from(t).balances, isTrue);
      expect(CashFlow.from(t).opening, 495000);
    });

    test('an entry after the period is left out', () {
      final t = _monthTotals().withEntries([expense(DateTime(2026, 11, 2), 5000)]);
      expect(OwnerOverview.from(t).cash, 680000);
      expect(t.unsentEntries, 0);
    });
  });

  group('periods', () {
    test('a week starts on Saturday by default', () {
      // 2026-10-17 is a Saturday; 2026-10-21 a Wednesday.
      final p = AccountingPeriod.of(PeriodKind.week, DateTime(2026, 10, 21, 15));
      expect(p.from, DateTime(2026, 10, 17));
      expect(p.to, DateTime(2026, 10, 24));
      final monday = AccountingPeriod.of(PeriodKind.week, DateTime(2026, 10, 21), firstWeekday: DateTime.monday);
      expect(monday.from, DateTime(2026, 10, 19));
    });

    test('today, month, year and custom', () {
      final now = DateTime(2026, 12, 31, 23, 59);
      expect(AccountingPeriod.of(PeriodKind.today, now).to, DateTime(2027, 1, 1));
      expect(AccountingPeriod.of(PeriodKind.month, now).from, DateTime(2026, 12, 1));
      expect(AccountingPeriod.of(PeriodKind.year, now).to, DateTime(2027));
      final custom = AccountingPeriod.of(PeriodKind.custom, now,
          customFrom: DateTime(2026, 3, 5, 10), customTo: DateTime(2026, 3, 7));
      expect(custom.from, DateTime(2026, 3, 5));
      expect(custom.to, DateTime(2026, 3, 8));
      expect(custom.lastDay, DateTime(2026, 3, 7));
      expect(AccountingPeriod.of(PeriodKind.month, now).balancesAt(now), now);
      expect(custom.balancesAt(now), DateTime(2026, 3, 8));
    });
  });

  group('local build', () {
    test('totals come straight from the journal, and the statements agree', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftAccountingRepository(db);
      final posting = AccountingPostingService(repo);
      await repo.seedDefaultChartOfAccounts('s');
      await posting.postCashSale(
        storeId: 's',
        branchId: 'b',
        saleId: 'sale',
        createdByUserId: 'u',
        revenueMinorUnits: 10000,
        cogsMinorUnits: 6000,
        taxMinorUnits: 0,
      );
      await posting.postPayLaterSale(
        storeId: 's',
        branchId: 'b',
        saleId: 'sale2',
        createdByUserId: 'u',
        revenueMinorUnits: 5000,
        cogsMinorUnits: 2000,
        taxMinorUnits: 0,
      );
      final now = DateTime.now();
      final t = await repo.accountTotals('s',
          from: DateTime(now.year, now.month, now.day), to: now.add(const Duration(minutes: 1)));
      expect(t.source, TotalsSource.local);
      final pl = ProfitAndLoss.from(t);
      expect(pl.netSales, 15000);
      expect(pl.grossProfit, 7000);
      expect(OwnerOverview.from(t).receivables, 5000);
      expect(OwnerOverview.from(t).cash, 10000);
      expect(BalanceSheet.from(t).balances, isTrue);
      expect(CashFlow.from(t).inflows, {'SALE': 10000});

      final entries =
          await repo.journalEntriesBetween('s', from: DateTime(now.year), to: now.add(const Duration(minutes: 1)));
      expect(entries, hasLength(2));
    });
  });

  group('shared backend', () {
    late HttpServer server;
    late SupabaseClient client;
    late SupabaseAccountingRepository repo;
    var requests = <String>[];

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      OfflineCache.resetMemory();
      OfflineCache.knownOffline = false;
      requests = [];
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        final path = req.uri.path.replaceFirst('/rest/v1/', '');
        requests.add(path);
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode(switch (path) {
          'rpc/account_totals' => _serverRows(),
          'rpc/account_movements_by_reference' => _movementRows(),
          _ => <Object>[],
        }));
        await req.response.close();
      });
      client = SupabaseClient('http://${server.address.host}:${server.port}', 'anon-key');
      repo = SupabaseAccountingRepository(client, OfflineWriter(client, Outbox(), ConnectivityMonitor(null)));
    });

    tearDown(() async {
      OfflineCache.knownOffline = false;
      await client.dispose();
      await server.close(force: true);
    });

    test('the server adds up; offline, the kept copy plus unsent entries is an estimate', () async {
      final from = DateTime(2026, 10, 1);
      final to = DateTime(2026, 11, 1);
      final live = await repo.accountTotals('s', from: from, to: to);
      expect(live.source, TotalsSource.live);
      expect(requests, containsAll(['rpc/account_totals', 'rpc/account_movements_by_reference']));
      expect(ProfitAndLoss.from(live).netProfit, 66000);

      // An expense entered on this device with no connection.
      final box = Outbox.shared;
      await box.load();
      const opId = 'test-expense-op';
      await box.add(OutboxOp(
        id: opId,
        kind: OutboxKind.rpc,
        createdAt: DateTime(2026, 10, 20),
        rpc: 'post_journal_entry',
        params: const {},
        table: 'journal_entries',
        row: {
          'id': Outbox.ref(opId),
          'store_id': 's',
          'branch_id': 'b',
          'entry_date': DateTime(2026, 10, 20).toUtc().toIso8601String(),
          'reference_type': 'EXPENSE',
          'memo': 'Rent',
          'created_by_user_id': 'u',
          'is_reversal': false,
          'created_at': DateTime(2026, 10, 20).toUtc().toIso8601String(),
          'lines': [
            {'id': 'l1', 'account_id': '', 'account_code': '6000', 'debit_minor_units': 5000, 'credit_minor_units': 0},
            {'id': 'l2', 'account_id': '', 'account_code': '1000', 'debit_minor_units': 0, 'credit_minor_units': 5000},
          ],
        },
      ));
      addTearDown(() => box.discard(opId));

      OfflineCache.knownOffline = true;
      requests.clear();
      final estimate = await repo.accountTotals('s', from: from, to: to);
      expect(requests, isEmpty);
      expect(estimate.isEstimate, isTrue);
      expect(estimate.unsentEntries, 1);
      expect(ProfitAndLoss.from(estimate).netProfit, 61000);
      expect(OwnerOverview.from(estimate).cash, 675000);
      expect(BalanceSheet.from(estimate).balances, isTrue);
    });
  });
}
