import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/offline/data_refresh.dart';
import '../../../core/utils/formatters.dart';

/// The status bar's refresh button: shows every screen's data again (and,
/// online, sends what is waiting and fetches fresh data). Its tooltip says
/// when it last ran; it shows a spinner while it runs and ignores taps then.
class RefreshDataButton extends ConsumerWidget {
  const RefreshDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dataRefreshProvider);
    final last = state.lastAt;
    return IconButton(
      tooltip: last == null ? l10n.refreshData : l10n.refreshDataLast(AppDateFormat.time(last)),
      onPressed: state.running
          ? null
          : () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              await ref.read(dataRefreshProvider.notifier).refresh();
              messenger
                ?..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(l10n.refreshDataDone), duration: const Duration(seconds: 2)),
                );
            },
      icon: state.running
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.refresh),
    );
  }
}
