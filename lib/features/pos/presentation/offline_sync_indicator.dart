import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/offline/connectivity.dart';
import '../../../core/supabase/supabase_config.dart';
import '../data/offline_sale_sync.dart';

/// Top-bar status: online or offline, and whether sales made offline are
/// being sent (syncing) or still waiting. Tap to check the connection and
/// send waiting sales now.
class OfflineSyncIndicator extends ConsumerWidget {
  const OfflineSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kUseSupabaseBackend) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final online = ref.watch(connectivityProvider);
    final sync = ref.watch(offlineSaleSyncProvider);

    final (icon, color, text) = sync.syncing
        ? (Icons.sync, scheme.primary, l10n.syncInProgress(sync.pending))
        : !online
            ? (
                Icons.cloud_off,
                scheme.error,
                sync.pending > 0 ? l10n.offlineWithPending(sync.pending) : l10n.statusOffline
              )
            : sync.pending > 0
                ? (Icons.cloud_upload_outlined, Colors.orange.shade800, l10n.offlinePendingSales(sync.pending))
                : (Icons.cloud_done_outlined, Colors.green.shade700, l10n.statusOnline);

    return Tooltip(
      message: online ? l10n.statusOnlineHelp : l10n.statusOfflineHelp,
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: color, visualDensity: VisualDensity.compact),
        onPressed: sync.syncing
            ? null
            : () async {
                await ref.read(connectivityProvider.notifier).check();
                await ref.read(offlineSaleSyncProvider.notifier).syncNow();
              },
        icon: sync.syncing
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(icon, size: 18, color: color),
        label: Text(text, style: TextStyle(color: color)),
      ),
    );
  }
}
