import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/backup_service_supabase.dart';
import '../domain/store_reset/reset_scope.dart';
import '../domain/store_reset/store_reset_service.dart';

/// Resets the store's data on the shared server: `store_reset_preview` and
/// `reset_store_data` (migration 0029), called directly — never queued,
/// the reset only happens online.
class SupabaseStoreResetBackend implements StoreResetBackend {
  SupabaseStoreResetBackend(this._client, this._storeId);

  final SupabaseClient _client;
  final String _storeId;
  static const _timeout = Duration(seconds: 60);

  @override
  bool get isServer => true;

  @override
  Future<Map<String, int>> preview(List<ResetScope> scopes) async {
    final json = await _client.rpc('store_reset_preview', params: {
      'p_scopes': [for (final s in scopes) s.wire]
    }).timeout(_timeout);
    final counts = ((json as Map)['counts'] as Map?) ?? const {};
    return {for (final e in counts.entries) '${e.key}': (e.value as num).toInt()};
  }

  @override
  Future<List<Map<String, dynamic>>> rows(String table) => fetchAllStoreRows(_client, table, _storeId);

  @override
  Future<StoreResetResult> apply(String resetId, List<ResetScope> scopes, String actorId) async {
    final json = await _client.rpc('reset_store_data', params: {
      'p_reset_id': resetId,
      'p_scopes': [for (final s in scopes) s.wire],
      'p_actor_id': actorId,
    }).timeout(_timeout);
    return StoreResetResult.fromJson((json as Map).cast<String, dynamic>());
  }

  @override
  Future<StoreResetResult?> status(String resetId) async {
    final row = await _client.from('store_resets').select().eq('id', resetId).maybeSingle().timeout(_timeout);
    return row == null ? null : StoreResetResult.fromJson(row);
  }

  @override
  Future<List<StoreResetResult>> resetsSince(int generation) async {
    final rows = await _client
        .from('store_resets')
        .select('id, generation, scopes, counts, created_at')
        .eq('store_id', _storeId)
        .gt('generation', generation)
        .order('generation')
        .timeout(_timeout);
    return [for (final r in rows) StoreResetResult.fromJson(r)];
  }
}
