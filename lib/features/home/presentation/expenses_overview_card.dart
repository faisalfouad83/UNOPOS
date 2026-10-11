import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../accounting/domain/expense_categories.dart';
import '../../accounting/presentation/expense_labels.dart';
import '../../../core/utils/formatters.dart';

final _yearExpensesProvider = StreamProvider.autoDispose.family<List<ExpenseDetailRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  return ref.watch(expenseDetailsRepositoryProvider).watch(storeId, from: DateTime(now.year));
});

/// Home-screen summary of spending this month or this year: the total, how
/// it splits across fixed / variable / negligible / custom, and the biggest
/// categories.
class ExpensesOverviewCard extends ConsumerStatefulWidget {
  const ExpensesOverviewCard({super.key, required this.storeId});
  final String storeId;

  @override
  ConsumerState<ExpensesOverviewCard> createState() => _ExpensesOverviewCardState();
}

class _ExpensesOverviewCardState extends ConsumerState<ExpensesOverviewCard> {
  bool _year = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final all = ref.watch(_yearExpensesProvider(widget.storeId)).value ?? const <ExpenseDetailRecord>[];
    final from = _year ? DateTime(now.year) : DateTime(now.year, now.month);
    final breakdown = ExpenseBreakdown(all.where((d) => !d.entryDate.isBefore(from)));

    final groupRows = [
      for (final g in ExpenseGroup.values)
        if ((breakdown.byGroup[g] ?? 0) > 0) (expenseGroupLabel(l10n, g), breakdown.byGroup[g]!),
    ];
    final categoryRows = (breakdown.byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) => (
              '${expenseCategoryLabel(l10n, e.key.$1, e.key.$2)} · ${expenseGroupLabel(l10n, e.key.$1)}',
              e.value,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_year ? l10n.expensesThisYear : l10n.expensesThisMonth, style: theme.textTheme.titleMedium),
                ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.expensesMonth)),
                    ButtonSegment(value: true, label: Text(l10n.expensesYear)),
                  ],
                  selected: {_year},
                  onSelectionChanged: (s) => setState(() => _year = s.first),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(Money.format(breakdown.total), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (breakdown.total == 0)
              Text(l10n.expensesNone)
            else
              LayoutBuilder(builder: (context, constraints) {
                final groups = _Bars(rows: groupRows, total: breakdown.total);
                final categories = _Bars(rows: categoryRows, total: breakdown.total);
                if (constraints.maxWidth < 640) {
                  return Column(children: [groups, const Divider(height: 24), categories]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: groups), const SizedBox(width: 24), Expanded(child: categories)],
                );
              }),
            const SizedBox(height: 8),
            Text(
              l10n.expensesUntyped,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Labeled horizontal bars: the label and amount (with share of the total)
/// are text, so one color is enough.
class _Bars extends StatelessWidget {
  const _Bars({required this.rows, required this.total});
  final List<(String, int)> rows;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = rows.fold<int>(0, (m, r) => r.$2 > m ? r.$2 : m);
    return Column(
      children: [
        for (final (label, value) in rows)
          Tooltip(
            message: '$label: ${Money.format(value)}',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                      Text('${Money.format(value)} · ${(value * 100 / total).round()}%', style: theme.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : value / max,
                      minHeight: 8,
                      color: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
