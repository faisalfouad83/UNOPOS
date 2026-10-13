import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/break_models.dart';
import '../domain/breaks_repository.dart';

class SupabaseBreaksRepository implements BreaksRepository {
  SupabaseBreaksRepository(this._client);

  final SupabaseClient _client;

  EmployeeBreakRecord _map(Map<String, dynamic> row) => EmployeeBreakRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String?,
        userId: row['user_id'] as String,
        shiftId: row['shift_id'] as String?,
        startedAt: DateTime.parse(row['started_at'] as String).toLocal(),
        endedAt: row['ended_at'] == null ? null : DateTime.parse(row['ended_at'] as String).toLocal(),
        allowedMinutes: (row['allowed_minutes'] as num).toInt(),
        endKind: BreakEndKind.fromName(row['end_kind'] as String?),
        exceededMinutes: (row['exceeded_minutes'] as num?)?.toInt() ?? 0,
      );

  Never _rethrow(PostgrestException e) {
    final m = e.message;
    if (m.contains('wrong PIN')) throw const BreakException(wrongPin: true);
    if (m.contains('breaks are off')) throw const BreakException(refusal: BreakRefusal.off);
    if (m.contains('not allowed for this role')) throw const BreakException(refusal: BreakRefusal.roleNotAllowed);
    if (m.contains('already on a break')) throw const BreakException(refusal: BreakRefusal.alreadyOnBreak);
    if (m.contains('no breaks left')) throw const BreakException(refusal: BreakRefusal.noneLeftToday);
    throw e;
  }

  @override
  Future<EmployeeBreakRecord> startBreak({
    required String storeId,
    required String userId,
    String? branchId,
    String? shiftId,
  }) async {
    try {
      final row = await _client.rpc('start_break', params: {
        'p_user_id': userId,
        'p_branch_id': branchId,
        'p_shift_id': shiftId,
      });
      return _map(row as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<EmployeeBreakRecord> endBreak({required String breakId, required String pin, bool reconciled = false}) async {
    try {
      final row = await _client.rpc('end_break', params: {
        'p_break_id': breakId,
        'p_pin': pin,
        'p_reconciled': reconciled,
      });
      return _map(row as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<EmployeeBreakRecord?> openBreakFor(String storeId, String userId) async {
    final row = await _client
        .from('employee_breaks')
        .select()
        .eq('store_id', storeId)
        .eq('user_id', userId)
        .isFilter('ended_at', null)
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : _map(row);
  }

  @override
  Future<List<EmployeeBreakRecord>> breaksBetween(String storeId, DateTime from, DateTime to) async {
    final rows = await _client
        .from('employee_breaks')
        .select()
        .eq('store_id', storeId)
        .gte('started_at', from.toUtc().toIso8601String())
        .lt('started_at', to.toUtc().toIso8601String())
        .order('started_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>().map(_map).toList();
  }
}
