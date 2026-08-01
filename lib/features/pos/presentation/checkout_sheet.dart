import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../printing/domain/receipt_template_builder.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/pos_models.dart';
import 'cart_controller.dart';

enum _PayMethod { cash, card, payLater }

/// The checkout flow: choose a payment method, enter tendered cash (with
/// live change calculation) or a pay-later customer name, confirm, then
/// print the receipt on whatever printer this store has configured.
Future<void> showCheckoutSheet(BuildContext context, WidgetRef ref, {required AppSettingsRecord settings}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _CheckoutSheetContent(settings: settings),
  );
}

class _CheckoutSheetContent extends ConsumerStatefulWidget {
  const _CheckoutSheetContent({required this.settings});
  final AppSettingsRecord settings;

  @override
  ConsumerState<_CheckoutSheetContent> createState() => _CheckoutSheetContentState();
}

class _CheckoutSheetContentState extends ConsumerState<_CheckoutSheetContent> {
  _PayMethod _method = _PayMethod.cash;
  final _tenderedController = TextEditingController();
  final _customerNameController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _tenderedController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final cart = ref.read(cartControllerProvider);
    final session = ref.read(sessionControllerProvider);
    if (session.store == null || session.employee == null || session.currentBranchId == null) return;
    if (cart.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      int? tendered;
      int? change;
      if (_method == _PayMethod.cash) {
        tendered = Money.toMinorUnits(double.tryParse(_tenderedController.text) ?? 0);
        if (tendered < cart.grandTotalMinorUnits) {
          setState(() => _error = l10n.errorRequired);
          return;
        }
        change = tendered - cart.grandTotalMinorUnits;
      }

      final paymentMethod = switch (_method) {
        _PayMethod.cash => SalePaymentMethod.cash,
        _PayMethod.card => SalePaymentMethod.card,
        _PayMethod.payLater => SalePaymentMethod.payLater,
      };

      final result = await ref.read(completeSaleUseCaseProvider).checkout(
            storeId: session.store!.id,
            branchId: session.currentBranchId!,
            cashierId: session.employee!.id,
            paymentMethod: paymentMethod,
            lines: cart.lines.map((l) => l.toSaleLineInput()).toList(),
            amountTenderedMinorUnits: tendered,
            changeGivenMinorUnits: change,
            customerNameForPayLater: _method == _PayMethod.payLater ? _customerNameController.text : null,
            resumingHeldSale: cart.resumingHeldSale,
          );

      ref.read(cartControllerProvider.notifier).clear();

      if (context.mounted) {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.posSaleCompleted)));
      }

      await _printReceipt(result.sale, session);
    } catch (_) {
      setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _printReceipt(SaleRecord sale, SessionState session) async {
    if (widget.settings.printerConfig.driverType == 'none') return;
    try {
      final productNames = <String, String>{
        for (final l in sale.lines) l.productId: l.productId,
      };
      final doc = ReceiptTemplateBuilder.build(
        sale: sale,
        productNamesById: productNames,
        storeName: session.store?.displayName ?? '',
        branchName: '',
        cashierName: session.employee?.name ?? '',
        currencySymbol: widget.settings.currencySymbol,
      );
      final printer = buildPrinterService(
        widget.settings.printerConfig.driverType,
        paperWidthMm: widget.settings.printerConfig.paperWidthMm,
      );
      final address = widget.settings.printerConfig.connectionAddress;
      if (address != null && address.isNotEmpty) {
        await printer.connect(address);
      }
      await printer.printReceipt(doc);
      await printer.disconnect();
    } catch (_) {
      // Printing failures shouldn't block the sale — it's already saved.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartControllerProvider);
    final tendered = Money.toMinorUnits(double.tryParse(_tenderedController.text) ?? 0);
    final change = tendered - cart.grandTotalMinorUnits;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.posCheckout, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            Money.format(cart.grandTotalMinorUnits, currencySymbol: widget.settings.currencySymbol),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          SegmentedButton<_PayMethod>(
            segments: [
              ButtonSegment(value: _PayMethod.cash, label: Text(l10n.posPayCash), icon: const Icon(Icons.payments_outlined)),
              ButtonSegment(value: _PayMethod.card, label: Text(l10n.posPayCard), icon: const Icon(Icons.credit_card)),
              ButtonSegment(value: _PayMethod.payLater, label: Text(l10n.posPayLater), icon: const Icon(Icons.schedule)),
            ],
            selected: {_method},
            onSelectionChanged: (s) => setState(() => _method = s.first),
          ),
          const SizedBox(height: 16),
          if (_method == _PayMethod.cash) ...[
            TextField(
              controller: _tenderedController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: InputDecoration(labelText: l10n.posAmountTendered, errorText: _error),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.posChangeDue}: ${Money.format(change > 0 ? change : 0, currencySymbol: widget.settings.currencySymbol)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else if (_method == _PayMethod.payLater)
            TextField(
              controller: _customerNameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.posCustomerName, errorText: _error),
            )
          else if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _confirm,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.posCompleteSale),
          ),
        ],
      ),
    );
  }
}
