import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';

Future<void> showAddExpenseDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null || session.currentBranchId == null) return;

  final accounts = await ref.read(accountingRepositoryProvider).listAccounts(session.store!.id);
  final expenseAccounts = accounts.where((a) => a.type == AccountType.expense.name).toList();
  if (!context.mounted || expenseAccounts.isEmpty) return;

  String selectedCode = expenseAccounts.first.code;
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  bool isCash = true;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.accountingAddExpense),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCode,
                items: expenseAccounts.map((a) => DropdownMenuItem(value: a.code, child: Text(a.name))).toList(),
                onChanged: (v) => setState(() => selectedCode = v ?? selectedCode),
                decoration: const InputDecoration(labelText: 'Expense account'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(labelText: l10n.commonAmount),
              ),
              const SizedBox(height: 12),
              TextField(controller: memoController, decoration: InputDecoration(labelText: l10n.commonNotes)),
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
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              final amount = Money.toMinorUnits(double.tryParse(amountController.text) ?? 0);
              if (amount <= 0) return;
              await ref.read(accountingPostingServiceProvider).postExpense(
                    storeId: session.store!.id,
                    branchId: session.currentBranchId!,
                    expenseAccountCode: selectedCode,
                    createdByUserId: session.employee!.id,
                    amountMinorUnits: amount,
                    isCash: isCash,
                    memo: memoController.text.trim().isEmpty ? 'Expense' : memoController.text.trim(),
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}
