import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import 'backup_models.dart';

/// Runs on app launch/resume (see app/app.dart) — not a true OS-level
/// scheduler (Flutter has none for a desktop/mobile app that might not be
/// running), so this only fires while the app is actually open around the
/// configured time. That limitation is called out in Settings too.
class AutoBackupChecker {
  const AutoBackupChecker(this._ref);
  final WidgetRef _ref;

  Future<void> checkAndRunIfDue(String storeId) async {
    final settings = await _ref.read(settingsRepositoryProvider).ensureSettings(storeId);
    if (!settings.autoBackupEnabled) return;
    if (settings.autoBackupFolderPath == null || settings.autoBackupFolderPath!.isEmpty) return;

    final backupService = _ref.read(backupServiceProvider);
    if (await backupService.hasBackupToday(storeId)) return;

    final now = DateTime.now();
    final parts = settings.autoBackupTimeOfDay.split(':');
    final targetHour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 22;
    final targetMinute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
    if (now.isBefore(target)) return;

    await backupService.performBackup(
      storeId: storeId,
      destinationFolderPath: settings.autoBackupFolderPath!,
      type: BackupType.automatic,
    );
  }
}
