import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/roles.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../auth/domain/session_controller.dart';
import 'store_reset_dialog.dart';

/// Settings → Factory Reset: resets the store's data, all of it or one part
/// (see [StoreResetDialog]). Shown to the store owner only: the server
/// accepts a reset from the owner alone.
class FactoryResetSection extends ConsumerWidget {
  const FactoryResetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final store = session.store;
    final employee = session.employee;
    if (store == null || employee == null || employee.role != StoreRole.owner) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.settingsFactoryReset, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l10n.storeResetSubtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
              onPressed: () => StoreResetDialog.show(context, storeId: store.id, actorId: employee.id),
              child: Text(l10n.storeResetButton),
            ),
          ],
        ),
      ),
    );
  }
}
