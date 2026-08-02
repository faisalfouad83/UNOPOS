import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/audit_models.dart';
import '../domain/audit_repository.dart';

class SupabaseAuditRepository implements AuditRepository {
  SupabaseAuditRepository(this._client);

  final SupabaseClient _client;

  AuditLogRecord _mapRow(Map<String, dynamic> row) => AuditLogRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        userId: row['user_id'] as String,
        action: row['action'] as String,
        entityType: row['entity_type'] as String,
        entityId: row['entity_id'] as String?,
        beforeValueJson: row['before_value_json'] as String?,
        afterValueJson: row['after_value_json'] as String?,
        timestamp: DateTime.parse(row['timestamp'] as String),
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
    // id/timestamp left to Postgres defaults (gen_random_uuid()/now()),
    // same precedent as SupabaseAuthRepository.createBranch.
    await _client.from('audit_logs').insert({
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
    return _client
        .from('audit_logs')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .order('timestamp', ascending: false)
        .limit(limit)
        .map((rows) => rows.map(_mapRow).toList());
  }
}
