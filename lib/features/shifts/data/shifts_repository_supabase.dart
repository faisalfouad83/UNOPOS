import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/shifts_models.dart';
import '../domain/shifts_repository.dart';

class SupabaseShiftsRepository implements ShiftsRepository {
  SupabaseShiftsRepository(this._client);

  final SupabaseClient _client;

  ShiftRecord _mapRow(Map<String, dynamic> row) => ShiftRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        cashierId: row['cashier_id'] as String,
        openedAt: DateTime.parse(row['opened_at'] as String),
        closedAt: row['closed_at'] == null ? null : DateTime.parse(row['closed_at'] as String),
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
    final row = await _client.from('shifts').insert({
      'store_id': storeId,
      'branch_id': branchId,
      'cashier_id': cashierId,
      'opening_cash_float_minor_units': openingCashFloatMinorUnits,
    }).select().single();
    return _mapRow(row);
  }

  @override
  Future<ShiftRecord?> getOpenShift(String storeId, String cashierId) async {
    final row = await _client
        .from('shifts')
        .select()
        .eq('store_id', storeId)
        .eq('cashier_id', cashierId)
        .eq('status', 'open')
        .maybeSingle();
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> closeShift({
    required String shiftId,
    required int expectedCashAtCloseMinorUnits,
    required int countedCashAtCloseMinorUnits,
  }) async {
    await _client.from('shifts').update({
      'status': 'closed',
      'closed_at': DateTime.now().toIso8601String(),
      'expected_cash_at_close_minor_units': expectedCashAtCloseMinorUnits,
      'counted_cash_at_close_minor_units': countedCashAtCloseMinorUnits,
      'discrepancy_minor_units': countedCashAtCloseMinorUnits - expectedCashAtCloseMinorUnits,
    }).eq('id', shiftId);
  }

  @override
  Stream<List<ShiftRecord>> watchShiftHistory(String storeId, {String? branchId}) {
    // .stream() only supports one server-side filter — RLS already scopes
    // rows to this store, so that slot goes to branch_id (when given)
    // instead; storeId itself needs no filtering here.
    final stream = branchId == null
        ? _client.from('shifts').stream(primaryKey: ['id'])
        : _client.from('shifts').stream(primaryKey: ['id']).eq('branch_id', branchId);
    return stream.order('opened_at', ascending: false).map((rows) => rows.map(_mapRow).toList());
  }
}
