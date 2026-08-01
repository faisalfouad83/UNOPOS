import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/shifts_models.dart';

typedef ShiftKey = ({String storeId, String cashierId});

final openShiftProvider = FutureProvider.autoDispose.family<ShiftRecord?, ShiftKey>((ref, key) {
  return ref.watch(shiftsRepositoryProvider).getOpenShift(key.storeId, key.cashierId);
});
