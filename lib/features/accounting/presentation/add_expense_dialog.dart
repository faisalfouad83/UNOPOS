import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/expense_categories.dart';
import 'expense_labels.dart';

/// Record an expense: pick its type (fixed / variable / negligible, then the
/// category — or "custom" and type a name), the amount, and cash or card.
/// The amount is posted to the matching expense account automatically.
Future<void> showAddExpenseDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null || session.currentBranchId == null) return;

  var group = ExpenseGroup.fixed;
  ExpenseCategory? category = ExpenseCategory.of(group).first;
  final customController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  var isCash = true;
  String? error;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.accountingAddExpense),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExpenseTypePicker(
                  group: group,
                  category: category,
                  customController: customController,
                  onChanged: (g, c) => setState(() {
                    group = g;
                    category = c;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  decoration: InputDecoration(labelText: l10n.commonAmount, errorText: error),
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
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              final amount = Money.toMinorUnits(double.tryParse(amountController.text) ?? 0);
              final categoryKey = group == ExpenseGroup.custom ? customController.text.trim() : category?.key;
              if (amount <= 0 || categoryKey == null || categoryKey.isEmpty) {
                setState(() => error = l10n.errorRequired);
                return;
              }
              final typeLabel = expenseCategoryLabel(l10n, group, categoryKey);
              final entry = await ref.read(accountingPostingServiceProvider).postExpense(
                    storeId: session.store!.id,
                    branchId: session.currentBranchId!,
                    expenseAccountCode: category?.accountCode ?? SystemAccountCodes.miscExpense,
                    createdByUserId: session.employee!.id,
                    amountMinorUnits: amount,
                    isCash: isCash,
                    memo: memoController.text.trim().isEmpty ? typeLabel : '$typeLabel — ${memoController.text.trim()}',
                  );
              await ref.read(expenseDetailsRepositoryProvider).save(ExpenseDetailRecord(
                    journalEntryId: entry.id,
                    storeId: session.store!.id,
                    group: group,
                    category: categoryKey,
                    amountMinorUnits: amount,
                    entryDate: entry.entryDate,
                  ));
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}

/// Change the type of an expense already recorded.
Future<void> showEditExpenseTypeDialog(BuildContext context, WidgetRef ref, ExpenseDetailRecord detail) async {
  final l10n = AppLocalizations.of(context);
  var group = detail.group;
  ExpenseCategory? category = detail.builtIn;
  final customController = TextEditingController(text: detail.group == ExpenseGroup.custom ? detail.category : '');
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.expenseEditType),
        content: SizedBox(
          width: 440,
          child: ExpenseTypePicker(
            group: group,
            category: category,
            customController: customController,
            onChanged: (g, c) => setState(() {
              group = g;
              category = c;
            }),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              final key = group == ExpenseGroup.custom ? customController.text.trim() : category?.key;
              if (key == null || key.isEmpty) return;
              await ref.read(expenseDetailsRepositoryProvider).updateType(detail.journalEntryId, group, key);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}

/// Group selector, then the group's categories (or a text field for custom).
class ExpenseTypePicker extends StatelessWidget {
  const ExpenseTypePicker({
    super.key,
    required this.group,
    required this.category,
    required this.customController,
    required this.onChanged,
  });

  final ExpenseGroup group;
  final ExpenseCategory? category;
  final TextEditingController customController;
  final void Function(ExpenseGroup group, ExpenseCategory? category) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.expenseType, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in ExpenseGroup.values)
              ChoiceChip(
                label: Text(expenseGroupLabel(l10n, g)),
                selected: g == group,
                onSelected: (_) => onChanged(g, g == ExpenseGroup.custom ? null : ExpenseCategory.of(g).first),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (group == ExpenseGroup.custom)
          TextField(
            controller: customController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.expenseCustomName),
          )
        else
          DropdownButtonFormField<ExpenseCategory>(
            key: ValueKey(group),
            initialValue: category,
            decoration: InputDecoration(labelText: l10n.expenseCategory),
            items: [
              for (final c in ExpenseCategory.of(group))
                DropdownMenuItem(value: c, child: Text(expenseCategoryLabel(l10n, c.group, c.key))),
            ],
            onChanged: (c) => onChanged(group, c),
          ),
      ],
    );
  }
}
