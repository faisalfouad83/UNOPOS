import 'package:flutter/material.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../domain/account_totals.dart';
import 'account_labels.dart';
import 'accounting_shared.dart';
import 'accounts_tabs.dart';

/// The store's accounts by kind, each with what that kind means, its
/// balance at the end of the period and how much it moved in it. Tapping
/// an account lists its movements.
class ChartOfAccountsTab extends StatelessWidget {
  const ChartOfAccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TotalsView(
      builder: (context, totals) => [
        for (final type in AccountType.values)
          if (totals.ofType(type).isNotEmpty)
            SectionCard(
              title: accountTypeLabel(l10n, type.name),
              info: accountTypeInfo(l10n, type),
              children: [
                for (final a in totals.ofType(type))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${a.code} · ${accountLabel(l10n, a.code, a.name)}'),
                    subtitle: a.periodChange == 0 ? null : Text(l10n.acxChangeInPeriod(Money.format(a.periodChange))),
                    trailing: Text(Money.format(a.closingBalance)),
                    onTap: () => _showAccount(context, a),
                  ),
              ],
            ),
      ],
    );
  }

  void _showAccount(BuildContext context, AccountTotal a) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          children: [
            SectionCard(
              title: '${a.code} · ${accountLabel(l10n, a.code, a.name)}',
              children: [
                AmountRow(label: l10n.acxOpeningBalance, amount: a.openingBalance),
                AmountRow(label: l10n.acctDebit, amount: a.periodDebit, indent: true),
                AmountRow(label: l10n.acctCredit, amount: a.periodCredit, indent: true),
                const Divider(height: 8),
                AmountRow(label: l10n.acxClosingBalance, amount: a.closingBalance, bold: true),
              ],
            ),
            AccountMovements(codes: {a.code}),
          ],
        ),
      ),
    );
  }
}

/// What each kind of account is, in plain words.
String accountTypeInfo(AppLocalizations l10n, AccountType type) => switch (type) {
      AccountType.asset => l10n.acxAssetsInfo,
      AccountType.liability => l10n.acxLiabilitiesInfo,
      AccountType.equity => l10n.acxEquityInfo,
      AccountType.revenue => l10n.acxRevenueInfo,
      AccountType.cogs => l10n.acxCogsInfo,
      AccountType.expense => l10n.acxOperatingExpensesInfo,
    };
