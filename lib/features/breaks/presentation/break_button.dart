import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/store_settings_provider.dart';
import '../../auth/domain/session_controller.dart';
import '../../shifts/presentation/shift_providers.dart';
import '../domain/break_models.dart';
import 'break_providers.dart';

String breakRefusalMessage(AppLocalizations l10n, BreakRefusal? r, int maxPerDay) => switch (r) {
      BreakRefusal.off => l10n.breakOff,
      BreakRefusal.roleNotAllowed => l10n.breakRoleNotAllowed,
      BreakRefusal.alreadyOnBreak => l10n.breakAlreadyOn,
      BreakRefusal.noneLeftToday => l10n.breakNoneLeft(maxPerDay),
      null => l10n.errorGeneric,
    };

/// "Break" in the top bar, for accounts whose role may take breaks (when
/// breaks are switched on). Starts the break after a confirmation; the till
/// then locks until the same employee returns with their PIN.
class BreakButton extends ConsumerWidget {
  const BreakButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(currentStoreSettingsProvider).valueOrNull;
    final session = ref.watch(sessionControllerProvider);
    final employee = session.employee;
    if (settings == null || employee == null || !settings.breakEnabled) return const SizedBox.shrink();
    if (!settings.breakRoleNames.contains(employee.role.name)) return const SizedBox.shrink();

    return IconButton(
      tooltip: l10n.breakStart,
      icon: const Icon(Icons.free_breakfast_outlined),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.free_breakfast_outlined),
            title: Text(l10n.breakStart),
            content: Text(l10n.breakStartConfirm(settings.breakMaxMinutes, settings.breakMaxPerDay)),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
              FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.breakStart)),
            ],
          ),
        );
        if (ok != true) return;
        try {
          final shift = await ref.read(openShiftProvider((storeId: employee.storeId, cashierId: employee.id)).future);
          final started = await ref.read(breaksRepositoryProvider).startBreak(
                storeId: employee.storeId,
                userId: employee.id,
                branchId: session.currentBranchId,
                shiftId: shift?.id,
              );
          ref.read(activeBreakProvider.notifier).state = started;
        } on BreakException catch (e) {
          messenger
              .showSnackBar(SnackBar(content: Text(breakRefusalMessage(l10n, e.refusal, settings.breakMaxPerDay))));
        } catch (_) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
        }
      },
    );
  }
}
