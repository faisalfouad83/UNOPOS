import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';

import '../domain/shift_cash_summary.dart';
import '../domain/shifts_models.dart';
import '../domain/shifts_repository.dart';

class SupabaseShiftsRepository implements ShiftsRepository {
  SupabaseShiftsRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

  ShiftRecord _mapRow(Map<String, dynamic> row) => ShiftRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        cashierId: row['cashier_id'] as String,
        openedAt: DateTime.parse(row['opened_at'] as String).toLocal(),
        closedAt: row['closed_at'] == null ? null : DateTime.parse(row['closed_at'] as String).toLocal(),
        openingCashFloatMinorUnits: (row['opening_cash_float_minor_units'] as num).toInt(),
        expectedCashAtCloseMinorUnits: (row['expected_cash_at_close_minor_units'] as num?)?.toInt(),
        countedCashAtCloseMinorUnits: (row['counted_cash_at_close_minor_units'] as num?)?.toInt(),
        discrepancyMinorUnits: (row['discrepancy_minor_units'] as num?)?.toInt(),
        status: row['status'] == 'closed' ? ShiftStatus.closed : ShiftStatus.open,
      );

  @override
  Future<ShiftRecord> openShift({
    required String storeId,
    required String branchId,
    required String cashierId,
    required int openingCashFloatMinorUnits,
  }) async {
    // Works offline too: the shift is opened on this device and sent later.
    final row = await _writer.insert('shifts', {
      'store_id': storeId,
      'branch_id': branchId,
      'cashier_id': cashierId,
      'opening_cash_float_minor_units': openingCashFloatMinorUnits,
      'opened_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'open',
    });
    return _mapRow(row);
  }

  @override
  Future<ShiftRecord?> getOpenShift(String storeId, String cashierId) async {
    // Offline: the shift this device last saw open, with any shift opened
    // or closed here since.
    final rows = await fetchRowsOrCached(
      'open_shift.$storeId.$cashierId',
      () async => (await _client
              .from('shifts')
              .select()
              .eq('store_id', storeId)
              .eq('cashier_id', cashierId)
              .eq('status', 'open'))
          .cast<Map<String, dynamic>>(),
      table: 'shifts',
      where: (r) => r['store_id'] == storeId && r['cashier_id'] == cashierId && r['status'] == 'open',
    );
    return (rows == null || rows.isEmpty) ? null : _mapRow(rows.first);
  }

  @override
  Future<void> closeShift({
    required String shiftId,
    required int expectedCashAtCloseMinorUnits,
    required int countedCashAtCloseMinorUnits,
  }) async {
    await _writer.update(
        'shifts',
        {
          'status': 'closed',
          'closed_at': DateTime.now().toUtc().toIso8601String(),
          'expected_cash_at_close_minor_units': expectedCashAtCloseMinorUnits,
          'counted_cash_at_close_minor_units': countedCashAtCloseMinorUnits,
          'discrepancy_minor_units': countedCashAtCloseMinorUnits - expectedCashAtCloseMinorUnits,
        },
        value: shiftId);
  }

  @override
  Future<ShiftCashSummary> cashSummary(ShiftRecord shift) async {
    final key = 'shift_cash.${shift.id}';
    ShiftCashSummary? summary;
    var complete = true;
    if (!OfflineCache.knownOffline) {
      try {
        final json = await _client
            .rpc('shift_cash_summary', params: {'p_shift_id': shift.id}).timeout(const Duration(seconds: 8));
        summary = ShiftCashSummary.fromJson((json as Map).cast<String, dynamic>());
        await OfflineCache.write(key, summary.toJson());
      } on PostgrestException catch (e) {
        // Opened on this device and not sent yet: everything about it is
        // still here.
        if (!e.message.contains('shift not found')) rethrow;
        summary = ShiftCashSummary(openingMinorUnits: shift.openingCashFloatMinorUnits);
      } catch (e) {
        if (!isNetworkError(e) && e is! TimeoutException) rethrow;
      }
    }
    if (summary == null) {
      final cached = await OfflineCache.read(key);
      summary = cached is Map
          ? ShiftCashSummary.fromJson(cached.cast<String, dynamic>())
          : ShiftCashSummary(openingMinorUnits: shift.openingCashFloatMinorUnits);
      complete = false;
    }
    // What this device hasn't sent yet isn't on the server: added on top.
    return summary.withQueued(Outbox.shared.pending, shift).copyWith(complete: complete);
  }

  @override
  Stream<List<ShiftRecord>> watchShiftHistory(String storeId, {String? branchId}) {
    // .stream() only supports one server-side filter — RLS already scopes
    // rows to this store, so that slot goes to branch_id (when given)
    // instead; storeId itself needs no filtering here.
    return resilientRows(
      'shifts.$storeId.${branchId ?? 'all'}',
      () => (branchId == null
              ? _client.from('shifts').stream(primaryKey: ['id'])
              : _client.from('shifts').stream(primaryKey: ['id']).eq('branch_id', branchId))
          .order('opened_at', ascending: false),
      table: 'shifts',
      where: (r) => branchId == null || r['branch_id'] == branchId,
    ).map((rows) => rows.map(_mapRow).toList());
  }
}
