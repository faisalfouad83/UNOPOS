import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/debts_models.dart';

Future<void> showRecordDebtPaymentDialog(BuildContext context, WidgetRef ref, DebtLedgerEntryRecord entry) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null) return;

  final controller = TextEditingController(
    text: Money.toMajorUnits(entry.balanceRemainingMinorUnits).toStringAsFixed(2),
  );
  bool isCash = true;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.debtsRecordPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${l10n.debtsBalanceOwed}: ${Money.format(entry.balanceRemainingMinorUnits, currencySymbol: r'$')}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: InputDecoration(labelText: l10n.commonAmount),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.posPayCash)),
                ButtonSegment(value: false, label: Text(l10n.posPayCard)),
              ],
              selected: {isCash},
              onSelectionChanged: (s) => setState(() => isCash = s.first),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              final amount = Money.toMinorUnits(double.tryParse(controller.text) ?? 0);
              if (amount <= 0) return;

              final paymentId = await ref.read(debtsRepositoryProvider).recordPayment(
                    debtLedgerEntryId: entry.id,
                    amountMinorUnits: amount,
                    paymentMethod: isCash ? 'cash' : 'card',
                    receivedByUserId: session.employee!.id,
                  );
              final journalEntry = await ref.read(accountingPostingServiceProvider).postDebtPaymentReceived(
                    storeId: session.store!.id,
                    branchId: entry.branchId,
                    debtPaymentId: paymentId,
                    createdByUserId: session.employee!.id,
                    amountMinorUnits: amount,
                    isCash: isCash,
                  );
              await ref.read(debtsRepositoryProvider).attachJournalEntryToPayment(paymentId, journalEntry.id);
              await ref.read(auditRepositoryProvider).log(
                    storeId: session.store!.id,
                    userId: session.employee!.id,
                    action: 'debt_payment_recorded',
                    entityType: 'debt_ledger_entry',
                    entityId: entry.id,
                    afterValueJson: '$amount',
                  );

              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    ),
  );
}
