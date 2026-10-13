import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../accounting/presentation/account_labels.dart';
import '../../auth/domain/session_controller.dart';
import '../../debts/domain/debts_models.dart';
import '../../printing/domain/receipt_models.dart';
import '../../printing/presentation/print_after_sale.dart';
import '../../printing/presentation/receipt_preview_dialog.dart';
import '../../printing/presentation/sale_receipt.dart';
import '../../printing/presentation/whatsapp_receipt_dialog.dart';
import '../domain/invoice_query.dart';
import '../domain/pos_models.dart';
import 'invoices_screen.dart';
import 'process_return_dialog.dart';

/// Product names for [sale]'s lines (sale lines only carry product ids),
/// including products since removed from the catalog.
Future<Map<String, String>> _productNames(WidgetRef ref, SaleRecord sale) async {
  final inventory = ref.read(inventoryRepositoryProvider);
  final names = <String, String>{};
  for (final id in sale.lines.map((l) => l.productId).toSet()) {
    try {
      names[id] = (await inventory.getProduct(id))?.name ?? id;
    } catch (_) {
      names[id] = id;
    }
  }
  return names;
}

/// Builds the receipt for an invoice exactly as it was sold: its own
/// cashier, branch and customer (not whoever is signed in now).
Future<ReceiptDocument> invoiceReceipt(
    BuildContext context, WidgetRef ref, InvoiceRecord invoice, InvoiceNames names) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  final settings = await ref.read(settingsRepositoryProvider).ensureSettings(invoice.sale.storeId);
  final branches = await ref.read(authRepositoryProvider).listBranches(invoice.sale.storeId);
  final customer = invoice.sale.customerId == null ? null : names.customers[invoice.sale.customerId];
  return buildSaleReceipt(
    inventory: ref.read(inventoryRepositoryProvider),
    session: session,
    sale: invoice.sale,
    settings: settings,
    l10n: l10n,
    cashierName: names.cashier(invoice.sale.cashierId),
    branch: branches.where((b) => b.id == invoice.sale.branchId).firstOrNull,
    customerName: customer?.name,
    extraRows: [
      if (invoice.isPayLater) (l10n.payRemaining, Money.format(invoice.remainingMinorUnits)),
    ],
  );
}

Future<void> showInvoiceDetails(BuildContext context, WidgetRef ref, InvoiceRecord invoice, InvoiceNames names) async {
  final productNames = await _productNames(ref, invoice.sale);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => _InvoiceDetailsDialog(invoice: invoice, names: names, productNames: productNames),
  );
}

class _InvoiceDetailsDialog extends ConsumerWidget {
  const _InvoiceDetailsDialog({required this.invoice, required this.names, required this.productNames});

  final InvoiceRecord invoice;
  final InvoiceNames names;
  final Map<String, String> productNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sale = invoice.sale;
    final customer = sale.customerId == null ? null : names.customers[sale.customerId];
    final canReturn = ref.watch(sessionControllerProvider).employee?.can(AppPermission.processReturns) ?? false;
    final status = invoice.status;

    Widget info(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 130, child: Text(label, style: theme.textTheme.bodySmall)),
              Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
            ],
          ),
        );

    Widget total(String label, int amount, {bool bold = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(label, style: bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                Money.format(amount),
                style: (bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(color: color),
              ),
            ],
          ),
        );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
              child: Row(
                children: [
                  Expanded(child: Text('${l10n.invoiceTitle} ${sale.saleNumber}', style: theme.textTheme.titleLarge)),
                  Chip(
                    label: Text(invoiceStatusLabel(l10n, status)),
                    labelStyle: TextStyle(color: invoiceStatusColor(theme.colorScheme, status)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    info(l10n.invoiceDate, AppDateFormat.dateTime(sale.completedAt ?? sale.createdAt)),
                    info(l10n.invoiceBranch, names.branch(sale.branchId)),
                    info(l10n.receiptCashier, names.cashier(sale.cashierId)),
                    info(
                      l10n.receiptCustomer,
                      customer == null
                          ? (invoice.isPayLater ? l10n.invoiceCreditCustomer : l10n.customerWalkIn)
                          : [customer.name, if (customer.phone?.isNotEmpty ?? false) customer.phone!].join(' · '),
                    ),
                    info(l10n.receiptPayment, paymentMethodLabel(l10n, sale.paymentMethod)),
                    const Divider(height: 24),
                    for (final line in sale.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(productNames[line.productId] ?? line.productId,
                                      style: theme.textTheme.titleSmall),
                                  Text(
                                    [
                                      '${line.quantity} × ${Money.format(line.unitPriceMinorUnits)}',
                                      if (line.discountAmountMinorUnits > 0)
                                        '${l10n.commonDiscount} -${Money.format(line.discountAmountMinorUnits)}',
                                      if (line.taxAmountMinorUnits > 0)
                                        '${l10n.receiptTax} ${Money.format(line.taxAmountMinorUnits)}',
                                      if (line.quantityReturned > 0)
                                        l10n.returnSoldReturned(line.quantity, line.quantityReturned),
                                    ].join(' · '),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(Money.format(line.lineTotalMinorUnits)),
                          ],
                        ),
                      ),
                    const Divider(height: 24),
                    total(l10n.receiptSubtotal, sale.subtotalMinorUnits),
                    if (sale.discountTotalMinorUnits > 0) total(l10n.commonDiscount, -sale.discountTotalMinorUnits),
                    if (sale.taxTotalMinorUnits > 0) total(l10n.receiptTax, sale.taxTotalMinorUnits),
                    total(l10n.commonTotal, sale.grandTotalMinorUnits, bold: true),
                    if (sale.refundedMinorUnits > 0) ...[
                      total(l10n.returnRefund, -sale.refundedMinorUnits, color: theme.colorScheme.error),
                      total(l10n.invoiceNetTotal, sale.netTotalMinorUnits, bold: true),
                    ],
                    const SizedBox(height: 8),
                    if (sale.paymentMethod == SalePaymentMethod.cash && sale.amountTenderedMinorUnits != null) ...[
                      total(l10n.receiptTendered, sale.amountTenderedMinorUnits!),
                      if ((sale.changeGivenMinorUnits ?? 0) > 0) total(l10n.posChangeDue, sale.changeGivenMinorUnits!),
                    ],
                    total(l10n.invoicePaid, invoice.paidMinorUnits, color: Colors.green.shade700),
                    if (invoice.isPayLater)
                      total(l10n.payRemaining, invoice.remainingMinorUnits, bold: true, color: theme.colorScheme.error),
                    if (invoice.debt != null) _PaymentHistory(debt: invoice.debt!, names: names),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (canReturn && sale.canReturn)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.assignment_return_outlined),
                      label: Text(l10n.posProcessReturn),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await showProcessReturnDialog(context, ref, sale);
                      },
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                    onPressed: () async {
                      final doc = await invoiceReceipt(context, ref, invoice, names);
                      if (context.mounted) await showWhatsAppReceiptDialog(context, doc, initialPhone: customer?.phone);
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.preview_outlined),
                    label: Text(l10n.printPreview),
                    onPressed: () async {
                      final doc = await invoiceReceipt(context, ref, invoice, names);
                      final settings = await ref.read(settingsRepositoryProvider).ensureSettings(sale.storeId);
                      if (context.mounted) await showReceiptPreview(context, doc, settings);
                    },
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.print_outlined),
                    label: Text(l10n.invoiceReprint),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final doc = await invoiceReceipt(context, ref, invoice, names);
                      final settings = await ref.read(settingsRepositoryProvider).ensureSettings(sale.storeId);
                      if (context.mounted) await printWithFeedback(messenger, l10n, doc, settings);
                    },
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

class _PaymentHistory extends ConsumerWidget {
  const _PaymentHistory({required this.debt, required this.names});
  final DebtLedgerEntryRecord debt;
  final InvoiceNames names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return StreamBuilder<List<DebtPaymentRecord>>(
      stream: ref.watch(debtsRepositoryProvider).watchPaymentHistory(debt.id),
      builder: (context, snapshot) {
        final payments = snapshot.data ?? const <DebtPaymentRecord>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(l10n.invoicePaymentHistory, style: theme.textTheme.titleSmall),
            if (!snapshot.hasData) const LinearProgressIndicator(),
            if (snapshot.hasData && payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l10n.invoiceNoPayments, style: theme.textTheme.bodySmall),
              ),
            for (final p in payments)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: Text(Money.format(p.amountMinorUnits)),
                subtitle: Text('${AppDateFormat.dateTime(p.paidAt)} · ${names.cashier(p.receivedByUserId)}'),
              ),
          ],
        );
      },
    );
  }
}
