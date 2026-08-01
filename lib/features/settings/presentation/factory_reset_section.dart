import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/database/connection.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/numeric_pin_pad.dart';

class FactoryResetSection extends ConsumerWidget {
  const FactoryResetSection({super.key});

  Future<void> _showResetFlow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsFactoryReset),
        content: Text(l10n.settingsFactoryResetWarning),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionContinue),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    var pin = '';
    final passcodeOk = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l10n.pinPadTitle),
          content: SizedBox(
            width: 320,
            child: NumericPinPad(
              value: pin,
              onChanged: (v) => setState(() => pin = v),
              onSubmit: () => Navigator.of(dialogContext).pop(pin == MagicPasscodes.factoryReset),
            ),
          ),
        ),
      ),
    );
    if (passcodeOk != true || !context.mounted) return;

    await ref.read(databaseProvider).close();
    final dbPath = await resolveDatabaseFilePath();
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Reset complete'),
          content: const Text('All data has been erased. Please close and reopen UNOPOS to start fresh.'),
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(l10n.settingsFactoryReset, style: Theme.of(context).textTheme.titleMedium)),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => _showResetFlow(context, ref),
              child: Text(l10n.settingsFactoryReset),
            ),
          ],
        ),
      ),
    );
  }
}
