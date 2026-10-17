import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/adaptive_row.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/accounting_models.dart';
import 'account_labels.dart';
import 'accounting_shared.dart';

/// Every journal entry in the period, filtered by cause, account or words;
/// tapping one shows its lines and where it came from.
class JournalTab extends ConsumerStatefulWidget {
  const JournalTab({super.key});

  @override
  ConsumerState<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<JournalTab> {
  JournalReferenceType? _type;
  String? _account;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();
    final period = ref.watch(accountingPeriodProvider);
    final async = ref.watch(periodJournalProvider((storeId, period)));
    final chart = ref.watch(chartOfAccountsProvider(storeId)).valueOrNull ?? const <ChartOfAccountEntry>[];

    final filters = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: AdaptiveRow(
        minRowWidth: 720,
        children: [
          Expanded(
            child: DropdownButtonFormField<JournalReferenceType?>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.acxFilterCause, isDense: true),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.acxAll)),
                for (final t in JournalReferenceType.values)
                  DropdownMenuItem(value: t, child: Text(journalReferenceLabel(l10n, t))),
              ],
              onChanged: (v) => setState(() => _type = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue: _account,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.acxFilterAccount, isDense: true),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.acxAll)),
                for (final a in chart)
                  DropdownMenuItem(
                    value: a.code,
                    child: Text('${a.code} ${accountLabel(l10n, a.code, a.name)}', overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _account = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.acxFilterSearch,
                isDense: true,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        filters,
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorRetry(onRetry: () => refreshAccounting(ref)),
            data: (entries) {
              final shown = entries.where((e) {
                if (_type != null && e.referenceType != _type) return false;
                if (_account != null && !e.lines.any((l) => l.accountCode == _account)) return false;
                if (_search.isNotEmpty) {
                  final text = '${e.memo} ${journalMemoLabel(l10n, e.memo)} ${e.referenceId ?? ''} '
                          '${journalReferenceLabel(l10n, e.referenceType)}'
                      .toLowerCase();
                  if (!text.contains(_search)) return false;
                }
                return true;
              }).toList();
              final reversed = {
                for (final e in entries)
                  if (e.reversalOfEntryId != null) e.reversalOfEntryId!
              };
              return RefreshIndicator(
                onRefresh: () async => refreshAccounting(ref),
                child: shown.isEmpty
                    ? ListView(children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(child: Text(l10n.acxNoEntries, textAlign: TextAlign.center)),
                        ),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: shown.length + (entries.length >= 1000 ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == shown.length) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(l10n.acxShowingFirst(1000), style: Theme.of(context).textTheme.bodySmall),
                            );
                          }
                          final e = shown[i];
                          final total = e.lines.fold<int>(0, (s, l) => s + l.debitMinorUnits);
                          return ListTile(
                            leading: Icon(
                              e.isReversal
                                  ? Icons.undo
                                  : reversed.contains(e.id)
                                      ? Icons.block
                                      : _icon(e.referenceType),
                            ),
                            title: Text(
                              '${journalReferenceLabel(l10n, e.referenceType)} · ${journalMemoLabel(l10n, e.memo)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              [
                                AppDateFormat.dateTime(e.entryDate),
                                if (e.isReversal) l10n.acxReversalEntry,
                                if (reversed.contains(e.id)) l10n.acxWasReversed,
                                if (Outbox.refOp(e.id) != null) l10n.acxNotSentYet,
                              ].join(' · '),
                            ),
                            trailing: Text(Money.format(total)),
                            onTap: () =>
                                showJournalEntryDetails(context, ref, e, alreadyReversed: reversed.contains(e.id)),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

IconData _icon(JournalReferenceType t) => switch (t) {
      JournalReferenceType.sale => Icons.point_of_sale_outlined,
      JournalReferenceType.returnEntry => Icons.assignment_return_outlined,
      JournalReferenceType.expense => Icons.receipt_long_outlined,
      JournalReferenceType.debtPayment => Icons.handshake_outlined,
      JournalReferenceType.purchase => Icons.local_shipping_outlined,
      JournalReferenceType.supplierPayment => Icons.payments_outlined,
      _ => Icons.edit_note_outlined,
    };

/// The section of the app where an entry's source document lives.
String? sourceRoute(JournalReferenceType t) => switch (t) {
      JournalReferenceType.sale || JournalReferenceType.returnEntry => RoutePaths.invoices,
      JournalReferenceType.debtPayment => RoutePaths.debts,
      JournalReferenceType.expense => RoutePaths.expensesCash,
      JournalReferenceType.purchase || JournalReferenceType.supplierPayment => RoutePaths.suppliers,
      _ => null,
    };

/// An entry's lines (account, debit, credit), where it came from, and —
/// for an entry that isn't itself a correction — a way to reverse it.
/// Entries are never edited: a mistake is corrected by a reversing entry.
Future<void> showJournalEntryDetails(
  BuildContext context,
  WidgetRef ref,
  JournalEntryRecord entry, {
  bool alreadyReversed = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _EntryDetails(entry: entry, alreadyReversed: alreadyReversed),
  );
}

class _EntryDetails extends ConsumerWidget {
  const _EntryDetails({required this.entry, required this.alreadyReversed});
  final JournalEntryRecord entry;
  final bool alreadyReversed;

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final employee = ref.read(sessionControllerProvider).employee;
    if (employee == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.undo),
        title: Text(l10n.acxReverseTitle),
        content: Text(l10n.acxReverseBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.acxReverse)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(accountingRepositoryProvider).postReversingEntry(
            originalEntryId: entry.id,
            createdByUserId: employee.id,
            memo: 'Reversal',
          );
      navigator.pop();
      refreshAccounting(ref);
      messenger.showSnackBar(SnackBar(content: Text(l10n.acxReversed)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id ?? '';
    final chart = ref.watch(chartOfAccountsProvider(storeId)).valueOrNull ?? const <ChartOfAccountEntry>[];
    final names = {for (final a in chart) a.code: a.name};
    final debit = entry.lines.fold<int>(0, (s, l) => s + l.debitMinorUnits);
    final credit = entry.lines.fold<int>(0, (s, l) => s + l.creditMinorUnits);
    final route = sourceRoute(entry.referenceType);
    final unsent = Outbox.refOp(entry.id) != null;
    final canReverse = !entry.isReversal && !alreadyReversed && !unsent;

    Widget line(String account, String d, String c, {bool bold = false}) {
      final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(flex: 5, child: Text(account, style: style)),
            Expanded(flex: 3, child: Text(d, style: style, textAlign: TextAlign.end)),
            Expanded(flex: 3, child: Text(c, style: style, textAlign: TextAlign.end)),
          ],
        ),
      );
    }

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              '${journalReferenceLabel(l10n, entry.referenceType)} · ${journalMemoLabel(l10n, entry.memo)}',
              style: theme.textTheme.titleMedium,
            ),
            Text(AppDateFormat.dateTime(entry.entryDate), style: theme.textTheme.bodySmall),
            if (entry.isReversal) Text(l10n.acxReversalOf, style: theme.textTheme.bodySmall),
            if (alreadyReversed) Text(l10n.acxWasReversed, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
            line(l10n.acxAccount, l10n.acctDebit, l10n.acctCredit, bold: true),
            const Divider(height: 4),
            for (final l in entry.lines)
              line(
                '${l.accountCode} ${accountLabel(l10n, l.accountCode, names[l.accountCode] ?? l.accountCode)}',
                l.debitMinorUnits == 0 ? '' : Money.format(l.debitMinorUnits),
                l.creditMinorUnits == 0 ? '' : Money.format(l.creditMinorUnits),
              ),
            const Divider(height: 4),
            line(l10n.acxTotal, Money.format(debit), Money.format(credit), bold: true),
            const SizedBox(height: 16),
            Text(l10n.acxSourceDocument, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            if (entry.referenceType == JournalReferenceType.sale && entry.referenceId != null)
              _SaleSource(saleId: entry.referenceId!)
            else
              Text(
                entry.referenceId == null
                    ? l10n.acxNoSourceDocument
                    : '${journalReferenceLabel(l10n, entry.referenceType)} · ${entry.referenceId}',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (route != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go(route);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.acxOpenSource),
                  ),
                if (canReverse)
                  FilledButton.tonalIcon(
                    onPressed: () => _reverse(context, ref),
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.acxReverse),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.acxCorrectionsNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// The sale behind a sales entry: its number, total and how it was paid.
class _SaleSource extends ConsumerWidget {
  const _SaleSource({required this.saleId});
  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder(
      future: ref.read(posRepositoryProvider).getSale(saleId).catchError((_) => null),
      builder: (context, snap) {
        final sale = snap.data;
        if (snap.connectionState != ConnectionState.done) return const LinearProgressIndicator();
        if (sale == null) return Text(l10n.acxSaleNotFound(saleId), style: Theme.of(context).textTheme.bodySmall);
        return Text(
          l10n.acxSaleSummary(
            sale.saleNumber,
            Money.format(sale.grandTotalMinorUnits),
            paymentMethodLabel(l10n, sale.paymentMethod),
          ),
        );
      },
    );
  }
}
