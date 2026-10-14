import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../accounting/presentation/account_labels.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/pos_models.dart';
import '../domain/process_sale_return_use_case.dart';

/// "Return invoice": type the number printed on the receipt, see the
/// invoice, then return all or part of it.
Future<void> showReturnInvoiceDialog(BuildContext context, WidgetRef ref) async {
  final storeId = ref.read(sessionControllerProvider).store?.id;
  if (storeId == null) return;
  final sale = await showDialog<SaleRecord>(
    context: context,
    builder: (_) => _FindInvoiceDialog(storeId: storeId),
  );
  if (sale != null && context.mounted) await showProcessReturnDialog(context, ref, sale);
}

class _FindInvoiceDialog extends ConsumerStatefulWidget {
  const _FindInvoiceDialog({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_FindInvoiceDialog> createState() => _FindInvoiceDialogState();
}

class _FindInvoiceDialogState extends ConsumerState<_FindInvoiceDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final sale = await ref.read(posRepositoryProvider).findSaleByNumber(widget.storeId, _controller.text);
      if (!mounted) return;
      if (sale == null) {
        setState(() => _error = l10n.returnNotFound);
      } else {
        Navigator.of(context).pop(sale);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.returnFailed);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.returnInvoice),
      content: SizedBox(
        width: 380,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.returnInvoiceNumber,
            hintText: l10n.returnInvoiceNumberHint,
            errorText: _error,
            prefixIcon: const Icon(Icons.receipt_long_outlined),
          ),
          onSubmitted: (_) => _find(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton.icon(
          onPressed: _searching ? null : _find,
          icon: _searching
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.search),
          label: Text(l10n.returnFind),
        ),
      ],
    );
  }
}

/// The invoice with what can still be returned. Stock, sales, profit, the
/// customer's debt and loyalty points are all adjusted by the return itself
/// (see ProcessSaleReturnUseCase / the process_sale_return RPC).
Future<void> showProcessReturnDialog(BuildContext context, WidgetRef ref, SaleRecord sale) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.employee == null || session.store == null) return;

  if (!sale.canReturn) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(sale.hasReturns ? l10n.returnNothingLeft : l10n.returnNotReturnable)));
    return;
  }

  final products = await ref.read(inventoryRepositoryProvider).watchProducts(session.store!.id).first;
  final namesById = {for (final p in products) p.id: p.name};
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final refunded = await showDialog<int>(
    context: context,
    builder: (_) => _ReturnDialog(sale: sale, namesById: namesById, processedByUserId: session.employee!.id),
  );
  if (refunded != null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.returnDone(Money.format(refunded)))));
  }
}

class _ReturnDialog extends ConsumerStatefulWidget {
  const _ReturnDialog({required this.sale, required this.namesById, required this.processedByUserId});

  final SaleRecord sale;
  final Map<String, String> namesById;
  final String processedByUserId;

  @override
  ConsumerState<_ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends ConsumerState<_ReturnDialog> {
  late final Map<String, int> _quantities = {for (final line in widget.sale.lines) line.id: 0};
  late bool _refundToCash = widget.sale.paymentMethod == SalePaymentMethod.cash || widget.sale.paymentMethod == null;
  bool _saving = false;
  String? _error;

  int get _refund => widget.sale.lines.fold(0, (s, l) => s + l.unitRefundMinorUnits * (_quantities[l.id] ?? 0));

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(processSaleReturnUseCaseProvider).processReturn(
            originalSale: widget.sale,
            processedByUserId: widget.processedByUserId,
            refundToCash: _refundToCash,
            returnLines: widget.sale.lines
                .map((line) => ReturnLineInput(saleLine: line, quantityReturned: _quantities[line.id] ?? 0))
                .toList(),
          );
      if (mounted) Navigator.of(context).pop(_refund);
    } on SaleNotSyncedException {
      if (mounted) setState(() => _error = l10n.returnWaitSync);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.returnFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sale = widget.sale;
    final nothingChosen = _quantities.values.every((q) => q == 0);

    return AlertDialog(
      title: Text('${l10n.posProcessReturn}: ${sale.saleNumber}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                [
                  AppDateFormat.dateTime(sale.completedAt ?? sale.createdAt),
                  paymentMethodLabel(l10n, sale.paymentMethod),
                  '${l10n.commonTotal}: ${Money.format(sale.grandTotalMinorUnits)}',
                ].where((s) => s.isNotEmpty).join(' · '),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.returnWhatHappens, style: theme.textTheme.bodySmall),
              const Divider(height: 24),
              ...sale.lines.map((line) {
                final selected = _quantities[line.id] ?? 0;
                final left = line.remainingQuantity;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.namesById[line.productId] ?? line.productId, style: theme.textTheme.titleSmall),
                            Text(
                              '${Money.format(line.unitRefundMinorUnits)} · '
                              '${l10n.returnSoldReturned(line.quantity, line.quantityReturned)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: selected > 0 ? () => setState(() => _quantities[line.id] = selected - 1) : null,
                      ),
                      SizedBox(width: 56, child: Text('$selected / $left', textAlign: TextAlign.center)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: selected < left ? () => setState(() => _quantities[line.id] = selected + 1) : null,
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.select_all),
                  label: Text(l10n.returnAll),
                  onPressed: () => setState(() {
                    for (final line in sale.lines) {
                      _quantities[line.id] = line.remainingQuantity;
                    }
                  }),
                ),
              ),
              const Divider(height: 24),
              if (sale.paymentMethod != SalePaymentMethod.payLater) ...[
                Text(l10n.returnRefundTo, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(l10n.posPayCash), icon: const Icon(Icons.payments_outlined)),
                    ButtonSegment(value: false, label: Text(l10n.posPayCard), icon: const Icon(Icons.credit_card)),
                  ],
                  selected: {_refundToCash},
                  onSelectionChanged: (s) => setState(() => _refundToCash = s.first),
                ),
              ] else
                Text(l10n.posReturnReducesBalance),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(l10n.returnRefund, style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    Money.format(_refund),
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: nothingChosen || _saving ? null : _confirm,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}
