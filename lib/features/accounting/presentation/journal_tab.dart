import 'account_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/accounting_models.dart';

final _journalProvider = StreamProvider.autoDispose.family<List<JournalEntryRecord>, String>((ref, storeId) {
  return ref.watch(accountingRepositoryProvider).watchJournalEntries(storeId);
});

class JournalTab extends ConsumerWidget {
  const JournalTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();

    final entriesAsync = ref.watch(_journalProvider(storeId));

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l10n.errorGeneric)),
      data: (entries) {
        if (entries.isEmpty) return Center(child: Text(l10n.accountingJournal));
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final total = entry.lines.fold<int>(0, (s, l) => s + l.debitMinorUnits);
            return ExpansionTile(
              title: Text('${journalReferenceLabel(context.l10n, entry.referenceType)} · ${journalMemoLabel(context.l10n, entry.memo)}'),
              subtitle: Text(AppDateFormat.dateTime(entry.entryDate)),
              trailing: Text(Money.format(total)),
              children: entry.lines
                  .map((line) => ListTile(
                        dense: true,
                        title: Text(line.accountCode),
                        trailing: Text(
                          line.debitMinorUnits > 0
                              ? '${context.l10n.acctDebit} ${Money.format(line.debitMinorUnits)}'
                              : '${context.l10n.acctCredit} ${Money.format(line.creditMinorUnits)}',
                        ),
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
