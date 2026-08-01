import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/accounting_models.dart';

final _accountsProvider = FutureProvider.autoDispose.family<List<ChartOfAccountEntry>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).listAccounts(storeId);
});

final _trialBalanceProvider = FutureProvider.autoDispose.family<Map<String, int>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).trialBalance(storeId);
});

class ChartOfAccountsTab extends ConsumerWidget {
  const ChartOfAccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();

    final accountsAsync = ref.watch(_accountsProvider(storeId));
    final balancesAsync = ref.watch(_trialBalanceProvider(storeId));

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l10n.errorGeneric)),
      data: (accounts) {
        final balances = balancesAsync.value ?? const <String, int>{};
        final grouped = <String, List<ChartOfAccountEntry>>{};
        for (final a in accounts) {
          grouped.putIfAbsent(a.type, () => []).add(a);
        }
        return ListView(
          children: grouped.entries.map((group) {
            return ExpansionTile(
              title: Text(group.key.toUpperCase(), style: Theme.of(context).textTheme.titleSmall),
              initiallyExpanded: true,
              children: group.value.map((account) {
                final balance = balances[account.code] ?? 0;
                return ListTile(
                  dense: true,
                  title: Text('${account.code} · ${account.name}'),
                  trailing: Text(Money.format(balance, currencySymbol: r'$')),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}
