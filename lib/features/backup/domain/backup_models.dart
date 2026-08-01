enum BackupType { manual, automatic }

enum BackupStatus { success, failed }

class BackupLogRecord {
  const BackupLogRecord({
    required this.id,
    required this.storeId,
    required this.filePath,
    this.sizeBytes = 0,
    required this.type,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String filePath;
  final int sizeBytes;
  final BackupType type;
  final BackupStatus status;
  final String? errorMessage;
  final DateTime createdAt;
}
