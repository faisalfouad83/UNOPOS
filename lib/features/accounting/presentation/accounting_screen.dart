import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import 'accounting_shared.dart';
import 'accounts_tabs.dart';
import 'add_expense_dialog.dart';
import 'audit_trail_tab.dart';
import 'chart_of_accounts_tab.dart';
import 'journal_tab.dart';
import 'overview_tab.dart';
import 'statements_tabs.dart';

/// Accounting for the owner: an overview of the chosen period, the journal,
/// accounts, what customers and suppliers owe, and the statements (trial
/// balance, profit and loss, balance sheet, cash flow), plus the audit
/// trail. Everything is worked out from the journal.
class AccountingScreen extends ConsumerWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabs = <(String, Widget)>[
      (l10n.acxOverview, const OverviewTab()),
      (l10n.accountingJournal, const JournalTab()),
      (l10n.accountingChartOfAccounts, const ChartOfAccountsTab()),
      (l10n.acxCashAndBank, const CashBankTab()),
      (
        l10n.acxReceivables,
        AccountFocusTab(
          code: SystemAccountCodes.accountsReceivable,
          info: l10n.acxReceivablesInfo,
          route: RoutePaths.debts,
          routeLabel: l10n.acxOpenDebts,
        ),
      ),
      (
        l10n.acxPayables,
        AccountFocusTab(
          code: SystemAccountCodes.accountsPayable,
          info: l10n.acxPayablesInfo,
          route: RoutePaths.suppliers,
          routeLabel: l10n.acxOpenSuppliers,
        ),
      ),
      (l10n.accountingTrialBalance, const TrialBalanceTab()),
      (l10n.accountingProfitLoss, const ProfitLossTab()),
      (l10n.accountingBalanceSheet, const BalanceSheetTab()),
      (l10n.acxCashFlow, const CashFlowTab()),
      (l10n.acxAuditTrail, const AuditTrailTab()),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.accountingTitle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight + 52),
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final t in tabs) Tab(text: t.$1)],
                ),
                const SizedBox(height: 52, child: PeriodBar()),
              ],
            ),
          ),
        ),
        body: TabBarView(children: [for (final t in tabs) t.$2]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await showAddExpenseDialog(context, ref);
            refreshAccounting(ref);
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.accountingAddExpense),
        ),
      ),
    );
  }
}
