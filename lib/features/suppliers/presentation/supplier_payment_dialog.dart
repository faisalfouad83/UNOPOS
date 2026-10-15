import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/suppliers_models.dart';

/// Records a payment to [supplier]. True when one was recorded (the
/// caller refreshes the balance it shows).
Future<bool> showSupplierPaymentDialog(
    BuildContext context, WidgetRef ref, SupplierRecord supplier, int balanceOwed) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null || session.currentBranchId == null) return false;

  final controller = TextEditingController(text: Money.toMajorUnits(balanceOwed).toStringAsFixed(2));
  bool isCash = true;
  var saving = false;
  String? error;

  final recorded = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> record() async {
          final amount = Money.toMinorUnits(double.tryParse(controller.text.trim()) ?? 0);
          if (amount <= 0) {
            setState(() => error = l10n.invAmountInvalid);
            return;
          }
          setState(() {
            saving = true;
            error = null;
          });
          try {
            final txId = await ref.read(suppliersRepositoryProvider).recordTransaction(
                  storeId: session.store!.id,
                  supplierId: supplier.id,
                  type: SupplierTransactionType.payment,
                  amountMinorUnits: amount,
                  createdByUserId: session.employee!.id,
                );
            // The payment itself is saved: from here on a failure must not
            // let it be recorded a second time.
            try {
              final journalEntry = await ref.read(accountingPostingServiceProvider).postSupplierPayment(
                    storeId: session.store!.id,
                    branchId: session.currentBranchId!,
                    supplierTransactionId: txId,
                    createdByUserId: session.employee!.id,
                    amountMinorUnits: amount,
                    isCash: isCash,
                  );
              await ref.read(suppliersRepositoryProvider).attachJournalEntry(txId, journalEntry.id);
              await ref.read(auditRepositoryProvider).log(
                    storeId: session.store!.id,
                    userId: session.employee!.id,
                    action: 'supplier_payment_recorded',
                    entityType: 'supplier',
                    entityId: supplier.id,
                    afterValueJson: '$amount',
                  );
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invPaymentNotPosted)));
              }
            }
            if (context.mounted) Navigator.of(context).pop(true);
          } catch (_) {
            if (!context.mounted) return;
            setState(() {
              saving = false;
              error = l10n.errorGeneric;
            });
          }
        }

        return AlertDialog(
          title: Text('${l10n.suppliersRecordPayment}: ${supplier.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${l10n.suppliersBalanceOwed}: ${Money.format(balanceOwed)}'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  enabled: !saving,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  decoration: InputDecoration(labelText: l10n.commonAmount, errorText: error, errorMaxLines: 2),
                  onChanged: (_) => setState(() => error = null),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(l10n.posPayCash)),
                    ButtonSegment(value: false, label: Text(l10n.posPayCard)),
                  ],
                  selected: {isCash},
                  onSelectionChanged: saving ? null : (s) => setState(() => isCash = s.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: saving ? null : record,
              child: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.actionConfirm),
            ),
          ],
        );
      },
    ),
  );
  controller.dispose();
  return recorded ?? false;
}
