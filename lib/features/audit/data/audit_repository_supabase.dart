import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/sync_service.dart';

import '../domain/audit_models.dart';
import '../domain/audit_repository.dart';

class SupabaseAuditRepository implements AuditRepository {
  SupabaseAuditRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

  AuditLogRecord _mapRow(Map<String, dynamic> row) => AuditLogRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        userId: row['user_id'] as String,
        action: row['action'] as String,
        entityType: row['entity_type'] as String,
        entityId: row['entity_id'] as String?,
        beforeValueJson: row['before_value_json'] as String?,
        afterValueJson: row['after_value_json'] as String?,
        timestamp: DateTime.parse(row['timestamp'] as String).toLocal(),
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
    // Kept (and sent later) when offline, like every other change.
    await _writer.insert('audit_logs', {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'store_id': storeId,
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'before_value_json': beforeValueJson,
      'after_value_json': afterValueJson,
    });
  }

  @override
  Stream<List<AuditLogRecord>> watchLog(String storeId, {int limit = 200}) {
    return resilientRows(
      'audit_logs.$storeId',
      () => _client
          .from('audit_logs')
          .stream(primaryKey: ['id'])
          .eq('store_id', storeId)
          .order('timestamp', ascending: false)
          .limit(limit),
      table: 'audit_logs',
      where: (r) => r['store_id'] == storeId,
    ).map((rows) => rows.map(_mapRow).toList());
  }
}
