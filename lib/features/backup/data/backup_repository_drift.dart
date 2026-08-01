import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/backup_models.dart';
import '../domain/backup_repository.dart';

class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository(this._db);

  final AppDatabase _db;

  BackupLogRecord _mapRow(BackupLog row) => BackupLogRecord(
        id: row.id,
        storeId: row.storeId,
        filePath: row.filePath,
        sizeBytes: row.sizeBytes,
        type: BackupType.values.firstWhere((t) => t.name == row.type),
        status: BackupStatus.values.firstWhere((s) => s.name == row.status),
        errorMessage: row.errorMessage,
        createdAt: row.createdAt,
      );

  @override
  Future<BackupLogRecord> logBackup({
    required String storeId,
    required String filePath,
    required int sizeBytes,
    required BackupType type,
    required BackupStatus status,
    String? errorMessage,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _db.into(_db.backupLogs).insert(
          BackupLogsCompanion.insert(
            id: id,
            storeId: storeId,
            filePath: filePath,
            sizeBytes: Value(sizeBytes),
            type: type.name,
            status: status.name,
            errorMessage: Value(errorMessage),
            createdAt: now,
          ),
        );
    return BackupLogRecord(
      id: id,
      storeId: storeId,
      filePath: filePath,
      sizeBytes: sizeBytes,
      type: type,
      status: status,
      errorMessage: errorMessage,
      createdAt: now,
    );
  }

  @override
  Stream<List<BackupLogRecord>> watchBackupHistory(String storeId) {
    return (_db.select(_db.backupLogs)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<BackupLogRecord?> mostRecentSuccessfulBackup(String storeId, {required bool onlyToday}) async {
    final query = _db.select(_db.backupLogs)
      ..where((t) => t.storeId.equals(storeId) & t.status.equals('success'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    if (onlyToday) {
      final now = DateTime.now();
      final isToday = row.createdAt.year == now.year && row.createdAt.month == now.month && row.createdAt.day == now.day;
      if (!isToday) return null;
    }
    return _mapRow(row);
  }
}
