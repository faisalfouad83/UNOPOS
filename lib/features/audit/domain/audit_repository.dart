import 'audit_models.dart';

abstract class AuditRepository {
  Future<void> log({
    required String storeId,
    required String userId,
    required String action,
    required String entityType,
    String? entityId,
    String? beforeValueJson,
    String? afterValueJson,
  });

  Stream<List<AuditLogRecord>> watchLog(String storeId, {int limit = 200});
}
