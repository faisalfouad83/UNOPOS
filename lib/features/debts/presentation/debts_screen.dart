import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/whatsapp.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/debts_models.dart';
import 'record_debt_payment_dialog.dart';

final _openDebtsProvider = StreamProvider.autoDispose.family<List<DebtLedgerEntryRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchOpenDebts(storeId);
});

final _customersProvider = StreamProvider.autoDispose.family<List<CustomerRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchCustomers(storeId);
});

/// What one customer owes across all their open pay-later sales.
class _CustomerDebts {
  _CustomerDebts(this.customerId, this.customer);
  final String customerId;
  final CustomerRecord? customer;
  final List<DebtLedgerEntryRecord> entries = [];

  int get totalOwed => entries.fold(0, (s, e) => s + e.balanceRemainingMinorUnits);
  DateTime get oldest => entries.map((e) => e.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
  int get daysOutstanding => DateTime.now().difference(oldest).inDays;
}

/// Open debts grouped by customer — largest first — with each customer's
/// sales underneath and a WhatsApp reminder button.
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  Future<void> _remind(BuildContext context, WidgetRef ref, _CustomerDebts group) async {
    final l10n = AppLocalizations.of(context);
    var phone = group.customer?.phone;
    if (phone == null || phone.trim().isEmpty) {
      phone = await _askPhone(context, group.customer?.name ?? '');
      if (phone == null) return;
      await ref.read(debtsRepositoryProvider).updateCustomerPhone(group.customerId, phone);
    }
    final storeName = ref.read(sessionControllerProvider).store?.displayName ?? '';
    final message = l10n.debtsReminderMessage(
      group.customer?.name ?? '',
      storeName,
      Money.format(group.totalOwed),
    );
    final ok = await WhatsApp.send(phone, message);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.whatsappInvalidPhone)));
    }
  }

  Future<String?> _askPhone(BuildContext context, String customerName) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(customerName),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.whatsappPhone,
            hintText: '07XX XXX XXXX',
            prefixIcon: const Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (WhatsApp.normalizePhone(text) != null) Navigator.of(dialogContext).pop(text);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

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
          if (debts.isEmpty) return Center(child: Text(l10n.debtsNone));
          final customersById = {for (final c in (customersAsync.value ?? const <CustomerRecord>[])) c.id: c};

          final groups = <String, _CustomerDebts>{};
          for (final entry in debts) {
            groups
                .putIfAbsent(entry.customerId, () => _CustomerDebts(entry.customerId, customersById[entry.customerId]))
                .entries
                .add(entry);
          }
          final sorted = groups.values.toList()..sort((a, b) => b.totalOwed.compareTo(a.totalOwed));
          final grandTotal = sorted.fold(0, (s, g) => s + g.totalOwed);

          return ListView(
            children: [
              ListTile(
                title: Text(l10n.debtsTotalOutstanding, style: Theme.of(context).textTheme.titleMedium),
                trailing: Text(Money.format(grandTotal), style: Theme.of(context).textTheme.titleLarge),
              ),
              const Divider(height: 1),
              for (final group in sorted)
                ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(_initial(group.customer?.name)),
                  ),
                  title: Text(group.customer?.name ?? group.customerId),
                  subtitle: Text([
                    l10n.debtsSalesCount(group.entries.length),
                    l10n.debtsDaysOutstanding(group.daysOutstanding),
                    if (group.customer?.phone?.isNotEmpty ?? false) group.customer!.phone!,
                  ].join(' · ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Money.format(group.totalOwed), style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.chat_outlined),
                        tooltip: l10n.debtsSendReminder,
                        onPressed: () => _remind(context, ref, group),
                      ),
                    ],
                  ),
                  children: [
                    for (final entry in group.entries)
                      ListTile(
                        dense: true,
                        title: Text('${entry.receiptRef ?? ''} · ${AppDateFormat.shortDate(entry.createdAt)}'),
                        subtitle: Text(switch (entry.status) {
                          DebtStatus.open => l10n.debtsOpen,
                          DebtStatus.partiallyPaid => l10n.debtsPartiallyPaid,
                          DebtStatus.paid => l10n.debtsPaid,
                        }),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Money.format(entry.balanceRemainingMinorUnits)),
                            TextButton(
                              onPressed: () => showRecordDebtPaymentDialog(context, ref, entry),
                              child: Text(l10n.debtsRecordPayment),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The first letter of [name], for an avatar ('?' when there is none).
String _initial(String? name) {
  final n = name?.trim() ?? '';
  return n.isEmpty ? '?' : n.characters.first.toUpperCase();
}
