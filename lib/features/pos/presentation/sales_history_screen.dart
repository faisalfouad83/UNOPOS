import '../../accounting/presentation/account_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/domain/auth_models.dart';
import '../../debts/domain/debts_models.dart';
import '../../printing/domain/receipt_models.dart';
import '../../printing/presentation/print_after_sale.dart';
import '../../printing/presentation/whatsapp_receipt_dialog.dart';
import '../domain/invoice_query.dart';
import '../domain/pos_models.dart';
import 'invoice_details_dialog.dart';
import 'invoices_screen.dart';
import 'process_return_dialog.dart';

final _todaysSalesProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: startOfDay);
});

final _searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key, required this.storeId});
  final String storeId;

  /// The receipt for [sale] as it was sold: its own cashier, branch and
  /// customer, and for a sale paid later what is still owed — the same as
  /// a reprint from the invoices screen. Also gives the customer's phone.
  Future<(ReceiptDocument, String?)> _receipt(BuildContext context, WidgetRef ref, SaleRecord sale) async {
    final debts = ref.read(debtsRepositoryProvider);
    final auth = ref.read(authRepositoryProvider);
    DebtLedgerEntryRecord? debt;
    if (sale.paymentMethod == SalePaymentMethod.payLater) {
      try {
        debt = await debts.findBySaleId(sale.id);
      } catch (_) {}
    }
    var customers = const <CustomerRecord>[];
    var employees = const <EmployeeRecord>[];
    try {
      customers = await debts.watchCustomers(storeId).first;
    } catch (_) {}
    try {
      employees = await auth.watchEmployees(storeId).first;
    } catch (_) {}
    if (!context.mounted) throw StateError('closed');
    final names = InvoiceNames(
      cashiers: {for (final e in employees) e.id: e.name},
      customers: {for (final c in customers) c.id: c},
    );
    final doc = await invoiceReceipt(context, ref, InvoiceRecord(sale: sale, debt: debt), names);
    return (doc, sale.customerId == null ? null : names.customers[sale.customerId]?.phone);
  }

  Future<void> _reprint(BuildContext context, WidgetRef ref, SaleRecord sale) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final settingsRepository = ref.read(settingsRepositoryProvider);
    try {
      final (doc, _) = await _receipt(context, ref, sale);
      final settings = await settingsRepository.ensureSettings(storeId);
      await printWithFeedback(messenger, l10n, doc, settings);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  Future<void> _sendWhatsApp(BuildContext context, WidgetRef ref, SaleRecord sale) async {
    final l10n = AppLocalizations.of(context);
    try {
      final (doc, phone) = await _receipt(context, ref, sale);
      if (context.mounted) await showWhatsAppReceiptDialog(context, doc, initialPhone: phone);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final salesAsync = ref.watch(_todaysSalesProvider(storeId));
    final query = ref.watch(_searchQueryProvider).trim().toLowerCase();
    final canReturn = ref.watch(sessionControllerProvider).employee?.can(AppPermission.processReturns) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posSalesHistory),
        actions: [
          if (canReturn)
            TextButton.icon(
              icon: const Icon(Icons.assignment_return_outlined),
              label: Text(l10n.returnInvoice),
              onPressed: () => showReturnInvoiceDialog(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.actionSearch),
              onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(l10n.errorGeneric)),
              data: (sales) {
                final filtered =
                    query.isEmpty ? sales : sales.where((s) => s.saleNumber.toLowerCase().contains(query)).toList();
                if (filtered.isEmpty) return Center(child: Text(l10n.posEmptyCart));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final sale = filtered[index];
                    return ListTile(
                      title: Text('${sale.saleNumber} · ${Money.format(sale.netTotalMinorUnits)}'),
                      subtitle: Text(
                        [
                          paymentMethodLabel(l10n, sale.paymentMethod),
                          AppDateFormat.dateTime(sale.completedAt ?? sale.createdAt),
                          if (sale.status == SaleStatus.refunded) l10n.returnStatusRefunded,
                          if (sale.status == SaleStatus.partiallyRefunded) l10n.returnStatusPartial,
                        ].join(' · '),
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print_outlined),
                            tooltip: l10n.posPrintReceipt,
                            onPressed: () => _reprint(context, ref, sale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_outlined),
                            tooltip: l10n.whatsappSendReceipt,
                            onPressed: () => _sendWhatsApp(context, ref, sale),
                          ),
                          if (canReturn && sale.canReturn)
                            TextButton(
                              child: Text(l10n.posProcessReturn),
                              onPressed: () => showProcessReturnDialog(context, ref, sale),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
