import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/account_totals.dart';
import '../domain/accounting_models.dart';
import '../domain/financial_statements.dart';

/// The period the accounting sections show (shared by all of them).
final accountingPeriodProvider = StateProvider<AccountingPeriod>(
  (ref) => AccountingPeriod.of(PeriodKind.month, DateTime.now()),
);

/// Totals for the signed-in store over [AccountingPeriod]; balances as at
/// the end of the period (or now, for a period still running).
final accountTotalsProvider = FutureProvider.autoDispose.family<AccountTotals, (String, AccountingPeriod)>((ref, key) {
  final (storeId, period) = key;
  return ref.watch(accountingRepositoryProvider).accountTotals(
        storeId,
        from: period.from,
        to: period.balancesAt(DateTime.now()),
      );
});

/// The store's chart of accounts (names for codes).
final chartOfAccountsProvider = FutureProvider.autoDispose.family<List<ChartOfAccountEntry>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).listAccounts(storeId);
});

/// Journal entries in the period, newest first.
final periodJournalProvider =
    FutureProvider.autoDispose.family<List<JournalEntryRecord>, (String, AccountingPeriod)>((ref, key) {
  final (storeId, period) = key;
  return ref.watch(accountingRepositoryProvider).journalEntriesBetween(storeId, from: period.from, to: period.to);
});

/// Re-reads the period's figures and journal.
void refreshAccounting(WidgetRef ref) {
  ref.invalidate(accountTotalsProvider);
  ref.invalidate(periodJournalProvider);
  ref.invalidate(chartOfAccountsProvider);
}

/// Today / week / month / year / custom, with the dates shown and a
/// refresh button. Scrolls sideways on a narrow phone.
class PeriodBar extends ConsumerWidget {
  const PeriodBar({super.key});

  Future<void> _pickCustom(BuildContext context, WidgetRef ref) async {
    final current = ref.read(accountingPeriodProvider);
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(start: current.from, end: current.lastDay),
    );
    if (range == null) return;
    ref.read(accountingPeriodProvider.notifier).state =
        AccountingPeriod.of(PeriodKind.custom, now, customFrom: range.start, customTo: range.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final period = ref.watch(accountingPeriodProvider);
    // Weeks start on the locale's first day (Saturday for Arabic/Kurdish).
    final firstDay = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
    final firstWeekday = firstDay == 0 ? DateTime.sunday : firstDay;
    String label(PeriodKind k) => switch (k) {
          PeriodKind.today => l10n.acxPeriodToday,
          PeriodKind.week => l10n.acxPeriodWeek,
          PeriodKind.month => l10n.acxPeriodMonth,
          PeriodKind.year => l10n.acxPeriodYear,
          PeriodKind.custom => l10n.acxPeriodCustom,
        };
    final dates = period.from == period.lastDay
        ? AppDateFormat.shortDate(period.from)
        : '${AppDateFormat.shortDate(period.from)} – ${AppDateFormat.shortDate(period.lastDay)}';

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final k in PeriodKind.values)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(label(k)),
                          selected: period.kind == k,
                          onSelected: (_) {
                            if (k == PeriodKind.custom) {
                              _pickCustom(context, ref);
                            } else {
                              ref.read(accountingPeriodProvider.notifier).state =
                                  AccountingPeriod.of(k, DateTime.now(), firstWeekday: firstWeekday);
                            }
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(dates, style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.acxRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => refreshAccounting(ref),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loads the period's totals and builds [builder] with them; shows the
/// "offline estimate" note when they were worked out on this device.
class TotalsView extends ConsumerWidget {
  const TotalsView({super.key, required this.builder});

  final List<Widget> Function(BuildContext context, AccountTotals totals) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();
    final period = ref.watch(accountingPeriodProvider);
    final async = ref.watch(accountTotalsProvider((storeId, period)));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorRetry(onRetry: () => refreshAccounting(ref)),
      data: (totals) => RefreshIndicator(
        onRefresh: () async => refreshAccounting(ref),
        child: SectionList(children: [TotalsSourceNote(totals: totals), ...builder(context, totals)]),
      ),
    );
  }
}

/// A scrolling column of sections, centred and not too wide on a desktop.
class SectionList extends StatelessWidget {
  const SectionList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        for (final c in children)
          Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 980), child: c)),
      ],
    );
  }
}

/// Says when the figures are an offline estimate, and what they leave out.
class TotalsSourceNote extends StatelessWidget {
  const TotalsSourceNote({super.key, required this.totals});
  final AccountTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notes = <String>[
      if (totals.isEstimate) l10n.acxOfflineEstimate(AppDateFormat.dateTime(totals.fetchedAt)),
      if (totals.unsentEntries > 0) l10n.acxUnsentEntriesIncluded(totals.unsentEntries),
      if (totals.unsentSales > 0) l10n.acxUnsentSalesMissing(totals.unsentSales),
    ];
    if (notes.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: totals.isEstimate ? scheme.tertiaryContainer : scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(totals.isEstimate ? Icons.cloud_off_outlined : Icons.sync_problem_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(notes.join('\n'))),
          ],
        ),
      ),
    );
  }
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.errorGeneric),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry)),
        ],
      ),
    );
  }
}

/// A small ⓘ that explains an accounting word in plain language.
class TermInfo extends StatelessWidget {
  const TermInfo({super.key, required this.title, required this.explanation});
  final String title;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      tooltip: explanation,
      icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(explanation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled card, with an optional explanation.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, this.info, required this.children, this.trailing});
  final String title;
  final String? info;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                if (info != null) TermInfo(title: title, explanation: info!),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// "Label ............ amount", wrapping long labels, with optional help.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.bold = false,
    this.info,
    this.indent = false,
    this.negativeIsBad = false,
    this.onTap,
  });

  final String label;
  final int amount;
  final bool bold;
  final String? info;
  final bool indent;

  /// Shows a negative amount in the error colour (a loss).
  final bool negativeIsBad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : null,
      color: negativeIsBad && amount < 0 ? theme.colorScheme.error : null,
    );
    final row = Padding(
      padding: EdgeInsetsDirectional.only(start: indent ? 16 : 0, top: 3, bottom: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null)),
          if (info != null) TermInfo(title: label, explanation: info!),
          const SizedBox(width: 8),
          Text(Money.format(amount), style: style),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// A big figure for the overview: title, amount, a line under it.
class FigureTile extends StatelessWidget {
  const FigureTile({
    super.key,
    required this.title,
    required this.amount,
    required this.info,
    this.subtitle,
    this.icon,
    this.negativeIsBad = false,
  });

  final String title;
  final int amount;
  final String info;
  final String? subtitle;
  final IconData? icon;
  final bool negativeIsBad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon, size: 18, color: theme.colorScheme.primary), const SizedBox(width: 6)],
                Expanded(child: Text(title, style: theme.textTheme.labelLarge, maxLines: 2)),
                TermInfo(title: title, explanation: info),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Money.format(amount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: negativeIsBad && amount < 0 ? theme.colorScheme.error : null,
                ),
              ),
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Lays tiles out in as many columns as fit (1 on a phone, up to 4).
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children, this.minTileWidth = 220});
  final List<Widget> children;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minTileWidth).floor().clamp(1, 4);
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final c in children) SizedBox(width: width, child: c)],
        );
      },
    );
  }
}
