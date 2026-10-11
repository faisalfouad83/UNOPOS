import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../debts/domain/debts_models.dart';
import '../../printing/domain/receipt_models.dart';
import '../../printing/presentation/sale_receipt.dart';
import '../../printing/presentation/whatsapp_receipt_dialog.dart';
import '../../settings/domain/settings_models.dart';
import '../data/offline_sale_sync.dart';
import '../domain/loyalty.dart';
import '../domain/pos_models.dart';
import 'cart_controller.dart';
import 'loyalty_customer_picker.dart';

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
  final _customerPhoneController = TextEditingController();
  bool _submitting = false;
  String? _error;

  /// Cash handed over in the other currency of the IQD/USD pair.
  bool _payInForeign = false;

  ExchangeRate get _rate => ExchangeRate(storeCurrency: Money.currency, iqdPerUsd: widget.settings.usdExchangeRate);

  /// What was typed into the tendered field, in minor units of whichever
  /// currency it was entered in.
  int get _enteredMinor => Money.toMinorUnits(double.tryParse(_tenderedController.text) ?? 0);

  /// The tendered amount in the store's currency.
  int get _tenderedInStoreCurrency => _payInForeign ? _rate.toStore(_enteredMinor) : _enteredMinor;

  String? _phoneForWhatsApp;

  /// Loyalty customer for this sale (null = none chosen).
  CustomerRecord? _loyaltyCustomer;
  final _pointsController = TextEditingController();

  /// Points can't be spent on a resumed held sale: the server re-prices it
  /// from the held lines, which wouldn't carry the points discount.
  bool _canRedeem(CartState cart) =>
      _loyaltyCustomer != null &&
      widget.settings.loyaltyEnabled &&
      widget.settings.loyaltyPointValueMinor > 0 &&
      cart.resumingHeldSale == null;

  int _maxRedeemable(CartState cart) => _canRedeem(cart)
      ? Loyalty.maxRedeemable(
          balance: _loyaltyCustomer!.loyaltyPoints,
          pointValueMinor: widget.settings.loyaltyPointValueMinor,
          payableMinorUnits: cart.grandTotalMinorUnits,
        )
      : 0;

  int _pointsToRedeem(CartState cart) {
    final typed = int.tryParse(_pointsController.text) ?? 0;
    final max = _maxRedeemable(cart);
    return typed < 0 ? 0 : (typed > max ? max : typed);
  }

  /// Cart lines with the points discount spread over them.
  List<CartLine> _saleLines(CartState cart) =>
      Loyalty.applyDiscount(cart.pricedLines, _pointsToRedeem(cart) * widget.settings.loyaltyPointValueMinor);

  int _payable(CartState cart) => _saleLines(cart).fold(0, (s, l) => s + l.lineTotalMinorUnits);

  Future<void> _chooseCustomer() async {
    final storeId = ref.read(sessionControllerProvider).store?.id;
    if (storeId == null) return;
    final picked = await showLoyaltyCustomerPicker(context, ref, storeId, showPoints: widget.settings.loyaltyEnabled);
    if (picked == null || !mounted) return;
    setState(() {
      _loyaltyCustomer = picked;
      _pointsController.clear();
      // Pay-later debts are filed by customer name — keep them on the same customer.
      if (_customerNameController.text.trim().isEmpty) _customerNameController.text = picked.name;
      if (_customerPhoneController.text.trim().isEmpty && (picked.phone?.isNotEmpty ?? false)) {
        _customerPhoneController.text = picked.phone!;
      }
    });
  }

  @override
  void dispose() {
    _tenderedController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _pointsController.dispose();
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

    // Read before the sheet closes — the receipt prints afterwards.
    final inventory = ref.read(inventoryRepositoryProvider);

    final loyaltyCustomer = _loyaltyCustomer;
    final pointsRedeemed = _pointsToRedeem(cart);
    final saleLines = _saleLines(cart);
    final payable = _payable(cart);

    try {
      int? tendered;
      int? change;
      if (_method == _PayMethod.cash) {
        tendered = _tenderedInStoreCurrency;
        if (tendered < payable) {
          setState(() => _error = l10n.errorRequired);
          return;
        }
        change = tendered - payable;
      }

      final foreignPayment = _method == _PayMethod.cash && _payInForeign && _rate.isSet;
      final foreignExtras = <String, dynamic>{
        'paid_currency': _rate.foreign.code,
        'exchange_rate': _rate.iqdPerUsd,
        'foreign_tendered_minor_units': _enteredMinor,
      };
      final receiptExtraRows = foreignPayment
          ? [(l10n.posPaidIn(_rate.foreign.code), '${_rate.foreign.format(_enteredMinor)} · ${_rate.label}')]
          : const <(String, String)>[];

      final paymentMethod = switch (_method) {
        _PayMethod.cash => SalePaymentMethod.cash,
        _PayMethod.card => SalePaymentMethod.card,
        _PayMethod.payLater => SalePaymentMethod.payLater,
      };

      final result = await ref
          .read(completeSaleUseCaseProvider)
          .checkout(
            storeId: session.store!.id,
            branchId: session.currentBranchId!,
            cashierId: session.employee!.id,
            paymentMethod: paymentMethod,
            lines: saleLines.map((l) => l.toSaleLineInput()).toList(),
            amountTenderedMinorUnits: tendered,
            changeGivenMinorUnits: change,
            customerNameForPayLater: _method == _PayMethod.payLater ? _customerNameController.text : null,
            resumingHeldSale: cart.resumingHeldSale,
            extras: {
              if (foreignPayment) ...foreignExtras,
              if (_method == _PayMethod.payLater && _customerPhoneController.text.trim().isNotEmpty)
                'customer_phone': _customerPhoneController.text.trim(),
              if (loyaltyCustomer != null) 'customer_id': loyaltyCustomer.id,
              if (loyaltyCustomer != null && widget.settings.loyaltyEnabled) ...{
                'loyalty_customer_id': loyaltyCustomer.id,
                'points_redeemed': pointsRedeemed,
                // Used by the local (single-device) checkout; the server
                // reads its own setting.
                'loyalty_spend_per_point_minor': widget.settings.loyaltySpendPerPointMinor,
              },
            },
          );

      final loyaltyRows = <(String, String)>[
        if (loyaltyCustomer != null) (l10n.receiptCustomer, loyaltyCustomer.name),
        if (pointsRedeemed > 0)
          (
            l10n.loyaltyPointsRedeemed,
            '-$pointsRedeemed (${Money.format(pointsRedeemed * widget.settings.loyaltyPointValueMinor)})',
          ),
        if ((result.loyaltyPointsEarned ?? 0) > 0) (l10n.loyaltyPointsEarned, '+${result.loyaltyPointsEarned}'),
        if (result.loyaltyBalance != null) (l10n.loyaltyBalance, '${result.loyaltyBalance}'),
      ];

      ref.read(cartControllerProvider.notifier).clear();
      if (result.queuedOffline) ref.read(offlineSaleSyncProvider.notifier).refresh();

      _phoneForWhatsApp = _customerPhoneController.text.trim().isEmpty ? null : _customerPhoneController.text.trim();
      if (!context.mounted) return;
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      navigator.pop();

      final receipt = await buildSaleReceipt(
        inventory: inventory,
        session: session,
        sale: result.sale,
        settings: widget.settings,
        l10n: l10n,
        extraRows: [...receiptExtraRows, ...loyaltyRows],
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.queuedOffline ? l10n.offlineSaleSaved : l10n.posSaleCompleted),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'WhatsApp',
            onPressed: () => showWhatsAppReceiptDialog(
              messenger.context,
              receipt,
              initialPhone: loyaltyCustomer?.phone ?? _phoneForWhatsApp,
            ),
          ),
        ),
      );

      await _printReceipt(receipt);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _printReceipt(ReceiptDocument receipt) async {
    if (widget.settings.printerConfig.driverType == 'none') return;
    try {
      await printReceiptDocument(receipt, widget.settings);
    } catch (_) {
      // Printing failures shouldn't block the sale — it's already saved.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartControllerProvider);
    final rate = _rate;
    final tendered = _tenderedInStoreCurrency;
    final payable = _payable(cart);
    final change = tendered - payable;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.posCheckout, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            Money.format(payable, currencySymbol: widget.settings.currencySymbol),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (payable != cart.grandTotalMinorUnits)
            Text(
              Money.format(cart.grandTotalMinorUnits, currencySymbol: widget.settings.currencySymbol),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough),
            ),
          if (rate.isSet)
            Text(
              '≈ ${rate.foreign.format(rate.toForeign(payable))}  ·  ${rate.label}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_loyaltyCustomer == null ? Icons.person_outline : Icons.person),
              title: Text(_loyaltyCustomer?.name ?? l10n.customerWalkIn),
              subtitle: _loyaltyCustomer == null || !widget.settings.loyaltyEnabled
                  ? null
                  : Text(l10n.loyaltyPointsBalance(_loyaltyCustomer!.loyaltyPoints)),
              trailing: _loyaltyCustomer == null
                  ? TextButton(onPressed: _chooseCustomer, child: Text(l10n.loyaltyChooseCustomer))
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _loyaltyCustomer = null;
                        _pointsController.clear();
                      }),
                    ),
            ),
            if (_maxRedeemable(cart) > 0)
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.loyaltyUsePoints(_maxRedeemable(cart)),
                  helperText: _pointsToRedeem(cart) > 0
                      ? '-${Money.format(_pointsToRedeem(cart) * widget.settings.loyaltyPointValueMinor)}'
                      : l10n.loyaltyPointWorth(Money.format(widget.settings.loyaltyPointValueMinor)),
                ),
                onChanged: (_) => setState(() {}),
              ),
          ],
          const SizedBox(height: 16),
          SegmentedButton<_PayMethod>(
            segments: [
              ButtonSegment(
                value: _PayMethod.cash,
                label: Text(l10n.posPayCash),
                icon: const Icon(Icons.payments_outlined),
              ),
              ButtonSegment(value: _PayMethod.card, label: Text(l10n.posPayCard), icon: const Icon(Icons.credit_card)),
              ButtonSegment(
                value: _PayMethod.payLater,
                label: Text(l10n.posPayLater),
                icon: const Icon(Icons.schedule),
              ),
            ],
            selected: {_method},
            onSelectionChanged: (s) => setState(() => _method = s.first),
          ),
          const SizedBox(height: 16),
          if (_method == _PayMethod.cash) ...[
            if (rate.isSet) ...[
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(Money.currency.code)),
                  ButtonSegment(value: true, label: Text(rate.foreign.code)),
                ],
                selected: {_payInForeign},
                onSelectionChanged: (s) => setState(() {
                  _payInForeign = s.first;
                  _tenderedController.clear();
                }),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _tenderedController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: InputDecoration(
                labelText: l10n.posAmountTendered,
                suffixText: _payInForeign ? rate.foreign.code : Money.currency.code,
                helperText: _payInForeign && _enteredMinor > 0 ? '= ${Money.format(tendered)}' : null,
                errorText: _error,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.posChangeDue}: ${Money.format(change > 0 ? change : 0, currencySymbol: widget.settings.currencySymbol)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else if (_method == _PayMethod.payLater) ...[
            TextField(
              controller: _customerNameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.posCustomerName, errorText: _error),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.posCustomerPhone,
                helperText: l10n.posCustomerPhoneHint,
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
          ] else if (_error != null)
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
