import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import 'add_expense_dialog.dart';
import 'chart_of_accounts_tab.dart';
import 'journal_tab.dart';
import 'reports_tab.dart';

class AccountingScreen extends ConsumerWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.accountingTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Reports'),
              Tab(text: l10n.accountingJournal),
              Tab(text: l10n.accountingChartOfAccounts),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ReportsTab(),
            JournalTab(),
            ChartOfAccountsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAddExpenseDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.accountingAddExpense),
        ),
      ),
    );
  }
}
