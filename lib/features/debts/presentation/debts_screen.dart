import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/debts_models.dart';
import 'record_debt_payment_dialog.dart';

final _openDebtsProvider = StreamProvider.autoDispose.family<List<DebtLedgerEntryRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchOpenDebts(storeId);
});

final _customersProvider = StreamProvider.autoDispose.family<List<CustomerRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchCustomers(storeId);
});

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());

    final debtsAsync = ref.watch(_openDebtsProvider(storeId));
    final customersAsync = ref.watch(_customersProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debtsTitle)),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (debts) {
          if (debts.isEmpty) return Center(child: Text(l10n.debtsTitle));
          final customersById = {for (final c in (customersAsync.value ?? const <CustomerRecord>[])) c.id: c};

          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final entry = debts[index];
              final customer = customersById[entry.customerId];
              final statusLabel = switch (entry.status) {
                DebtStatus.open => l10n.debtsOpen,
                DebtStatus.partiallyPaid => l10n.debtsPartiallyPaid,
                DebtStatus.paid => l10n.debtsPaid,
              };
              return ListTile(
                leading: CircleAvatar(child: Text((customer?.name ?? '?').isNotEmpty ? customer!.name[0].toUpperCase() : '?')),
                title: Text(customer?.name ?? entry.customerId),
                subtitle: Text('${entry.receiptRef ?? ''} · ${AppDateFormat.shortDate(entry.createdAt)} · $statusLabel'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Money.format(entry.balanceRemainingMinorUnits, currencySymbol: r'$'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => showRecordDebtPaymentDialog(context, ref, entry),
                      child: Text(l10n.debtsRecordPayment),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
