import '../../../core/constants/default_chart_of_accounts.dart';
import 'account_totals.dart';

/// The periods the accounting screens can show.
enum PeriodKind { today, week, month, year, custom }

/// A stretch of time: [from] inclusive, [to] exclusive, in local time.
class AccountingPeriod {
  const AccountingPeriod(this.kind, this.from, this.to);

  final PeriodKind kind;
  final DateTime from;
  final DateTime to;

  /// The period of [kind] containing [now]. Weeks start on
  /// [firstWeekday] (1 = Monday … 7 = Sunday; 6 = Saturday, as in Iraq).
  /// [customFrom]/[customTo] are whole days, both included.
  factory AccountingPeriod.of(
    PeriodKind kind,
    DateTime now, {
    int firstWeekday = DateTime.saturday,
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    switch (kind) {
      case PeriodKind.today:
        return AccountingPeriod(kind, today, DateTime(today.year, today.month, today.day + 1));
      case PeriodKind.week:
        final back = (today.weekday - firstWeekday) % 7;
        final start = DateTime(today.year, today.month, today.day - back);
        return AccountingPeriod(kind, start, DateTime(start.year, start.month, start.day + 7));
      case PeriodKind.month:
        return AccountingPeriod(kind, DateTime(today.year, today.month), DateTime(today.year, today.month + 1));
      case PeriodKind.year:
        return AccountingPeriod(kind, DateTime(today.year), DateTime(today.year + 1));
      case PeriodKind.custom:
        final a = customFrom ?? today;
        final b = customTo ?? a;
        final start = DateTime(a.year, a.month, a.day);
        final end = DateTime(b.year, b.month, b.day + 1);
        return AccountingPeriod(kind, start, end.isAfter(start) ? end : DateTime(a.year, a.month, a.day + 1));
    }
  }

  /// Balances are shown as at the end of the period, or now if that is
  /// still to come.
  DateTime balancesAt(DateTime now) => to.isAfter(now) ? now : to;

  /// The last day included (for showing "1 Jan – 31 Jan").
  DateTime get lastDay => to.subtract(const Duration(days: 1));

  @override
  bool operator ==(Object other) =>
      other is AccountingPeriod && other.kind == kind && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(kind, from, to);
}

/// One line of a statement: an account and its amount.
class StatementLine {
  const StatementLine(this.code, this.name, this.amount);
  final String code;
  final String name;
  final int amount;
}

/// Profit and loss (income statement) for the period: what was earned,
/// what the goods sold cost, what running the shop cost, and what is left.
class ProfitAndLoss {
  const ProfitAndLoss({
    required this.grossSales,
    required this.returns,
    required this.discounts,
    required this.otherRevenue,
    required this.cogs,
    required this.expenses,
  });

  /// Sales before returns and discounts (account 4000).
  final int grossSales;

  /// Money given back for returned goods (4100), as a positive amount.
  final int returns;

  /// Discounts given (4200), as a positive amount.
  final int discounts;

  /// Any other income accounts the store added.
  final int otherRevenue;

  /// What the goods sold cost to buy (5000 and other cost accounts).
  final int cogs;

  /// Running costs (6xxx), by account.
  final List<StatementLine> expenses;

  int get netSales => grossSales - returns - discounts + otherRevenue;
  int get grossProfit => netSales - cogs;
  int get totalExpenses => expenses.fold(0, (s, l) => s + l.amount);
  int get netProfit => grossProfit - totalExpenses;

  factory ProfitAndLoss.from(AccountTotals t) {
    int contra(String code) => -t.account(code).periodChange;
    final revenueTotal = t.ofType(AccountType.revenue).fold<int>(0, (s, a) => s + a.periodChange);
    final gross = t.account(SystemAccountCodes.salesRevenue).periodChange;
    final returns = contra(SystemAccountCodes.salesReturns);
    final discounts = contra(SystemAccountCodes.discountsGiven);
    return ProfitAndLoss(
      grossSales: gross,
      returns: returns,
      discounts: discounts,
      otherRevenue: revenueTotal - (gross - returns - discounts),
      cogs: t.ofType(AccountType.cogs).fold(0, (s, a) => s + a.periodChange),
      expenses: [
        for (final a in t.ofType(AccountType.expense))
          if (a.periodChange != 0) StatementLine(a.code, a.name, a.periodChange),
      ],
    );
  }
}

/// What the store has, owes and owns at the end of the period. Profit not
/// yet moved into equity is shown on the owner's side, so both sides match.
class BalanceSheet {
  const BalanceSheet({
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.earlierProfit,
    required this.periodProfit,
  });

  final List<StatementLine> assets;
  final List<StatementLine> liabilities;
  final List<StatementLine> equity;

  /// Profit from before the period, not yet moved into equity.
  final int earlierProfit;

  /// This period's profit.
  final int periodProfit;

  int get totalAssets => assets.fold(0, (s, l) => s + l.amount);
  int get totalLiabilities => liabilities.fold(0, (s, l) => s + l.amount);
  int get totalEquityAccounts => equity.fold(0, (s, l) => s + l.amount);
  int get totalEquity => totalEquityAccounts + earlierProfit + periodProfit;
  int get totalLiabilitiesAndEquity => totalLiabilities + totalEquity;

  /// Zero when every entry balanced (as the journal guarantees).
  int get difference => totalAssets - totalLiabilitiesAndEquity;
  bool get balances => difference == 0;

  factory BalanceSheet.from(AccountTotals t) {
    List<StatementLine> lines(AccountType type) => [
          for (final a in t.ofType(type))
            if (a.closingBalance != 0 || a.periodChange != 0) StatementLine(a.code, a.name, a.closingBalance),
        ];
    int profit(int Function(AccountTotal a) pick) {
      var p = 0;
      for (final a in t.accounts.values) {
        if (a.type == AccountType.revenue.name) p += pick(a);
        if (a.type == AccountType.cogs.name || a.type == AccountType.expense.name) p -= pick(a);
      }
      return p;
    }

    final toDate = profit((a) => a.closingBalance);
    final period = profit((a) => a.periodChange);
    return BalanceSheet(
      assets: lines(AccountType.asset),
      liabilities: lines(AccountType.liability),
      equity: lines(AccountType.equity),
      earlierProfit: toDate - period,
      periodProfit: period,
    );
  }
}

/// Cash flow, direct method: money into and out of cash and bank in the
/// period, grouped by what caused it.
class CashFlow {
  const CashFlow({required this.opening, required this.inflows, required this.outflows});

  /// Cash and bank together when the period started.
  final int opening;

  /// Money in, by cause ('SALE', 'DEBT_PAYMENT', ...).
  final Map<String, int> inflows;

  /// Money out, by cause, as positive amounts.
  final Map<String, int> outflows;

  int get totalIn => inflows.values.fold(0, (s, v) => s + v);
  int get totalOut => outflows.values.fold(0, (s, v) => s + v);
  int get netChange => totalIn - totalOut;
  int get closing => opening + netChange;

  factory CashFlow.from(AccountTotals t) {
    final inflows = <String, int>{};
    final outflows = <String, int>{};
    for (final m in t.movements) {
      if (!kCashAccountCodes.contains(m.accountCode)) continue;
      if (m.debit != 0) inflows[m.referenceType] = (inflows[m.referenceType] ?? 0) + m.debit;
      if (m.credit != 0) outflows[m.referenceType] = (outflows[m.referenceType] ?? 0) + m.credit;
    }
    return CashFlow(
      opening: kCashAccountCodes.fold(0, (s, c) => s + t.account(c).openingBalance),
      inflows: inflows,
      outflows: outflows,
    );
  }

  /// Closing cash worked out from the accounts themselves; equals
  /// [closing] when the movements are complete.
  static int closingFromAccounts(AccountTotals t) =>
      kCashAccountCodes.fold(0, (s, c) => s + t.account(c).closingBalance);
}

/// The figures an owner looks at first.
class OwnerOverview {
  const OwnerOverview({
    required this.profitAndLoss,
    required this.cashReceived,
    required this.cashPaidOut,
    required this.receivables,
    required this.payables,
    required this.cash,
    required this.bank,
  });

  final ProfitAndLoss profitAndLoss;

  /// Money into the cash drawer (account 1000) in the period.
  final int cashReceived;

  /// Money out of the cash drawer in the period.
  final int cashPaidOut;

  /// Customers owe the store (1100), at the end of the period.
  final int receivables;

  /// The store owes suppliers (2000).
  final int payables;

  /// Cash on hand (1000).
  final int cash;

  /// Bank (1010).
  final int bank;

  factory OwnerOverview.from(AccountTotals t) {
    final cash = t.account(SystemAccountCodes.cash);
    return OwnerOverview(
      profitAndLoss: ProfitAndLoss.from(t),
      cashReceived: cash.periodDebit,
      cashPaidOut: cash.periodCredit,
      receivables: t.account(SystemAccountCodes.accountsReceivable).closingBalance,
      payables: t.account(SystemAccountCodes.accountsPayable).closingBalance,
      cash: cash.closingBalance,
      bank: t.account(SystemAccountCodes.bank).closingBalance,
    );
  }
}

/// Trial balance: every account's closing balance in a debit or a credit
/// column; the two columns are equal when the books balance.
class TrialBalance {
  const TrialBalance(this.rows);

  /// (account, debit, credit) per account with a balance.
  final List<({AccountTotal account, int debit, int credit})> rows;

  int get totalDebit => rows.fold(0, (s, r) => s + r.debit);
  int get totalCredit => rows.fold(0, (s, r) => s + r.credit);
  bool get balances => totalDebit == totalCredit;

  factory TrialBalance.from(AccountTotals t) {
    final rows = <({AccountTotal account, int debit, int credit})>[];
    for (final a in t.accounts.values) {
      final net = a.closingDebit - a.closingCredit;
      if (net == 0) continue;
      rows.add((account: a, debit: net > 0 ? net : 0, credit: net < 0 ? -net : 0));
    }
    return TrialBalance(rows);
  }
}
