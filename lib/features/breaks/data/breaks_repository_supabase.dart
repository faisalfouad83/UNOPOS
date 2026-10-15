import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/offline_pins.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/utils/id_generator.dart';

import '../domain/break_models.dart';
import '../domain/breaks_repository.dart';

class SupabaseBreaksRepository implements BreaksRepository {
  SupabaseBreaksRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

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
    // Works offline: the break starts here at once (its length from the
    // store's settings on this device) and is recorded on the server —
    // which still applies its limits — when the connection is back.
    final opId = IdGenerator.newId();
    final settings = await OfflineCache.readRows('app_settings.$storeId');
    final allowed = (settings?.firstOrNull?['break_max_minutes'] as num?)?.toInt() ?? 15;
    final preview = {
      'id': Outbox.ref(opId),
      'store_id': storeId,
      'branch_id': branchId,
      'user_id': userId,
      'shift_id': shiftId,
      'started_at': DateTime.now().toUtc().toIso8601String(),
      'ended_at': null,
      'allowed_minutes': allowed,
      'end_kind': null,
      'exceeded_minutes': 0,
    };
    try {
      final row = await _writer.rpc(
        'start_break',
        {'p_user_id': userId, 'p_branch_id': branchId, 'p_shift_id': shiftId},
        offline: () => preview,
        opId: opId,
        previewTable: 'employee_breaks',
        preview: preview,
      );
      final started = (row as Map).cast<String, dynamic>();
      _keep(started);
      return _map(started);
    } on PostgrestException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<EmployeeBreakRecord> endBreak({required String breakId, required String pin, bool reconciled = false}) async {
    // A break started offline is known by a reference to the server's id
    // until that arrives; once it has, the server's id is used.
    final given = breakId;
    breakId = _writer.resolve(given) as String;
    var current = await _breakById(breakId);
    final startOp = Outbox.refOp(given);
    if (current == null && startOp != null) {
      // Sent since, and not looked up online yet: the server returned it.
      final row = _writer.resolve(Outbox.ref(startOp, '.'));
      if (row is Map) current = row.cast<String, dynamic>();
    }
    if (!_writer.sendsNow) {
      // Offline: the PIN is checked against this device's copy of it (the
      // server checks it again when the change is sent).
      if (current == null || !await OfflinePins.matches(current['user_id'] as String, pin)) {
        throw const BreakException(wrongPin: true);
      }
    }
    final now = DateTime.now();
    final ended = current == null
        ? null
        : {
            ...current,
            'ended_at': now.toUtc().toIso8601String(),
            'end_kind': reconciled ? 'reconciled' : 'returned',
            'exceeded_minutes': _exceeded(current, now),
          };
    try {
      final row = await _writer.rpc(
        'end_break',
        {'p_break_id': breakId, 'p_pin': pin, 'p_reconciled': reconciled},
        offline: () => ended,
        increments: [
          if (ended != null)
            {
              'table': 'employee_breaks',
              'id': breakId,
              'set': {'ended_at': ended['ended_at'], 'end_kind': ended['end_kind']},
            },
        ],
      );
      if (row == null) throw const BreakException(refusal: BreakRefusal.off);
      return _map((row as Map).cast<String, dynamic>());
    } on PostgrestException catch (e) {
      _rethrow(e);
    }
  }

  static int _exceeded(Map<String, dynamic> row, DateTime now) {
    final started = DateTime.parse(row['started_at'] as String);
    final allowed = (row['allowed_minutes'] as num).toInt();
    final over = now.difference(started).inMinutes - allowed;
    return over > 0 ? over : 0;
  }

  Future<Map<String, dynamic>?> _breakById(String breakId) async {
    final rows = await fetchRowsOrCached(
      'break.$breakId',
      () async => breakId.startsWith('@@')
          ? <Map<String, dynamic>>[]
          : (await _client.from('employee_breaks').select().eq('id', breakId)).cast<Map<String, dynamic>>(),
      table: 'employee_breaks',
      where: (r) => r['id'] == breakId,
    );
    return rows?.firstOrNull;
  }

  @override
  Future<EmployeeBreakRecord?> openBreakFor(String storeId, String userId) async {
    final rows = await fetchRowsOrCached(
      'open_break.$storeId.$userId',
      () async => (await _client
              .from('employee_breaks')
              .select()
              .eq('store_id', storeId)
              .eq('user_id', userId)
              .isFilter('ended_at', null)
              .order('started_at', ascending: false)
              .limit(1))
          .cast<Map<String, dynamic>>(),
      table: 'employee_breaks',
      where: (r) => r['store_id'] == storeId && r['user_id'] == userId && r['ended_at'] == null,
    );
    if (rows == null || rows.isEmpty) return null;
    _keep(rows.first);
    return _map(rows.first);
  }

  /// Keeps a copy of [row] by its id, so the break can be ended offline.
  static void _keep(Map<String, dynamic> row) {
    final id = row['id'];
    if (id is String && Outbox.refOp(id) == null) OfflineCache.write('break.$id', [row]);
  }

  @override
  Future<List<EmployeeBreakRecord>> breaksBetween(String storeId, DateTime from, DateTime to) async {
    final rows = await fetchRowsOrCached(
      'breaks.$storeId.${from.toIso8601String()}.${to.toIso8601String()}',
      () async => (await _client
              .from('employee_breaks')
              .select()
              .eq('store_id', storeId)
              .gte('started_at', from.toUtc().toIso8601String())
              .lt('started_at', to.toUtc().toIso8601String())
              .order('started_at', ascending: false))
          .cast<Map<String, dynamic>>(),
      table: 'employee_breaks',
      where: (r) {
        final at = DateTime.parse(r['started_at'] as String);
        return r['store_id'] == storeId && !at.isBefore(from) && at.isBefore(to);
      },
    );
    return (rows ?? const []).map(_map).toList();
  }
}
