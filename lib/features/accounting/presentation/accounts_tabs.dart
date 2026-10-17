import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/account_totals.dart';
import 'account_labels.dart';
import 'accounting_shared.dart';
import 'journal_tab.dart';

/// Cash on hand and bank: each account's opening balance, money in, money
/// out and closing balance, then every movement in the period.
class CashBankTab extends StatelessWidget {
  const CashBankTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TotalsView(
      builder: (context, totals) => [
        for (final code in kCashAccountCodes)
          _AccountSummaryCard(
            account: totals.account(code),
            info: code == SystemAccountCodes.cash ? l10n.acxCashOnHandInfo : l10n.acxBankInfo,
          ),
        AccountMovements(codes: kCashAccountCodes),
      ],
    );
  }
}

/// One account the owner follows closely (customers' debts, suppliers'
/// bills): its balance, what added to it and what reduced it in the
/// period, its movements, and a way to the screen that manages it.
class AccountFocusTab extends StatelessWidget {
  const AccountFocusTab({
    super.key,
    required this.code,
    required this.info,
    required this.route,
    required this.routeLabel,
  });

  final String code;
  final String info;
  final String route;
  final String routeLabel;

  @override
  Widget build(BuildContext context) {
    return TotalsView(
      builder: (context, totals) => [
        _AccountSummaryCard(
          account: totals.account(code),
          info: info,
          trailing: TextButton.icon(
            onPressed: () => context.go(route),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(routeLabel),
          ),
        ),
        AccountMovements(codes: {code}),
      ],
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({required this.account, required this.info, this.trailing});
  final AccountTotal account;
  final String info;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // "Added" is the side that grows the balance: debits for what the store
    // has (cash, customers' debts), credits for what it owes.
    final added = account.isDebitNormal ? account.periodDebit : account.periodCredit;
    final reduced = account.isDebitNormal ? account.periodCredit : account.periodDebit;
    return SectionCard(
      title: '${account.code} · ${accountLabel(l10n, account.code, account.name)}',
      info: info,
      children: [
        AmountRow(label: l10n.acxOpeningBalance, amount: account.openingBalance),
        AmountRow(label: account.isDebitNormal ? l10n.acxMoneyIn : l10n.acxAddedOwed, amount: added, indent: true),
        AmountRow(label: account.isDebitNormal ? l10n.acxMoneyOut : l10n.acxPaidOff, amount: -reduced, indent: true),
        const Divider(height: 8),
        AmountRow(label: l10n.acxClosingBalance, amount: account.closingBalance, bold: true),
        if (trailing != null) Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
      ],
    );
  }
}

/// Every journal line on [codes] in the period, newest first; tapping one
/// opens its entry.
class AccountMovements extends ConsumerWidget {
  const AccountMovements({super.key, required this.codes});
  final Set<String> codes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();
    final period = ref.watch(accountingPeriodProvider);
    final async = ref.watch(periodJournalProvider((storeId, period)));
    final chart = ref.watch(chartOfAccountsProvider(storeId)).valueOrNull ?? const [];
    final names = {for (final a in chart) a.code: a.name};
    return SectionCard(
      title: l10n.acxMovements,
      children: async.when(
        loading: () => [const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator())],
        error: (e, _) => [Text(l10n.errorGeneric)],
        data: (entries) {
          final rows = [
            for (final e in entries)
              for (final line in e.lines)
                if (codes.contains(line.accountCode)) (e, line),
          ];
          if (rows.isEmpty) return [Text(l10n.acxNoMovements, style: Theme.of(context).textTheme.bodySmall)];
          return [
            for (final (e, line) in rows.take(300))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () => showJournalEntryDetails(context, ref, e),
                title: Text(
                  '${journalReferenceLabel(l10n, e.referenceType)} · ${journalMemoLabel(l10n, e.memo)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${AppDateFormat.dateTime(e.entryDate)}'
                  '${codes.length > 1 ? ' · ${accountLabel(l10n, line.accountCode, names[line.accountCode] ?? line.accountCode)}' : ''}',
                ),
                trailing: Text(
                  line.debitMinorUnits > 0
                      ? '${l10n.acctDebit} ${Money.format(line.debitMinorUnits)}'
                      : '${l10n.acctCredit} ${Money.format(line.creditMinorUnits)}',
                ),
              ),
            if (rows.length > 300) Text(l10n.acxShowingFirst(300), style: Theme.of(context).textTheme.bodySmall),
          ];
        },
      ),
    );
  }
}
