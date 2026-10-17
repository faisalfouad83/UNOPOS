import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline/data_refresh.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/providers.dart';
import '../domain/shift_cash_summary.dart';
import '../domain/shifts_models.dart';

typedef ShiftKey = ({String storeId, String cashierId});

final openShiftProvider = FutureProvider.autoDispose.family<ShiftRecord?, ShiftKey>((ref, key) {
  return ref.watch(shiftsRepositoryProvider).getOpenShift(key.storeId, key.cashierId);
});

/// What should be in [shift]'s drawer, refreshed as changes are made on this
/// device and every half minute (for sales sent straight to the server and
/// changes made elsewhere).
final shiftCashSummaryProvider = FutureProvider.autoDispose.family<ShiftCashSummary, ShiftRecord>((ref, shift) {
  final changes = ref.watch(outboxProvider).changes.listen((_) => ref.invalidateSelf());
  final timer = Timer(const Duration(seconds: 30), ref.invalidateSelf);
  ref.onDispose(() {
    changes.cancel();
    timer.cancel();
  });
  ref.watch(dataRefreshEpochProvider);
  return ref.watch(shiftsRepositoryProvider).cashSummary(shift);
});
