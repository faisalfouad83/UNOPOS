import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/accounting_models.dart';

final _accountsProvider2 = FutureProvider.autoDispose.family<List<ChartOfAccountEntry>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).listAccounts(storeId);
});

final _trialBalanceProvider2 = FutureProvider.autoDispose.family<Map<String, int>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).trialBalance(storeId);
});

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();

    final accountsAsync = ref.watch(_accountsProvider2(storeId));
    final balancesAsync = ref.watch(_trialBalanceProvider2(storeId));

    if (!accountsAsync.hasValue || !balancesAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    final accounts = accountsAsync.value!;
    final balances = balancesAsync.value!;
    final byType = <String, List<ChartOfAccountEntry>>{};
    for (final a in accounts) {
      byType.putIfAbsent(a.type, () => []).add(a);
    }

    int sumType(String type) =>
        (byType[type] ?? const []).fold<int>(0, (s, a) => s + (balances[a.code] ?? 0));

    final revenue = sumType(AccountType.revenue.name);
    final cogs = sumType(AccountType.cogs.name);
    final expenses = sumType(AccountType.expense.name);
    final netIncome = revenue - cogs - expenses;

    final assets = sumType(AccountType.asset.name);
    final liabilities = sumType(AccountType.liability.name);
    final equity = sumType(AccountType.equity.name);

    final totalDebitNormal = sumType(AccountType.asset.name) + sumType(AccountType.expense.name) + sumType(AccountType.cogs.name);
    final totalCreditNormal = sumType(AccountType.liability.name) + sumType(AccountType.equity.name) + sumType(AccountType.revenue.name);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.accountingProfitLoss, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _row(context, 'Revenue', revenue),
        _row(context, 'COGS', -cogs),
        _row(context, 'Expenses', -expenses),
        const Divider(),
        _row(context, 'Net Income', netIncome, bold: true),
        const SizedBox(height: 24),
        Text(l10n.accountingBalanceSheet, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _row(context, 'Assets', assets),
        _row(context, 'Liabilities', liabilities),
        _row(context, "Equity (posted)", equity),
        const SizedBox(height: 4),
        Text(
          'Note: current-period net income rolls into equity only once a period-close entry is posted (not yet automated).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Text(l10n.accountingTrialBalance, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...accounts.map((a) => _row(context, '${a.code} ${a.name}', balances[a.code] ?? 0)),
        const Divider(),
        _row(context, 'Debit-normal total', totalDebitNormal),
        _row(context, 'Credit-normal total', totalCreditNormal),
        Text(
          totalDebitNormal == totalCreditNormal ? 'Books balance ✓' : 'Books do NOT balance — investigate',
          style: TextStyle(
            color: totalDebitNormal == totalCreditNormal ? Colors.green : Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, int minorUnits, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(Money.format(minorUnits, currencySymbol: r'$'), style: style),
        ],
      ),
    );
  }
}
