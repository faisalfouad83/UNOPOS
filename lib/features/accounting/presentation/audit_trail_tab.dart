import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../audit/domain/audit_models.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/presentation/tile_picker_screen.dart' show storeEmployeesProvider;
import 'accounting_shared.dart';

final _auditProvider = StreamProvider.autoDispose.family<List<AuditLogRecord>, String>((ref, storeId) {
  return ref.watch(auditRepositoryProvider).watchLog(storeId, limit: 1000);
});

/// Who did what and when (the store's audit log) in the period: price
/// changes, refunds, voids, device releases and other sensitive actions.
class AuditTrailTab extends ConsumerStatefulWidget {
  const AuditTrailTab({super.key});

  @override
  ConsumerState<AuditTrailTab> createState() => _AuditTrailTabState();
}

class _AuditTrailTabState extends ConsumerState<AuditTrailTab> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const SizedBox.shrink();
    final period = ref.watch(accountingPeriodProvider);
    final async = ref.watch(_auditProvider(storeId));
    final employees = ref.watch(storeEmployeesProvider(storeId)).valueOrNull ?? const [];
    final names = {for (final e in employees) e.id: e.name};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
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
              TermInfo(title: l10n.acxAuditTrail, explanation: l10n.acxAuditTrailInfo),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.errorGeneric)),
            data: (logs) {
              final shown = logs.where((l) {
                if (l.timestamp.isBefore(period.from) || !l.timestamp.isBefore(period.to)) return false;
                if (_search.isEmpty) return true;
                return '${l.action} ${l.entityType} ${l.entityId ?? ''} ${names[l.userId] ?? ''}'
                    .toLowerCase()
                    .contains(_search);
              }).toList();
              if (shown.isEmpty) return Center(child: Text(l10n.acxNoAudit));
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: shown.length,
                itemBuilder: (context, i) {
                  final log = shown[i];
                  return ExpansionTile(
                    leading: const Icon(Icons.history),
                    title: Text(log.action, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${AppDateFormat.dateTime(log.timestamp)} · ${names[log.userId] ?? log.userId}'
                      ' · ${log.entityType}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: [
                      if (log.entityId != null) SelectableText('${log.entityType}: ${log.entityId}'),
                      if (log.beforeValueJson != null) SelectableText('${l10n.acxBefore}: ${log.beforeValueJson}'),
                      if (log.afterValueJson != null) SelectableText('${l10n.acxAfter}: ${log.afterValueJson}'),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
