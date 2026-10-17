import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_config.dart';
import 'store_themes.dart';
import 'theme_resolution.dart';

/// A store's own theme choice as the developer sees it.
class StoreThemeChoiceRow {
  const StoreThemeChoiceRow({required this.storeId, this.themeKey, this.themeMode});
  final String storeId;
  final String? themeKey;
  final String? themeMode;

  /// The same fallback as AppSettingsRecord.themeChoice.
  String? get choice => themeKey ?? (themeMode == 'light' || themeMode == 'dark' ? themeMode : null);
}

/// The developer's theme assignments (`theme_assignments`). The server's
/// row-level security lets a store read only the global row and its own,
/// and only developer admins write.
class ThemeAssignmentRepository {
  ThemeAssignmentRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'theme_assignments';

  static List<ThemeAssignment> _map(List<Map<String, dynamic>> rows) =>
      rows.map(ThemeAssignment.fromRow).whereType<ThemeAssignment>().toList();

  /// Live global and store assignments for [storeId] (realtime).
  Stream<List<ThemeAssignment>> watchForStore(String storeId) => _client
      .from(_table)
      .stream(primaryKey: ['scope']).inFilter('scope', [ThemeAssignment.globalScope, storeId]).map(_map);

  /// The global and store assignments for [storeId], read once.
  Future<List<ThemeAssignment>> fetchForStore(String storeId) async {
    final rows = await _client.from(_table).select().inFilter('scope', [ThemeAssignment.globalScope, storeId]);
    return _map(rows.cast<Map<String, dynamic>>());
  }

  /// Every assignment (developer console).
  Stream<List<ThemeAssignment>> watchAll() => _client.from(_table).stream(primaryKey: ['scope']).map(_map);

  /// Every store's own choice from its settings (developer console).
  Future<List<StoreThemeChoiceRow>> fetchStoreChoices() async {
    final rows = await _client.from('app_settings').select('store_id, theme_key, theme_mode');
    return rows
        .cast<Map<String, dynamic>>()
        .map((r) => StoreThemeChoiceRow(
              storeId: r['store_id'] as String,
              themeKey: r['theme_key'] as String?,
              themeMode: r['theme_mode'] as String?,
            ))
        .toList();
  }

  /// Sets the theme for every store ([ThemeAssignment.globalScope]) or one
  /// store (its id). The server stamps who changed it and when.
  Future<void> setAssignment({required String scope, required StoreThemeKey key, required bool locked}) async {
    await _client.from(_table).upsert({
      'scope': scope,
      'store_id': scope == ThemeAssignment.globalScope ? null : scope,
      'theme_key': key.dbKey,
      'locked': locked,
    }, onConflict: 'scope');
    await _audit('theme_assignment_set', scope, {'theme_key': key.dbKey, 'locked': locked});
  }

  /// Removes the assignment for [scope]; the store then follows its own
  /// choice, the global assignment, or Light.
  Future<void> clearAssignment(String scope) async {
    await _client.from(_table).delete().eq('scope', scope);
    await _audit('theme_assignment_cleared', scope, null);
  }

  Future<void> _audit(String action, String scope, Map<String, dynamic>? details) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      final admin = await _client.from('developer_admins').select('id').eq('auth_user_id', userId).maybeSingle();
      await _client.from('platform_audit_logs').insert({
        'admin_id': admin?['id'],
        'action': action,
        'target_store_id': scope == ThemeAssignment.globalScope ? null : scope,
        'details_json': details == null ? null : jsonEncode(details),
      });
    } catch (_) {
      // The change itself went through; a missing audit line must not undo
      // it or show as a failure.
    }
  }
}

/// Null on the local (Drift) build: there is no developer there.
final themeAssignmentRepositoryProvider = Provider<ThemeAssignmentRepository?>((ref) {
  if (!kUseSupabaseBackend) return null;
  return ThemeAssignmentRepository(ref.watch(supabaseClientProvider));
});
