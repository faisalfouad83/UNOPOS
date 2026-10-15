import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../accounting/domain/accounting_models.dart';
import '../../accounting/domain/expense_categories.dart';
import '../../accounting/presentation/add_expense_dialog.dart';
import '../../accounting/presentation/expense_labels.dart';
import '../../auth/domain/session_controller.dart';
import '../../pos/domain/pos_models.dart';
import '../domain/shifts_models.dart';
import 'close_shift_dialog.dart';
import 'open_shift_dialog.dart';
import 'shift_providers.dart';

final _shiftSalesProvider =
    StreamProvider.autoDispose.family<List<SaleRecord>, ({String storeId, DateTime from})>((ref, key) {
  return ref.watch(posRepositoryProvider).watchCompletedSales(key.storeId, from: key.from);
});

final _shiftExpenseDetailsProvider =
    StreamProvider.autoDispose.family<List<ExpenseDetailRecord>, ({String storeId, DateTime from})>((ref, key) {
  return ref.watch(expenseDetailsRepositoryProvider).watch(key.storeId, from: key.from);
});

final _shiftJournalEntriesProvider =
    StreamProvider.autoDispose.family<List<JournalEntryRecord>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).watchJournalEntries(storeId);
});

/// Combines what were previously three separate, harder-to-find places
/// (shift open/close on the POS screen, expense entry buried in
/// Accounting, no expense log at all) into one screen: current drawer
/// status, cash reconciliation, and a running expense log — matching how a
/// cashier actually thinks about "the till" as one thing.
class ExpensesCashScreen extends ConsumerWidget {
  const ExpensesCashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final store = session.store;
    final employee = session.employee;
    if (store == null || employee == null) return const SizedBox.shrink();

    final shiftAsync = ref.watch(openShiftProvider((storeId: store.id, cashierId: employee.id)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.expensesCashTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The title is in the bar above; here what the screen is for and
            // its actions, wrapping onto a second line on a phone.
            Text(l10n.expensesCashSubtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            shiftAsync.maybeWhen(
              data: (shift) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => showAddExpenseDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.accountingAddExpense),
                  ),
                  if (shift != null)
                    OutlinedButton.icon(
                      onPressed: () => showCloseShiftDialog(context, ref, shift),
                      icon: const Icon(Icons.lock_outline),
                      label: Text(l10n.posShiftClose),
                    ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: shiftAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text(l10n.errorGeneric)),
                data: (shift) {
                  if (shift == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.expensesCashNoOpenShift, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => showOpenShiftDialog(context, ref),
                            child: Text(l10n.posShiftOpen),
                          ),
                        ],
                      ),
                    );
                  }
                  return _ShiftDetail(shift: shift, storeId: store.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftDetail extends ConsumerWidget {
  const _ShiftDetail({required this.shift, required this.storeId});
  final ShiftRecord shift;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final salesAsync = ref.watch(_shiftSalesProvider((storeId: storeId, from: shift.openedAt)));
    final entriesAsync = ref.watch(_shiftJournalEntriesProvider(storeId));
    final detailsById = {
      for (final d in ref.watch(_shiftExpenseDetailsProvider((storeId: storeId, from: shift.openedAt))).value ??
          const <ExpenseDetailRecord>[])
        d.journalEntryId: d,
    };

    final cashSalesTotal = (salesAsync.value ?? const <SaleRecord>[])
        .where((s) => s.shiftId == shift.id && s.paymentMethod == SalePaymentMethod.cash)
        .fold<int>(0, (sum, s) => sum + s.netTotalMinorUnits);

    // A cash expense is a journal entry that credited the Cash account —
    // postExpense() (see add_expense_dialog.dart) always shapes it this
    // way, so this is a reliable filter without needing a dedicated column.
    final shiftExpenseEntries = (entriesAsync.value ?? const <JournalEntryRecord>[])
        .where((e) =>
            e.referenceType == JournalReferenceType.expense &&
            !e.entryDate.isBefore(shift.openedAt) &&
            e.lines.any((l) => l.accountCode == SystemAccountCodes.cash && l.creditMinorUnits > 0))
        .toList()
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    int entryAmount(JournalEntryRecord e) => e.lines.fold<int>(0, (s, l) => s + l.debitMinorUnits);
    final cashExpensesTotal = shiftExpenseEntries.fold<int>(0, (sum, e) => sum + entryAmount(e));
    final expected = shift.openingCashFloatMinorUnits + cashSalesTotal - cashExpensesTotal;

    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            final cards = [
              _StatTile(label: l10n.expensesCashOpeningCash, value: shift.openingCashFloatMinorUnits),
              _StatTile(label: l10n.expensesCashSalesTotal, value: cashSalesTotal, accent: BrandColors.silver),
              _StatTile(label: l10n.expensesCashTotalExpenses, value: -cashExpensesTotal, accent: BrandColors.red),
              _StatTile(label: l10n.expensesCashExpected, value: expected, accent: BrandColors.blue, emphasize: true),
            ];
            if (isWide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in cards) ...[Expanded(child: c), const SizedBox(width: 12)]
                  ]..removeLast(),
                ),
              );
            }
            // Two by two on a phone or a tablet held upright.
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in cards) SizedBox(width: (constraints.maxWidth - 12) / 2, child: c),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(l10n.expensesCashLog, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (shiftExpenseEntries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.expensesCashNoExpenses, style: Theme.of(context).textTheme.bodyMedium),
          )
        else
          ...shiftExpenseEntries.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(e.memo.isEmpty ? l10n.accountingAddExpense : e.memo),
                subtitle: Text([
                  if (detailsById[e.id] != null)
                    '${expenseGroupLabel(l10n, detailsById[e.id]!.group)} · '
                        '${expenseCategoryLabel(l10n, detailsById[e.id]!.group, detailsById[e.id]!.category)}',
                  AppDateFormat.dateTime(e.entryDate),
                ].join('\n')),
                onTap: detailsById[e.id] == null
                    ? null
                    : () => showEditExpenseTypeDialog(context, ref, detailsById[e.id]!),
                trailing: Text(
                  Money.format(entryAmount(e)),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.accent, this.emphasize = false});
  final String label;
  final int value;
  final Color? accent;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.65))),
            const SizedBox(height: 8),
            Text(
              Money.format(value),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: emphasize ? (accent ?? scheme.primary) : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
