import 'package:flutter/material.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../domain/financial_statements.dart';
import 'accounting_shared.dart';

/// The owner's first look: sales, profit, cash in and out, and what is owed
/// either way — all from the journal, for the chosen period.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TotalsView(
      builder: (context, totals) {
        final o = OwnerOverview.from(totals);
        final pl = o.profitAndLoss;
        final margin = pl.netSales == 0 ? null : (pl.grossProfit * 100 / pl.netSales).round();
        return [
          TileGrid(
            children: [
              FigureTile(
                title: l10n.acxNetSales,
                amount: pl.netSales,
                info: l10n.acxNetSalesInfo,
                icon: Icons.point_of_sale_outlined,
                subtitle: pl.returns == 0 && pl.discounts == 0
                    ? null
                    : l10n.acxNetSalesBreakdown(
                        Money.format(pl.grossSales),
                        Money.format(pl.returns),
                        Money.format(pl.discounts),
                      ),
              ),
              FigureTile(
                title: l10n.acxGrossProfit,
                amount: pl.grossProfit,
                info: l10n.acxGrossProfitInfo,
                icon: Icons.trending_up,
                negativeIsBad: true,
                subtitle: margin == null ? null : l10n.acxMargin(margin),
              ),
              FigureTile(
                title: l10n.acxNetProfit,
                amount: pl.netProfit,
                info: l10n.acxNetProfitInfo,
                icon: Icons.savings_outlined,
                negativeIsBad: true,
                subtitle: pl.netProfit < 0 ? l10n.acxLoss : null,
              ),
              FigureTile(
                title: l10n.acxCashOnHand,
                amount: o.cash,
                info: l10n.acxCashOnHandInfo,
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: l10n.acxProfitSummary,
            info: l10n.acxProfitSummaryInfo,
            children: [
              AmountRow(label: l10n.acxNetSales, amount: pl.netSales, info: l10n.acxNetSalesInfo),
              AmountRow(label: l10n.acxCogs, amount: -pl.cogs, info: l10n.acxCogsInfo),
              const Divider(height: 8),
              AmountRow(label: l10n.acxGrossProfit, amount: pl.grossProfit, bold: true, negativeIsBad: true),
              AmountRow(
                  label: l10n.acxOperatingExpenses, amount: -pl.totalExpenses, info: l10n.acxOperatingExpensesInfo),
              const Divider(height: 8),
              AmountRow(label: l10n.acxNetProfit, amount: pl.netProfit, bold: true, negativeIsBad: true),
            ],
          ),
          SectionCard(
            title: l10n.acxCashMovement,
            info: l10n.acxCashMovementInfo,
            children: [
              AmountRow(label: l10n.acxCashReceived, amount: o.cashReceived),
              AmountRow(label: l10n.acxCashPaidOut, amount: -o.cashPaidOut),
              const Divider(height: 8),
              AmountRow(
                  label: l10n.acxCashNet, amount: o.cashReceived - o.cashPaidOut, bold: true, negativeIsBad: true),
            ],
          ),
          SectionCard(
            title: l10n.acxBalancesNow(AppDateFormat.shortDate(totals.to)),
            info: l10n.acxBalancesInfo,
            children: [
              AmountRow(label: l10n.acxCashOnHand, amount: o.cash, info: l10n.acxCashOnHandInfo),
              AmountRow(label: l10n.acxBank, amount: o.bank, info: l10n.acxBankInfo),
              AmountRow(label: l10n.acxReceivables, amount: o.receivables, info: l10n.acxReceivablesInfo),
              AmountRow(label: l10n.acxPayables, amount: o.payables, info: l10n.acxPayablesInfo),
            ],
          ),
        ];
      },
    );
  }
}
