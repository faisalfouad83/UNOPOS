import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/formatters.dart';
import '../../backup/domain/backup_models.dart';
import '../domain/settings_models.dart';

final _backupHistoryProvider = StreamProvider.autoDispose.family<List<BackupLogRecord>, String>((ref, storeId) {
  return ref.watch(backupRepositoryProvider).watchBackupHistory(storeId);
});

class BackupSettingsSection extends ConsumerWidget {
  const BackupSettingsSection({super.key, required this.storeId, required this.settings});
  final String storeId;
  final AppSettingsRecord settings;

  Future<void> _pickFolder(WidgetRef ref) async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    await ref.read(settingsRepositoryProvider).updateSettings(settings.copyWith(autoBackupFolderPath: path));
  }

  Future<void> _backupNow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    var folder = settings.autoBackupFolderPath;
    folder ??= await FilePicker.platform.getDirectoryPath();
    if (folder == null) return;
    if (settings.autoBackupFolderPath == null) {
      await ref.read(settingsRepositoryProvider).updateSettings(settings.copyWith(autoBackupFolderPath: folder));
    }
    final result = await ref.read(backupServiceProvider).performBackup(
          storeId: storeId,
          destinationFolderPath: folder,
          type: BackupType.manual,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.status == BackupStatus.success ? l10n.settingsBackupNow : l10n.errorGeneric)),
      );
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [kUseSupabaseBackend ? 'json' : 'zip']);
    final path = result?.files.single.path;
    if (path == null) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).settingsRestore),
        content: const Text('This will replace all current data with the backup. The app must be restarted afterwards. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(AppLocalizations.of(context).actionCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(AppLocalizations.of(context).actionConfirm)),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(backupServiceProvider).restoreFromBackup(path);
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Restore complete'),
          content: const Text('Please close and reopen UNOPOS now to load the restored data.'),
          actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(_backupHistoryProvider(storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsBackup, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(settings.autoBackupFolderPath ?? 'No backup folder chosen', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(onPressed: () => _pickFolder(ref), child: const Text('Choose folder')),
                FilledButton(onPressed: () => _backupNow(context, ref), child: Text(l10n.settingsBackupNow)),
                OutlinedButton(onPressed: () => _restore(context, ref), child: Text(l10n.settingsRestore)),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsAutoBackup),
              subtitle: Text('Runs once the app is open past ${settings.autoBackupTimeOfDay} each day'),
              value: settings.autoBackupEnabled,
              onChanged: (v) => ref.read(settingsRepositoryProvider).updateSettings(settings.copyWith(autoBackupEnabled: v)),
            ),
            if (settings.autoBackupEnabled)
              TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (picked == null) return;
                  final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  await ref.read(settingsRepositoryProvider).updateSettings(settings.copyWith(autoBackupTimeOfDay: formatted));
                },
                child: Text('Backup time: ${settings.autoBackupTimeOfDay}'),
              ),
            const SizedBox(height: 8),
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (history) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history.take(5).map((h) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      h.status == BackupStatus.success ? Icons.check_circle_outline : Icons.error_outline,
                      color: h.status == BackupStatus.success ? Colors.green : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(AppDateFormat.dateTime(h.createdAt)),
                    subtitle: Text(h.type.name),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
