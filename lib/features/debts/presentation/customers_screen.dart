import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/store_settings_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/debts_models.dart';

final _customersProvider = StreamProvider.autoDispose.family<List<CustomerRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchCustomers(storeId);
});

final _openDebtsProvider = StreamProvider.autoDispose.family<List<DebtLedgerEntryRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchOpenDebts(storeId);
});

final _salesTotalsProvider = FutureProvider.autoDispose.family<Map<String, int>, String>((ref, storeId) {
  return ref.watch(posRepositoryProvider).salesTotalsByCustomer(storeId);
});

/// The store's registered customers: phone, what they owe, how much they've
/// bought in total and (with loyalty on) their points. Customers are added
/// here or from the till, and can be picked at checkout instead of selling
/// to a walk-in.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());

    final customersAsync = ref.watch(_customersProvider(storeId));
    final debts = ref.watch(_openDebtsProvider(storeId)).value ?? const <DebtLedgerEntryRecord>[];
    final totals = ref.watch(_salesTotalsProvider(storeId)).value ?? const <String, int>{};
    final loyaltyOn = ref.watch(currentStoreSettingsProvider).valueOrNull?.loyaltyEnabled ?? false;

    final owedByCustomer = <String, int>{};
    for (final d in debts) {
      owedByCustomer[d.customerId] = (owedByCustomer[d.customerId] ?? 0) + d.balanceRemainingMinorUnits;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCustomers),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.actionRefresh,
            onPressed: () => ref.invalidate(_salesTotalsProvider(storeId)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.actionSearch),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(l10n.errorGeneric)),
              data: (customers) {
                final list =
                    customers
                        .where(
                          (c) =>
                              _query.isEmpty ||
                              c.name.toLowerCase().contains(_query) ||
                              (c.phone ?? '').contains(_query),
                        )
                        .toList()
                      ..sort((a, b) => (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0));
                if (list.isEmpty) return Center(child: Text(l10n.customersNone));
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final owed = owedByCustomer[c.id] ?? 0;
                    final theme = Theme.of(context);
                    return ListTile(
                      leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
                      title: Text(c.name),
                      subtitle: Text(
                        [
                          if (c.phone?.isNotEmpty ?? false) c.phone!,
                          '${l10n.customersTotalSales}: ${Money.format(totals[c.id] ?? 0)}',
                          if (loyaltyOn) l10n.loyaltyPointsBalance(c.loyaltyPoints),
                        ].join(' · '),
                      ),
                      trailing: owed > 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.customersOwes, style: theme.textTheme.labelSmall),
                                Text(Money.format(owed), style: TextStyle(color: theme.colorScheme.error)),
                              ],
                            )
                          : null,
                      onTap: () => showCustomerEditDialog(context, ref, storeId, existing: c),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.loyaltyNewCustomer),
        onPressed: () => showCustomerEditDialog(context, ref, storeId),
      ),
    );
  }
}

/// Add a customer, or edit one's name, phone and address. Returns the saved
/// customer (null when cancelled).
Future<CustomerRecord?> showCustomerEditDialog(
  BuildContext context,
  WidgetRef ref,
  String storeId, {
  CustomerRecord? existing,
  String? initialName,
}) {
  final l10n = AppLocalizations.of(context);
  final name = TextEditingController(text: existing?.name ?? initialName);
  final phone = TextEditingController(text: existing?.phone);
  final address = TextEditingController(text: existing?.address);
  return showDialog<CustomerRecord>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(existing?.name ?? l10n.loyaltyNewCustomer),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.commonName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.commonPhone, prefixIcon: const Icon(Icons.phone)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: address,
              decoration: InputDecoration(labelText: l10n.commonAddress),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            final n = name.text.trim();
            if (n.isEmpty) return;
            final p = phone.text.trim().isEmpty ? null : phone.text.trim();
            final a = address.text.trim().isEmpty ? null : address.text.trim();
            final repo = ref.read(debtsRepositoryProvider);
            final CustomerRecord saved;
            if (existing == null) {
              saved = await repo.createCustomer(storeId, n, phone: p, address: a);
            } else {
              saved = CustomerRecord(
                id: existing.id,
                storeId: existing.storeId,
                name: n,
                phone: p,
                address: a,
                loyaltyPoints: existing.loyaltyPoints,
              );
              await repo.updateCustomer(saved);
            }
            if (dialogContext.mounted) Navigator.of(dialogContext).pop(saved);
          },
          child: Text(l10n.actionSave),
        ),
      ],
    ),
  );
}
