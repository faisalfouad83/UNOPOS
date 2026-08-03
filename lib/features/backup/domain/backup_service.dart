import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/connection.dart';
import 'backup_models.dart';
import 'backup_repository.dart';

/// Shared by [BackupService] (local Drift build) and SupabaseBackupService
/// (Supabase build) so `backup_settings_section.dart` can call either
/// without caring which backend it's talking to.
abstract class BackupExportService {
  Future<BackupLogRecord> performBackup({
    required String storeId,
    required String destinationFolderPath,
    required BackupType type,
  });

  Future<void> restoreFromBackup(String backupPath);

  Future<bool> hasBackupToday(String storeId);
}

class BackupService implements BackupExportService {
  BackupService(this._repository);

  final BackupRepository _repository;

  String _timestampSuffix(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }

  /// Copies the live SQLite file into a zip archive inside [destinationFolderPath],
  /// timestamped, and logs the result. Returns the created backup's log record.
  @override
  Future<BackupLogRecord> performBackup({
    required String storeId,
    required String destinationFolderPath,
    required BackupType type,
  }) async {
    try {
      final dbPath = await resolveDatabaseFilePath();
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw StateError('Database file not found at $dbPath');
      }

      final zipPath = p.join(destinationFolderPath, 'unopos_backup_${_timestampSuffix(DateTime.now())}.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      await encoder.addFile(dbFile, 'unopos.sqlite');
      encoder.close();

      final size = await File(zipPath).length();
      return _repository.logBackup(
        storeId: storeId,
        filePath: zipPath,
        sizeBytes: size,
        type: type,
        status: BackupStatus.success,
      );
    } catch (e) {
      return _repository.logBackup(
        storeId: storeId,
        filePath: destinationFolderPath,
        sizeBytes: 0,
        type: type,
        status: BackupStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Extracts [backupZipPath], safety-copies the current live DB alongside
  /// it first, then replaces the live DB file with the restored one. The
  /// app must be restarted afterwards — an open Drift/sqlite3 connection
  /// cannot safely have its underlying file swapped out from under it.
  @override
  Future<void> restoreFromBackup(String backupZipPath) async {
    final dbPath = await resolveDatabaseFilePath();
    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      final safetyPath = '$dbPath.before_restore_${_timestampSuffix(DateTime.now())}.bak';
      await dbFile.copy(safetyPath);
    }

    final bytes = await File(backupZipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final dbEntry = archive.files.firstWhere(
      (f) => f.name == 'unopos.sqlite',
      orElse: () => throw StateError('Backup archive does not contain unopos.sqlite'),
    );

    final restoredFile = File(dbPath);
    await restoredFile.writeAsBytes(dbEntry.content as List<int>, flush: true);
  }

  @override
  Future<bool> hasBackupToday(String storeId) async {
    final recent = await _repository.mostRecentSuccessfulBackup(storeId, onlyToday: true);
    return recent != null;
  }
}
