import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/shift_cash_summary.dart';
import '../domain/shifts_models.dart';
import 'shift_providers.dart';
import '../../../core/theming/store_themes.dart';

/// Cash count at the end of a shift: what should be in the drawer
/// ([ShiftCashSummary], worked out fresh), the cash counted, and the
/// difference between them.
Future<void> showCloseShiftDialog(BuildContext context, WidgetRef ref, ShiftRecord shift) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CloseShiftDialog(shift: shift),
  );
}

/// [code]'s currency, for amounts taken in a currency other than the store's.
CurrencyInfo currencyInfoFor(String code) => switch (code.toUpperCase()) {
      'USD' => CurrencyInfo.usd,
      'IQD' => CurrencyInfo.iqd,
      _ => CurrencyInfo(code, code),
    };

class _CloseShiftDialog extends ConsumerStatefulWidget {
  const _CloseShiftDialog({required this.shift});
  final ShiftRecord shift;

  @override
  ConsumerState<_CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends ConsumerState<_CloseShiftDialog> {
  final _counted = TextEditingController();
  ShiftCashSummary? _summary;
  Object? _loadError;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _counted.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      final summary = await ref.read(shiftsRepositoryProvider).cashSummary(widget.shift);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        if (_counted.text.isEmpty) _counted.text = Money.inputText(summary.expectedMinorUnits);
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  int get _countedMinor => Money.toMinorUnits(double.tryParse(_counted.text) ?? 0);

  Future<void> _close() async {
    final summary = _summary;
    if (_submitting || summary == null) return;
    final session = ref.read(sessionControllerProvider);
    final repo = ref.read(shiftsRepositoryProvider);
    final key = (storeId: session.store!.id, cashierId: widget.shift.cashierId);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await repo.closeShift(
        shiftId: widget.shift.id,
        expectedCashAtCloseMinorUnits: summary.expectedMinorUnits,
        countedCashAtCloseMinorUnits: _countedMinor,
      );
      if (!mounted) return;
      ref.invalidate(openShiftProvider(key));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppLocalizations.of(context).errorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = _summary;

    Widget body;
    if (summary == null) {
      body = _loadError == null
          ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.errorGeneric),
                const SizedBox(height: 8),
                TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry)),
              ],
            );
    } else {
      final difference = _countedMinor - summary.expectedMinorUnits;
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShiftCashBreakdown(summary: summary),
          const SizedBox(height: 16),
          TextField(
            controller: _counted,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
            decoration: InputDecoration(labelText: l10n.shiftCountedCash, errorText: _error),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.shiftDifference(Money.format(difference)),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: difference == 0
                  ? StatusColors.of(context).success
                  : difference < 0
                      ? theme.colorScheme.error
                      : StatusColors.of(context).warning,
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: Text(l10n.posShiftClose),
        content: SizedBox(width: 420, child: SingleChildScrollView(child: body)),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: _submitting || summary == null ? null : _close,
            child: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
  }
}

/// The lines that make up a shift's expected cash, one per row, with the
/// total under them.
class ShiftCashBreakdown extends StatelessWidget {
  const ShiftCashBreakdown({super.key, required this.summary});
  final ShiftCashSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget row(String label, int amount, {bool negative = false, bool strong = false}) {
      final style = strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: 12),
            Text(
              negative && amount != 0 ? '- ${Money.format(amount)}' : Money.format(amount),
              style: style?.copyWith(color: negative && amount != 0 ? theme.colorScheme.error : null),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        row(l10n.expensesCashOpeningCash, summary.openingMinorUnits),
        row(l10n.expensesCashSalesTotal, summary.cashSalesMinorUnits),
        if (summary.debtPaymentsMinorUnits != 0) row(l10n.shiftCashDebtPayments, summary.debtPaymentsMinorUnits),
        if (summary.refundsMinorUnits != 0) row(l10n.shiftCashRefunds, summary.refundsMinorUnits, negative: true),
        row(l10n.expensesCashTotalExpenses, summary.expensesMinorUnits, negative: true),
        const Divider(),
        row(l10n.expensesCashExpected, summary.expectedMinorUnits, strong: true),
        for (final f in summary.foreign.entries)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child:
                Text(l10n.shiftCashForeign(currencyInfoFor(f.key).format(f.value)), style: theme.textTheme.bodyMedium),
          ),
        if (!summary.complete)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cloud_off, size: 16, color: StatusColors.of(context).warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l10n.shiftCashOfflineNote,
                      style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.of(context).warning)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
