import 'backup_models.dart';

abstract class BackupRepository {
  Future<BackupLogRecord> logBackup({
    required String storeId,
    required String filePath,
    required int sizeBytes,
    required BackupType type,
    required BackupStatus status,
    String? errorMessage,
  });

  Stream<List<BackupLogRecord>> watchBackupHistory(String storeId);

  Future<BackupLogRecord?> mostRecentSuccessfulBackup(String storeId, {required bool onlyToday});
}
