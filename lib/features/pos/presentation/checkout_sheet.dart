import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../debts/domain/debts_models.dart';
import '../../printing/domain/receipt_models.dart';
import '../../printing/presentation/print_after_sale.dart';
import '../../printing/presentation/sale_receipt.dart';
import '../../printing/presentation/whatsapp_receipt_dialog.dart';
import '../../settings/domain/settings_models.dart';
import '../../shifts/presentation/shift_providers.dart';
import '../data/offline_sale_sync.dart';
import '../domain/complete_sale_use_case.dart';
import '../domain/loyalty.dart';
import '../domain/payment_math.dart';
import '../domain/pos_models.dart';
import 'cart_controller.dart';
import 'loyalty_customer_picker.dart';

enum _PayMethod { cash, card, payLater }

/// What a finished payment hands back to the till.
class _PaidSale {
  const _PaidSale({required this.receipt, required this.queuedOffline, this.whatsAppPhone});
  final ReceiptDocument receipt;
  final bool queuedOffline;
  final String? whatsAppPhone;
}

/// The payment dialog, centred on the window: total, payment method, the
/// amount received with quick amounts, change or what is left to pay, then
/// confirm. Only once the sale is saved does the receipt print (or the
/// cashier get asked), per Settings › Printer.
Future<void> showCheckoutSheet(BuildContext context, WidgetRef ref, {required AppSettingsRecord settings}) async {
  final paid = await showDialog<_PaidSale>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CheckoutDialog(settings: settings),
  );
  if (paid == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text(paid.queuedOffline ? l10n.offlineSaleSaved : l10n.posSaleCompleted),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'WhatsApp',
        onPressed: () => showWhatsAppReceiptDialog(messenger.context, paid.receipt, initialPhone: paid.whatsAppPhone),
      ),
    ),
  );
  await printAfterSale(context, paid.receipt, settings);
}

class _CheckoutDialog extends ConsumerStatefulWidget {
  const _CheckoutDialog({required this.settings});
  final AppSettingsRecord settings;

  @override
  ConsumerState<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<_CheckoutDialog> {
  _PayMethod _method = _PayMethod.cash;
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _pointsController = TextEditingController();
  bool _submitting = false;
  String? _error;

  /// Cash handed over in the other currency of the IQD/USD pair.
  bool _payInForeign = false;

  ExchangeRate get _rate => ExchangeRate(storeCurrency: Money.currency, iqdPerUsd: widget.settings.usdExchangeRate);

  /// What was typed into the amount field, in minor units of whichever
  /// currency it was entered in.
  int get _enteredMinor => Money.toMinorUnits(double.tryParse(_amountController.text) ?? 0);

  /// The amount received in the store's currency.
  int get _receivedInStoreCurrency => _payInForeign ? _rate.toStore(_enteredMinor) : _enteredMinor;

  bool _canRedeem(CartState cart) =>
      cart.customer != null && widget.settings.loyaltyEnabled && widget.settings.loyaltyPointValueMinor > 0;

  int _maxRedeemable(CartState cart) => _canRedeem(cart)
      ? Loyalty.maxRedeemable(
          balance: cart.customer!.loyaltyPoints,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _amountFocus.requestFocus());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _chooseCustomer() async {
    final storeId = ref.read(sessionControllerProvider).store?.id;
    if (storeId == null) return;
    final picked = await showLoyaltyCustomerPicker(context, ref, storeId, showPoints: widget.settings.loyaltyEnabled);
    if (picked == null || !mounted) return;
    ref.read(cartControllerProvider.notifier).setCustomer(picked);
    setState(() {
      _pointsController.clear();
      _error = null;
    });
  }

  void _setAmount(int minorUnits) {
    _amountController.text = Money.inputText(minorUnits);
    _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
    setState(() => _error = null);
    _amountFocus.requestFocus();
  }

  void _clearAmount() {
    _amountController.clear();
    setState(() => _error = null);
    _amountFocus.requestFocus();
  }

  void _selectMethod(_PayMethod method) {
    setState(() {
      _method = method;
      _error = null;
      if (method != _PayMethod.cash) _payInForeign = false;
      _amountController.clear();
    });
    _amountFocus.requestFocus();
  }

  /// Cash received is short: keep what was paid and put the rest on the
  /// customer's account.
  void _restOnAccount() {
    final received = _receivedInStoreCurrency;
    setState(() {
      _method = _PayMethod.payLater;
      _payInForeign = false;
      _amountController.text = received > 0 ? Money.inputText(received) : '';
      _error = null;
    });
  }

  /// Why the sale can't be confirmed yet, or null when it can.
  String? _blocker(AppLocalizations l10n, CartState cart) {
    final payable = _payable(cart);
    switch (_method) {
      case _PayMethod.cash:
        if (_receivedInStoreCurrency < payable) return l10n.payInsufficient;
      case _PayMethod.card:
        break;
      case _PayMethod.payLater:
        if (cart.customer == null && _customerNameController.text.trim().isEmpty) return l10n.payCustomerNeeded;
        if (_enteredMinor >= payable && payable > 0) return l10n.payPaidNowTooMuch;
    }
    return null;
  }

  Future<void> _confirm() async {
    // Set before any await: a second click or Enter can't start a second sale.
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    final cart = ref.read(cartControllerProvider);
    final session = ref.read(sessionControllerProvider);
    if (session.store == null || session.employee == null || session.currentBranchId == null || cart.isEmpty) return;
    final blocker = _blocker(l10n, cart);
    if (blocker != null) {
      setState(() => _error = blocker);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    // Read before the dialog closes — the receipt is built afterwards.
    final inventory = ref.read(inventoryRepositoryProvider);
    final customer = cart.customer;
    final pointsRedeemed = _pointsToRedeem(cart);
    final saleLines = _saleLines(cart);
    final payable = _payable(cart);

    try {
      int? tendered;
      int? change;
      var paidNow = 0;
      switch (_method) {
        case _PayMethod.cash:
          tendered = _receivedInStoreCurrency;
          change = tendered - payable;
        case _PayMethod.card:
          break;
        case _PayMethod.payLater:
          paidNow = _enteredMinor;
      }

      final foreignPayment = _method == _PayMethod.cash && _payInForeign && _rate.isSet;
      final typedName = _customerNameController.text.trim();
      final typedPhone = _customerPhoneController.text.trim();
      // The sale counts towards the cashier's open shift (cash count at close).
      final shift = await ref.read(
        openShiftProvider((storeId: session.store!.id, cashierId: session.employee!.id)).future,
      );

      final result = await ref.read(completeSaleUseCaseProvider).checkout(
        storeId: session.store!.id,
        branchId: session.currentBranchId!,
        cashierId: session.employee!.id,
        shiftId: shift?.id,
        paymentMethod: switch (_method) {
          _PayMethod.cash => SalePaymentMethod.cash,
          _PayMethod.card => SalePaymentMethod.card,
          _PayMethod.payLater => SalePaymentMethod.payLater,
        },
        lines: saleLines.map((l) => l.toSaleLineInput()).toList(),
        amountTenderedMinorUnits: tendered,
        changeGivenMinorUnits: change,
        customerNameForPayLater: _method == _PayMethod.payLater ? (customer?.name ?? typedName) : null,
        resumingHeldSale: cart.resumingHeldSale,
        extras: {
          if (foreignPayment) ...{
            'paid_currency': _rate.foreign.code,
            'exchange_rate': _rate.iqdPerUsd,
            'foreign_tendered_minor_units': _enteredMinor,
          },
          if (_method == _PayMethod.payLater && typedPhone.isNotEmpty) 'customer_phone': typedPhone,
          if (paidNow > 0) 'paid_now_minor_units': paidNow,
          if (customer != null) 'customer_id': customer.id,
          if (customer != null && widget.settings.loyaltyEnabled) ...{
            'loyalty_customer_id': customer.id,
            'points_redeemed': pointsRedeemed,
            // Used by the local (single-device) checkout; the server
            // reads its own setting.
            'loyalty_spend_per_point_minor': widget.settings.loyaltySpendPerPointMinor,
          },
        },
      );

      final extraRows = <(String, String)>[
        if (foreignPayment)
          (l10n.posPaidIn(_rate.foreign.code), '${_rate.foreign.format(_enteredMinor)} · ${_rate.label}'),
        if (_method == _PayMethod.payLater) (l10n.payRemaining, Money.format(payable - paidNow)),
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

      final receipt = await buildSaleReceipt(
        inventory: inventory,
        session: session,
        sale: result.sale,
        settings: widget.settings,
        l10n: l10n,
        customerName: customer?.name ?? (typedName.isEmpty ? null : typedName),
        branch: ref
            .read(storeBranchesProvider(session.store!.id))
            .valueOrNull
            ?.where((b) => b.id == session.currentBranchId)
            .firstOrNull,
        extraRows: extraRows,
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        _PaidSale(
          receipt: receipt,
          queuedOffline: result.queuedOffline,
          whatsAppPhone: customer?.phone ?? (typedPhone.isEmpty ? null : typedPhone),
        ),
      );
    } on HeldSaleClosedException {
      if (mounted) setState(() => _error = l10n.posHeldSaleClosed);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cart = ref.watch(cartControllerProvider);
    final customer = cart.customer;
    final rate = _rate;
    final payable = _payable(cart);
    final blocker = _blocker(l10n, cart);
    final symbol = widget.settings.currencySymbol;

    final paid = switch (_method) {
      _PayMethod.cash => _receivedInStoreCurrency,
      _PayMethod.card => payable,
      _PayMethod.payLater => _enteredMinor,
    };
    final breakdown = PaymentBreakdown(dueMinorUnits: payable, paidMinorUnits: paid);
    final suggestions = paymentSuggestions(
      _payInForeign ? rate.toForeign(payable) : payable,
      currencyCode: _payInForeign ? rate.foreign.code : Money.currency.code,
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _confirm,
        const SingleActivator(LogicalKeyboardKey.f1): () => _selectMethod(_PayMethod.cash),
        const SingleActivator(LogicalKeyboardKey.f2): () => _selectMethod(_PayMethod.card),
        const SingleActivator(LogicalKeyboardKey.f3): () => _selectMethod(_PayMethod.payLater),
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total: always visible, never scrolls away.
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Text(l10n.payAmountDue, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(
                        Money.format(payable, currencySymbol: symbol),
                        style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (payable != cart.grandTotalMinorUnits)
                      Text(
                        Money.format(cart.grandTotalMinorUnits, currencySymbol: symbol),
                        style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    if (rate.isSet)
                      Text(
                        '≈ ${rate.foreign.format(rate.toForeign(payable))}  ·  ${rate.label}',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<_PayMethod>(
                        segments: [
                          ButtonSegment(
                            value: _PayMethod.cash,
                            label: Text(l10n.posPayCash),
                            icon: const Icon(Icons.payments_outlined),
                          ),
                          ButtonSegment(
                            value: _PayMethod.card,
                            label: Text(l10n.posPayCard),
                            icon: const Icon(Icons.credit_card),
                          ),
                          ButtonSegment(
                            value: _PayMethod.payLater,
                            label: Text(l10n.posPayLater),
                            icon: const Icon(Icons.schedule),
                          ),
                        ],
                        selected: {_method},
                        onSelectionChanged: (s) => _selectMethod(s.first),
                      ),
                      const SizedBox(height: 12),
                      // One customer for the whole sale: loyalty points and a
                      // pay-later debt both go to this customer.
                      _CustomerRow(
                        customer: customer,
                        showPoints: widget.settings.loyaltyEnabled,
                        onChoose: _chooseCustomer,
                        onClear: () {
                          ref.read(cartControllerProvider.notifier).setCustomer(null);
                          setState(() => _pointsController.clear());
                        },
                      ),
                      if (_maxRedeemable(cart) > 0) ...[
                        const SizedBox(height: 8),
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
                      if (_method == _PayMethod.payLater && customer == null) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _customerNameController,
                          decoration: InputDecoration(labelText: l10n.posCustomerName),
                          onChanged: (_) => setState(() => _error = null),
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
                      ],
                      const SizedBox(height: 16),
                      if (_method == _PayMethod.card)
                        _SummaryRow(
                          label: l10n.payReceived,
                          value: Money.format(payable, currencySymbol: symbol),
                        )
                      else ...[
                        if (_method == _PayMethod.cash && rate.isSet) ...[
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(value: false, label: Text(Money.currency.code)),
                              ButtonSegment(value: true, label: Text(rate.foreign.code)),
                            ],
                            selected: {_payInForeign},
                            onSelectionChanged: (s) => setState(() {
                              _payInForeign = s.first;
                              _amountController.clear();
                            }),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _amountController,
                          focusNode: _amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                          style: theme.textTheme.headlineSmall,
                          decoration: InputDecoration(
                            labelText: _method == _PayMethod.cash ? l10n.payReceived : l10n.payPaidNow,
                            suffixText: _payInForeign ? rate.foreign.code : Money.currency.code,
                            helperText: _payInForeign && _enteredMinor > 0
                                ? '= ${Money.format(_receivedInStoreCurrency)}'
                                : null,
                            suffixIcon: IconButton(
                              tooltip: l10n.payClear,
                              icon: const Icon(Icons.backspace_outlined),
                              onPressed: _clearAmount,
                            ),
                          ),
                          onChanged: (_) => setState(() => _error = null),
                          onSubmitted: (_) => _confirm(),
                        ),
                        if (_method == _PayMethod.cash) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final (i, amount) in suggestions.indexed)
                                ActionChip(
                                  avatar: i == 0 ? const Icon(Icons.check_circle_outline, size: 18) : null,
                                  label: Text(
                                    i == 0
                                        ? '${l10n.payExact}: ${_payInForeign ? rate.foreign.format(amount) : Money.format(amount)}'
                                        : (_payInForeign ? rate.foreign.format(amount) : Money.format(amount)),
                                  ),
                                  onPressed: () => _setAmount(amount),
                                ),
                            ],
                          ),
                        ],
                      ],
                      const SizedBox(height: 16),
                      if (_method == _PayMethod.cash && breakdown.changeMinorUnits > 0)
                        _SummaryRow(
                          label: l10n.posChangeDue,
                          value: Money.format(breakdown.changeMinorUnits, currencySymbol: symbol),
                          color: Colors.green.shade700,
                          large: true,
                        ),
                      if (_method == _PayMethod.payLater ||
                          (_method == _PayMethod.cash && paid > 0 && breakdown.remainingMinorUnits > 0))
                        _SummaryRow(
                          label: _method == _PayMethod.payLater ? l10n.payOnAccount : l10n.payRemaining,
                          value: Money.format(breakdown.remainingMinorUnits, currencySymbol: symbol),
                          color: theme.colorScheme.error,
                          large: true,
                        ),
                      if (_method == _PayMethod.cash && paid > 0 && breakdown.remainingMinorUnits > 0)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            icon: const Icon(Icons.schedule),
                            label: Text(l10n.payRestOnAccount),
                            onPressed: _restOnAccount,
                          ),
                        ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                        child: Text(l10n.actionCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                        onPressed: _submitting || blocker != null ? null : _confirm,
                        icon: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check),
                        label: Text(l10n.posCompleteSale),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer, required this.showPoints, required this.onChoose, required this.onClear});

  final CustomerRecord? customer;
  final bool showPoints;
  final VoidCallback onChoose;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = customer;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(c == null ? Icons.person_outline : Icons.person),
      title: Text(c?.name ?? l10n.customerWalkIn),
      subtitle: c == null || !showPoints ? null : Text(l10n.loyaltyPointsBalance(c.loyaltyPoints)),
      trailing: c == null
          ? TextButton(onPressed: onChoose, child: Text(l10n.loyaltyChooseCustomer))
          : IconButton(icon: const Icon(Icons.close), tooltip: l10n.actionCancel, onPressed: onClear),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.color, this.large = false});

  final String label;
  final String value;
  final Color? color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = (large ? theme.textTheme.titleLarge : theme.textTheme.titleMedium)?.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
