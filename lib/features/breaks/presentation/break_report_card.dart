import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/presentation/tile_picker_screen.dart';
import '../domain/break_models.dart';

final _todaysBreaksProvider = FutureProvider.autoDispose.family<List<EmployeeBreakRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref.watch(breaksRepositoryProvider).breaksBetween(storeId, start, start.add(const Duration(days: 1)));
});

/// Today's breaks in the daily report: who, when, how long, how many, and
/// whether a break ended early or ran over.
class BreakReportCard extends ConsumerWidget {
  const BreakReportCard({super.key, required this.storeId, this.branchId});
  final String storeId;
  final String? branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(_todaysBreaksProvider(storeId));
    final employees = ref.watch(storeEmployeesProvider(storeId)).valueOrNull ?? const <EmployeeRecord>[];
    final names = {for (final e in employees) e.id: e.name};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.breakReportTitle, style: theme.textTheme.titleMedium)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.actionRefresh,
                  onPressed: () => ref.invalidate(_todaysBreaksProvider(storeId)),
                ),
              ],
            ),
            async.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (all) {
                final breaks = branchId == null ? all : all.where((b) => b.branchId == branchId).toList();
                if (breaks.isEmpty) return Text(l10n.breakNoneToday, style: theme.textTheme.bodySmall);
                final countByUser = <String, int>{};
                for (final b in breaks) {
                  countByUser[b.userId] = (countByUser[b.userId] ?? 0) + 1;
                }
                return Column(
                  children: [
                    for (final b in breaks)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          b.isOpen
                              ? Icons.timelapse
                              : b.exceededMinutes > 0
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                          color: b.exceededMinutes > 0 ? theme.colorScheme.error : null,
                        ),
                        title: Text(
                          '${names[b.userId] ?? '—'} · ${l10n.breakCount(countByUser[b.userId] ?? 0)}',
                        ),
                        subtitle: Text(
                          [
                            '${AppDateFormat.time(b.startedAt)} – ${b.endedAt == null ? l10n.breakStillAway : AppDateFormat.time(b.endedAt!)}',
                            l10n.breakMinutes(b.duration().inMinutes),
                            if (b.endKind == BreakEndKind.early) l10n.breakEndedEarly,
                            if (b.endKind == BreakEndKind.reconciled) l10n.breakReconciled,
                            if (b.exceededMinutes > 0) l10n.breakOverBy(b.exceededMinutes),
                          ].join(' · '),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
