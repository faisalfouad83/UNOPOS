import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/store_settings_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../accounting/presentation/account_labels.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/presentation/tile_picker_screen.dart';
import '../../pos/domain/invoice_query.dart';
import '../../pos/presentation/invoice_details_dialog.dart';
import '../../pos/presentation/invoices_screen.dart';
import '../domain/debts_models.dart';
import 'customers_screen.dart';

final _customerInvoicesProvider =
    FutureProvider.autoDispose.family<List<InvoiceRecord>, ({String storeId, String customerId})>((ref, key) {
  return ref
      .watch(posRepositoryProvider)
      .listInvoices(InvoiceQuery(storeId: key.storeId, customerIds: {key.customerId}, limit: 30));
});

final _customerDebtsProvider =
    StreamProvider.autoDispose.family<List<DebtLedgerEntryRecord>, String>((ref, customerId) {
  return ref.watch(debtsRepositoryProvider).watchDebtsForCustomer(customerId);
});

/// Everything about one customer in one place: contact, loyalty, what they
/// bought (their latest invoices), and what they owe with each debt's
/// payments. Opens the edit form from here.
Future<void> showCustomerDetails(
  BuildContext context,
  WidgetRef ref,
  CustomerRecord customer, {
  required int totalPurchasesMinorUnits,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CustomerDetailsDialog(customer: customer, totalPurchases: totalPurchasesMinorUnits),
  );
}

class _CustomerDetailsDialog extends ConsumerWidget {
  const _CustomerDetailsDialog({required this.customer, required this.totalPurchases});

  final CustomerRecord customer;
  final int totalPurchases;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final storeId = customer.storeId;
    final settings = ref.watch(currentStoreSettingsProvider).valueOrNull;
    final loyaltyOn = settings?.loyaltyEnabled ?? false;
    final invoicesAsync = ref.watch(_customerInvoicesProvider((storeId: storeId, customerId: customer.id)));
    final debts = ref.watch(_customerDebtsProvider(customer.id)).valueOrNull ?? const <DebtLedgerEntryRecord>[];
    final owed =
        debts.fold<int>(0, (s, d) => s + (d.balanceRemainingMinorUnits > 0 ? d.balanceRemainingMinorUnits : 0));
    final branches = ref.watch(storeBranchesProvider(storeId)).valueOrNull ?? const <BranchRecord>[];
    final employees = ref.watch(storeEmployeesProvider(storeId)).valueOrNull ?? const <EmployeeRecord>[];
    final names = InvoiceNames(
      branches: {for (final b in branches) b.id: b.name},
      cashiers: {for (final e in employees) e.id: e.name},
      customers: {customer.id: customer},
    );

    Widget stat(String label, String value, {Color? color}) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color)),
                ],
              ),
            ),
          ),
        );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
              leading: CircleAvatar(
                  child:
                      Text(customer.name.trim().isEmpty ? '?' : customer.name.trim().characters.first.toUpperCase())),
              title: Text(customer.name, style: theme.textTheme.titleLarge),
              subtitle: Text(
                [
                  if (customer.phone?.isNotEmpty ?? false) customer.phone!,
                  if (customer.address?.isNotEmpty ?? false) customer.address!,
                ].join(' · '),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.actionEdit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      // Opened over this one (which stays open until the
                      // edit is saved), so the edit form's context and ref
                      // are still alive while it saves.
                      await showCustomerEditDialog(context, ref, storeId, existing: customer);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Row(
                    children: [
                      stat(l10n.customersTotalSales, Money.format(totalPurchases)),
                      stat(
                        l10n.customersOwes,
                        Money.format(owed),
                        color: owed > 0 ? theme.colorScheme.error : null,
                      ),
                    ],
                  ),
                  if (loyaltyOn)
                    Row(
                      children: [
                        stat(l10n.loyaltyBalance, l10n.loyaltyPointsBalance(customer.loyaltyPoints)),
                        stat(
                          l10n.customerLoyaltyValue,
                          Money.format(customer.loyaltyPoints * (settings?.loyaltyPointValueMinor ?? 0)),
                        ),
                      ],
                    ),
                  if (loyaltyOn)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.card_membership, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(l10n.customerLoyaltyMember, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(l10n.customerDebts, style: theme.textTheme.titleSmall),
                  if (debts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l10n.customerNoDebts, style: theme.textTheme.bodySmall),
                    ),
                  for (final d in debts)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        d.status == DebtStatus.paid ? Icons.check_circle_outline : Icons.schedule,
                        color: d.status == DebtStatus.paid ? Colors.green.shade700 : theme.colorScheme.error,
                      ),
                      title: Text('${d.receiptRef ?? ''} · ${Money.format(d.originalAmountMinorUnits)}'),
                      subtitle: Text(
                        '${AppDateFormat.shortDate(d.createdAt)} · ${l10n.invoicePaid}: ${Money.format(d.amountPaidMinorUnits)}',
                      ),
                      trailing: d.balanceRemainingMinorUnits > 0
                          ? Text(
                              Money.format(d.balanceRemainingMinorUnits),
                              style: TextStyle(color: theme.colorScheme.error),
                            )
                          : null,
                    ),
                  const SizedBox(height: 12),
                  Text(l10n.customerInvoices, style: theme.textTheme.titleSmall),
                  invoicesAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
                    error: (e, st) => Text(l10n.errorGeneric),
                    data: (invoices) => invoices.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(l10n.invoiceNone, style: theme.textTheme.bodySmall),
                          )
                        : Column(
                            children: [
                              for (final inv in invoices)
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.receipt_long_outlined),
                                  title: Text('${inv.sale.saleNumber} · ${Money.format(inv.totalMinorUnits)}'),
                                  subtitle: Text(
                                    [
                                      AppDateFormat.dateTime(inv.sale.completedAt ?? inv.sale.createdAt),
                                      paymentMethodLabel(l10n, inv.sale.paymentMethod),
                                      invoiceStatusLabel(l10n, inv.status),
                                    ].join(' · '),
                                  ),
                                  onTap: () => showInvoiceDetails(context, ref, inv, names),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
