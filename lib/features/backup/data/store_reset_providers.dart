import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline/connectivity.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/providers.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';
import '../domain/store_reset/reset_scope.dart';
import '../domain/store_reset/store_reset_service.dart';
import 'store_reset_drift.dart';
import 'store_reset_supabase.dart';

/// The store reset for store [storeId]: on the server in the shared build,
/// in this device's database in the single-device build.
final storeResetServiceProvider = Provider.family<StoreResetService, String>((ref, storeId) {
  if (!kUseSupabaseBackend) {
    return StoreResetService(backend: DriftStoreResetBackend(ref.watch(databaseProvider), storeId), storeId: storeId);
  }
  return StoreResetService(
    backend: SupabaseStoreResetBackend(ref.watch(supabaseClientProvider), storeId),
    storeId: storeId,
    outbox: ref.watch(outboxProvider),
    isOnline: () => ref.read(connectivityProvider),
    flush: () => ref.read(syncServiceProvider.notifier).syncNow(),
  );
});

/// Makes the screens showing [scopes]' data read it again (their
/// repositories are rebuilt, and everything watching them with them).
void refreshAfterStoreReset(WidgetRef ref, Iterable<ResetScope> scopes) {
  final expanded = ResetPlan.expand(scopes);
  bool has(ResetScope s) => expanded.contains(s);
  if (has(ResetScope.sales) || has(ResetScope.customers)) ref.invalidate(posRepositoryProvider);
  if (has(ResetScope.sales) || has(ResetScope.debts) || has(ResetScope.customers)) {
    ref.invalidate(debtsRepositoryProvider);
  }
  if (expanded.any((s) => s != ResetScope.shifts && s != ResetScope.customers)) {
    ref.invalidate(accountingRepositoryProvider);
  }
  if (has(ResetScope.expenses)) ref.invalidate(expenseDetailsRepositoryProvider);
  if (has(ResetScope.inventory) || has(ResetScope.suppliers)) ref.invalidate(inventoryRepositoryProvider);
  if (has(ResetScope.suppliers)) ref.invalidate(suppliersRepositoryProvider);
  if (has(ResetScope.shifts) || has(ResetScope.sales) || has(ResetScope.expenses)) {
    ref.invalidate(shiftsRepositoryProvider);
  }
  if (has(ResetScope.shifts)) ref.invalidate(breaksRepositoryProvider);
}

/// On opening a store: finishes a reset this device started and didn't see
/// through (the app closed, the reply was lost), and drops this device's
/// queued changes and saved copies for resets made on other devices.
/// Best effort; never holds the app up. True when anything was done.
Future<bool> finishStoreResets(WidgetRef ref, String storeId) async {
  try {
    final service = ref.read(storeResetServiceProvider(storeId));
    final resumed = await service.resumePending();
    final dropped = await service.reconcile();
    if (resumed != null) refreshAfterStoreReset(ref, resumed.scopes);
    return resumed != null || dropped > 0;
  } catch (_) {
    return false;
  }
}
