import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/debts_models.dart';

Future<void> showRecordDebtPaymentDialog(BuildContext context, WidgetRef ref, DebtLedgerEntryRecord entry) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null) return;
  await showDialog<void>(
    context: context,
    builder: (context) => _RecordDebtPaymentDialog(entry: entry),
  );
}

class _RecordDebtPaymentDialog extends ConsumerStatefulWidget {
  const _RecordDebtPaymentDialog({required this.entry});
  final DebtLedgerEntryRecord entry;

  @override
  ConsumerState<_RecordDebtPaymentDialog> createState() => _RecordDebtPaymentDialogState();
}

class _RecordDebtPaymentDialogState extends ConsumerState<_RecordDebtPaymentDialog> {
  late final _controller = TextEditingController(text: Money.inputText(widget.entry.balanceRemainingMinorUnits));
  bool _isCash = true;

  /// Set before the first await, so a second tap can't record the payment twice.
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _record() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    final entry = widget.entry;
    final amount = Money.toMinorUnits(double.tryParse(_controller.text) ?? 0);
    if (amount <= 0) {
      setState(() => _error = l10n.errorQuantityInvalid);
      return;
    }
    if (amount > entry.balanceRemainingMinorUnits) {
      setState(() => _error = l10n.debtsPayMoreThanOwed(Money.format(entry.balanceRemainingMinorUnits)));
      return;
    }
    final session = ref.read(sessionControllerProvider);
    final debts = ref.read(debtsRepositoryProvider);
    final posting = ref.read(accountingPostingServiceProvider);
    final audit = ref.read(auditRepositoryProvider);
    final isCash = _isCash;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final paymentId = await debts.recordPayment(
        debtLedgerEntryId: entry.id,
        amountMinorUnits: amount,
        paymentMethod: isCash ? 'cash' : 'card',
        receivedByUserId: session.employee!.id,
      );
      final journalEntry = await posting.postDebtPaymentReceived(
        storeId: session.store!.id,
        branchId: entry.branchId,
        debtPaymentId: paymentId,
        createdByUserId: session.employee!.id,
        amountMinorUnits: amount,
        isCash: isCash,
      );
      await debts.attachJournalEntryToPayment(paymentId, journalEntry.id);
      await audit.log(
        storeId: session.store!.id,
        userId: session.employee!.id,
        action: 'debt_payment_recorded',
        entityType: 'debt_ledger_entry',
        entityId: entry.id,
        afterValueJson: '$amount',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = '$e'.contains('more than what is owed')
            ? l10n.debtsPayMoreThanOwed(Money.format(entry.balanceRemainingMinorUnits))
            : l10n.errorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: Text(l10n.debtsRecordPayment),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.debtsBalanceOwed}: ${Money.format(widget.entry.balanceRemainingMinorUnits)}'),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(labelText: l10n.commonAmount, errorText: _error, errorMaxLines: 3),
                onSubmitted: (_) => _record(),
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(l10n.posPayCash)),
                  ButtonSegment(value: false, label: Text(l10n.posPayCard)),
                ],
                selected: {_isCash},
                onSelectionChanged: _submitting ? null : (s) => setState(() => _isCash = s.first),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: _submitting ? null : _record,
            child: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
  }
}
