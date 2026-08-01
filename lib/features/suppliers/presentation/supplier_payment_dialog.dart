import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/suppliers_models.dart';

Future<void> showSupplierPaymentDialog(BuildContext context, WidgetRef ref, SupplierRecord supplier, int balanceOwed) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null || session.currentBranchId == null) return;

  final controller = TextEditingController(text: Money.toMajorUnits(balanceOwed).toStringAsFixed(2));
  bool isCash = true;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${l10n.suppliersRecordPayment}: ${supplier.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${l10n.suppliersBalanceOwed}: ${Money.format(balanceOwed, currencySymbol: r'$')}'),
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

              final txId = await ref.read(suppliersRepositoryProvider).recordTransaction(
                    storeId: session.store!.id,
                    supplierId: supplier.id,
                    type: SupplierTransactionType.payment,
                    amountMinorUnits: amount,
                    createdByUserId: session.employee!.id,
                  );
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

              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    ),
  );
}
