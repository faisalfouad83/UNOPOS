import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/audit_models.dart';
import '../domain/audit_repository.dart';

class DriftAuditRepository implements AuditRepository {
  DriftAuditRepository(this._db);

  final AppDatabase _db;

  AuditLogRecord _mapRow(AuditLog row) => AuditLogRecord(
        id: row.id,
        storeId: row.storeId,
        userId: row.userId,
        action: row.action,
        entityType: row.entityType,
        entityId: row.entityId,
        beforeValueJson: row.beforeValueJson,
        afterValueJson: row.afterValueJson,
        timestamp: row.timestamp,
      );

  @override
  Future<void> log({
    required String storeId,
    required String userId,
    required String action,
    required String entityType,
    String? entityId,
    String? beforeValueJson,
    String? afterValueJson,
  }) async {
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion.insert(
            id: IdGenerator.newId(),
            storeId: storeId,
            userId: userId,
            action: action,
            entityType: entityType,
            entityId: Value(entityId),
            beforeValueJson: Value(beforeValueJson),
            afterValueJson: Value(afterValueJson),
            timestamp: DateTime.now(),
          ),
        );
  }

  @override
  Stream<List<AuditLogRecord>> watchLog(String storeId, {int limit = 200}) {
    return (_db.select(_db.auditLogs)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }
}
