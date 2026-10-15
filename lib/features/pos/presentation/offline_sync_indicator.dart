import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/offline/connectivity.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/formatters.dart';
import '../domain/complete_sale_use_case.dart';

/// Top-bar status: online or offline, and whether changes made on this
/// device are being sent (syncing), still waiting, or were refused by the
/// server. Tap to check the connection and send now (and to see refused
/// changes, with a retry).
class OfflineSyncIndicator extends ConsumerWidget {
  const OfflineSyncIndicator({super.key, this.compact = false});

  /// Icon only (with the count waiting), for a phone's top bar.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kUseSupabaseBackend) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final online = ref.watch(connectivityProvider);
    final sync = ref.watch(syncServiceProvider);
    if (sync.failed > 0) {
      // A sale made offline that closed a held sale sold elsewhere
      // meanwhile: it is sent again on its own rather than left refused.
      final outbox = ref.read(outboxProvider);
      Future.microtask(() => resendRefusedHeldSaleCheckouts(outbox));
    }

    final (icon, color, text) = sync.syncing
        ? (Icons.sync, scheme.primary, l10n.syncInProgress(sync.pending))
        : !online
            ? (
                Icons.cloud_off,
                scheme.error,
                sync.pending > 0 ? l10n.offlineWithPending(sync.pending) : l10n.statusOffline
              )
            : sync.failed > 0
                ? (Icons.sync_problem, scheme.error, l10n.syncFailedCount(sync.failed))
                : sync.pending > 0
                    ? (Icons.cloud_upload_outlined, Colors.orange.shade800, l10n.offlinePendingSales(sync.pending))
                    : (Icons.cloud_done_outlined, Colors.green.shade700, l10n.statusOnline);

    Future<void> onTap() async {
      if (sync.failed > 0) {
        await _showFailed(context, ref);
        return;
      }
      await ref.read(connectivityProvider.notifier).check();
      await ref.read(syncServiceProvider.notifier).syncNow();
    }

    if (compact) {
      final count = sync.failed > 0 ? sync.failed : sync.pending;
      return IconButton(
        tooltip: text,
        onPressed: sync.syncing ? null : onTap,
        icon: sync.syncing
            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: Icon(icon, color: color),
              ),
      );
    }

    return Tooltip(
      message: online ? l10n.statusOnlineHelp : l10n.statusOfflineHelp,
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: color, visualDensity: VisualDensity.compact),
        onPressed: sync.syncing ? null : onTap,
        icon: sync.syncing
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(icon, size: 18, color: color),
        label: Text(text, style: TextStyle(color: color)),
      ),
    );
  }
}

/// The changes the server refused, with why, and a retry.
Future<void> _showFailed(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final failed = ref.read(outboxProvider).failed;
  final retry = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.syncFailedTitle),
      content: SizedBox(
        width: 520,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(l10n.syncFailedHelp),
            const SizedBox(height: 8),
            for (final op in failed)
              ListTile(
                dense: true,
                leading: const Icon(Icons.error_outline),
                title: Text(_describe(op)),
                subtitle: Text('${AppDateFormat.dateTime(op.createdAt)}\n${op.lastError ?? ''}'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionClose)),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.refresh),
          label: Text(l10n.actionRetry),
        ),
      ],
    ),
  );
  if (retry == true) await ref.read(syncServiceProvider.notifier).retryFailed();
}

String _describe(OutboxOp op) => switch (op.kind) {
      OutboxKind.checkout => 'sale',
      OutboxKind.rpc => op.rpc ?? '',
      OutboxKind.insert => '+ ${op.table}',
      OutboxKind.update => '~ ${op.table}',
    };
