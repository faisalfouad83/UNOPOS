import 'package:flutter/material.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../domain/account_totals.dart';
import '../domain/financial_statements.dart';
import 'account_labels.dart';
import 'accounting_shared.dart';

/// Profit and loss for the period.
class ProfitLossTab extends StatelessWidget {
  const ProfitLossTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TotalsView(
      builder: (context, totals) {
        final pl = ProfitAndLoss.from(totals);
        return [
          SectionCard(
            title: l10n.accountingProfitLoss,
            info: l10n.acxProfitLossInfo,
            children: [
              AmountRow(label: l10n.acxGrossSales, amount: pl.grossSales, info: l10n.acxGrossSalesInfo),
              if (pl.returns != 0)
                AmountRow(label: l10n.acxReturns, amount: -pl.returns, indent: true, info: l10n.acxReturnsInfo),
              if (pl.discounts != 0)
                AmountRow(label: l10n.acxDiscounts, amount: -pl.discounts, indent: true, info: l10n.acxDiscountsInfo),
              if (pl.otherRevenue != 0) AmountRow(label: l10n.acxOtherRevenue, amount: pl.otherRevenue, indent: true),
              AmountRow(label: l10n.acxNetSales, amount: pl.netSales, bold: true, info: l10n.acxNetSalesInfo),
              const SizedBox(height: 6),
              AmountRow(label: l10n.acxCogs, amount: -pl.cogs, info: l10n.acxCogsInfo),
              const Divider(height: 8),
              AmountRow(
                label: l10n.acxGrossProfit,
                amount: pl.grossProfit,
                bold: true,
                negativeIsBad: true,
                info: l10n.acxGrossProfitInfo,
              ),
              const SizedBox(height: 6),
              Text(l10n.acxOperatingExpenses, style: Theme.of(context).textTheme.labelLarge),
              if (pl.expenses.isEmpty) Text(l10n.acxNone, style: Theme.of(context).textTheme.bodySmall),
              for (final e in pl.expenses)
                AmountRow(label: accountLabel(l10n, e.code, e.name), amount: -e.amount, indent: true),
              AmountRow(
                label: l10n.acxTotalExpenses,
                amount: -pl.totalExpenses,
                bold: true,
                info: l10n.acxOperatingExpensesInfo,
              ),
              const Divider(height: 8),
              AmountRow(
                label: pl.netProfit < 0 ? l10n.acxNetLoss : l10n.acxNetProfit,
                amount: pl.netProfit,
                bold: true,
                negativeIsBad: true,
                info: l10n.acxNetProfitInfo,
              ),
            ],
          ),
        ];
      },
    );
  }
}

/// Balance sheet at the end of the period, with the check that it balances.
class BalanceSheetTab extends StatelessWidget {
  const BalanceSheetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TotalsView(
      builder: (context, totals) {
        final bs = BalanceSheet.from(totals);
        final ok = bs.balances;
        final scheme = Theme.of(context).colorScheme;
        final assets = SectionCard(
          title: l10n.acctAssets,
          info: l10n.acxAssetsInfo,
          children: [
            for (final a in bs.assets) AmountRow(label: accountLabel(l10n, a.code, a.name), amount: a.amount),
            const Divider(height: 8),
            AmountRow(label: l10n.acxTotalAssets, amount: bs.totalAssets, bold: true),
          ],
        );
        final claims = SectionCard(
          title: l10n.acxLiabilitiesAndEquity,
          info: l10n.acxLiabilitiesAndEquityInfo,
          children: [
            Text(l10n.acctLiabilities, style: Theme.of(context).textTheme.labelLarge),
            for (final a in bs.liabilities)
              AmountRow(label: accountLabel(l10n, a.code, a.name), amount: a.amount, indent: true),
            AmountRow(
                label: l10n.acxTotalLiabilities,
                amount: bs.totalLiabilities,
                bold: true,
                info: l10n.acxLiabilitiesInfo),
            const SizedBox(height: 6),
            Text(l10n.acctEquity, style: Theme.of(context).textTheme.labelLarge),
            for (final a in bs.equity)
              AmountRow(label: accountLabel(l10n, a.code, a.name), amount: a.amount, indent: true),
            AmountRow(
              label: l10n.acxEarlierProfit,
              amount: bs.earlierProfit,
              indent: true,
              info: l10n.acxEarlierProfitInfo,
            ),
            AmountRow(
                label: l10n.acxPeriodProfit, amount: bs.periodProfit, indent: true, info: l10n.acxPeriodProfitInfo),
            AmountRow(label: l10n.acxTotalEquity, amount: bs.totalEquity, bold: true, info: l10n.acxEquityInfo),
            const Divider(height: 8),
            AmountRow(label: l10n.acxTotalLiabilitiesAndEquity, amount: bs.totalLiabilitiesAndEquity, bold: true),
          ],
        );
        return [
          Text(l10n.acxAsAt(AppDateFormat.dateTime(totals.to)), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(child: assets), const SizedBox(width: 8), Expanded(child: claims)],
                  )
                : Column(children: [assets, claims]),
          ),
          Card(
            color: ok ? Colors.green.withValues(alpha: 0.12) : scheme.errorContainer,
            child: ListTile(
              leading:
                  Icon(ok ? Icons.check_circle_outline : Icons.error_outline, color: ok ? Colors.green : scheme.error),
              title: Text(ok ? l10n.acxBalanced : l10n.acxNotBalanced(Money.format(bs.difference))),
              subtitle: Text(l10n.acxBalanceRule),
            ),
          ),
        ];
      },
    );
  }
}

/// Cash flow (direct method): money in and out of cash and bank, by cause.
class CashFlowTab extends StatelessWidget {
  const CashFlowTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String cause(String code) => journalReferenceLabel(l10n, journalReferenceFromCode(code));
    return TotalsView(
      builder: (context, totals) {
        final cf = CashFlow.from(totals);
        final fromAccounts = CashFlow.closingFromAccounts(totals);
        return [
          SectionCard(
            title: l10n.acxCashFlow,
            info: l10n.acxCashFlowInfo,
            children: [
              AmountRow(label: l10n.acxOpeningCash, amount: cf.opening, bold: true, info: l10n.acxOpeningCashInfo),
              const SizedBox(height: 6),
              Text(l10n.acxMoneyIn, style: Theme.of(context).textTheme.labelLarge),
              if (cf.inflows.isEmpty) Text(l10n.acxNone, style: Theme.of(context).textTheme.bodySmall),
              for (final e in cf.inflows.entries) AmountRow(label: cause(e.key), amount: e.value, indent: true),
              AmountRow(label: l10n.acxTotalIn, amount: cf.totalIn, bold: true),
              const SizedBox(height: 6),
              Text(l10n.acxMoneyOut, style: Theme.of(context).textTheme.labelLarge),
              if (cf.outflows.isEmpty) Text(l10n.acxNone, style: Theme.of(context).textTheme.bodySmall),
              for (final e in cf.outflows.entries) AmountRow(label: cause(e.key), amount: -e.value, indent: true),
              AmountRow(label: l10n.acxTotalOut, amount: -cf.totalOut, bold: true),
              const Divider(height: 8),
              AmountRow(label: l10n.acxNetCashChange, amount: cf.netChange, bold: true, negativeIsBad: true),
              AmountRow(label: l10n.acxClosingCash, amount: cf.closing, bold: true),
              if (fromAccounts != cf.closing)
                Text(l10n.acxCashFlowMismatch(Money.format(fromAccounts)),
                    style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(l10n.acxCashFlowTransfersNote, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ];
      },
    );
  }
}

/// Trial balance at the end of the period.
class TrialBalanceTab extends StatelessWidget {
  const TrialBalanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TotalsView(
      builder: (context, totals) {
        final tb = TrialBalance.from(totals);
        final theme = Theme.of(context);
        Widget row(String label, String debit, String credit, {bool bold = false}) {
          final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text(label, style: style)),
                Expanded(flex: 3, child: Text(debit, style: style, textAlign: TextAlign.end)),
                Expanded(flex: 3, child: Text(credit, style: style, textAlign: TextAlign.end)),
              ],
            ),
          );
        }

        return [
          SectionCard(
            title: l10n.accountingTrialBalance,
            info: l10n.acxTrialBalanceInfo,
            children: [
              Text(l10n.acxAsAt(AppDateFormat.dateTime(totals.to)), style: theme.textTheme.bodySmall),
              row('', l10n.acctDebit, l10n.acctCredit, bold: true),
              const Divider(height: 4),
              for (final r in tb.rows)
                row(
                  '${r.account.code} ${accountLabel(l10n, r.account.code, r.account.name)}',
                  r.debit == 0 ? '' : Money.format(r.debit),
                  r.credit == 0 ? '' : Money.format(r.credit),
                ),
              const Divider(height: 4),
              row(l10n.acxTotal, Money.format(tb.totalDebit), Money.format(tb.totalCredit), bold: true),
              const SizedBox(height: 6),
              Text(
                tb.balances ? l10n.acctBalanced : l10n.acctNotBalanced,
                style: TextStyle(
                  color: tb.balances ? Colors.green : theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ];
      },
    );
  }
}
