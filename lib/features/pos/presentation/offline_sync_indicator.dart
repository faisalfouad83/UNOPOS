import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/supabase/supabase_config.dart';
import '../data/offline_sale_sync.dart';

/// Top-bar badge showing how many sales made offline are still waiting to
/// reach the server; tap to try sending them now. Hidden when none are.
class OfflineSyncIndicator extends ConsumerWidget {
  const OfflineSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kUseSupabaseBackend) return const SizedBox.shrink();
    final state = ref.watch(offlineSaleSyncProvider);
    if (state.pending == 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.error;
    return TextButton.icon(
      onPressed: state.syncing ? null : () => ref.read(offlineSaleSyncProvider.notifier).syncNow(),
      icon: state.syncing
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.cloud_off, size: 18, color: color),
      label: Text(l10n.offlinePendingSales(state.pending), style: TextStyle(color: color)),
    );
  }
}
