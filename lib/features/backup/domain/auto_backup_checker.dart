import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/providers.dart';
import 'backup_models.dart';
import 'backup_service.dart';

/// Runs on app launch/resume and every few minutes while the app is open
/// (see app/app.dart) — not a true OS-level scheduler (Flutter has none for
/// an app that might not be running), so this only fires while the app is
/// open at or after the configured time. Called out in Settings too.
class AutoBackupChecker {
  const AutoBackupChecker(this._ref);
  final WidgetRef _ref;

  /// How many automatic backups to keep; older ones are deleted.
  static const int keepAutomaticBackups = 14;

  Future<void> checkAndRunIfDue(String storeId) async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    var settings = await settingsRepo.ensureSettings(storeId);
    if (!settings.autoBackupEnabled) return;

    final backupService = _ref.read(backupServiceProvider);
    if (await backupService.hasBackupToday(storeId)) return;

    final now = DateTime.now();
    final parts = settings.autoBackupTimeOfDay.split(':');
    final targetHour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 22;
    final targetMinute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
    if (now.isBefore(target)) return;

    var folder = settings.autoBackupFolderPath;
    if (folder == null || folder.isEmpty) {
      // No folder picked yet: use one in the app's documents so automatic
      // backups still happen (and show it in Settings).
      folder = await defaultBackupFolder();
      settings = settings.copyWith(autoBackupFolderPath: folder);
      await settingsRepo.updateSettings(settings);
    }

    final result = await backupService.performBackup(
      storeId: storeId,
      destinationFolderPath: folder,
      type: BackupType.automatic,
    );
    if (result.status == BackupStatus.success) {
      await pruneAutomaticBackups(folder, keep: keepAutomaticBackups);
    }
  }

  static Future<String> defaultBackupFolder() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'UNOPOS Backups'));
    await dir.create(recursive: true);
    return dir.path;
  }
}
