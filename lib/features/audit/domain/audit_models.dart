class AuditLogRecord {
  const AuditLogRecord({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.beforeValueJson,
    this.afterValueJson,
    required this.timestamp,
  });

  final String id;
  final String storeId;
  final String userId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? beforeValueJson;
  final String? afterValueJson;
  final DateTime timestamp;
}
