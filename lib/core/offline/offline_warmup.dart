import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../supabase/supabase_config.dart';

/// Takes a copy of what the till needs to keep working without internet,
/// every time a store is opened: products, tax rates, discounts, settings,
/// customers, accounts, branches and their stock. Each is kept on the device by its own
/// repository and refreshed live while online. Best effort and in the
/// background — it never holds the app up.
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

Future<void> warmOfflineCopy(ProviderReader read, String storeId) async {
  if (!kUseSupabaseBackend) return;
  Future<void> take(Future<Object?> Function() run) async {
    try {
      await run().timeout(const Duration(seconds: 20));
    } catch (_) {}
  }

  final inventory = read(inventoryRepositoryProvider);
  final auth = read(authRepositoryProvider);
  await Future.wait([
    take(() => liveValue(inventory.watchProducts(storeId))),
    take(() => liveValue(inventory.watchTaxRates(storeId))),
    take(() => liveValue(inventory.watchDiscounts(storeId))),
    take(() => read(settingsRepositoryProvider).ensureSettings(storeId)),
    take(() => liveValue(read(debtsRepositoryProvider).watchCustomers(storeId))),
    take(() => liveValue(auth.watchEmployees(storeId))),
    take(() async {
      // Each branch's stock, so the till knows what is left while offline.
      final branches = await auth.listBranches(storeId);
      await Future.wait([for (final b in branches) liveValue(inventory.watchStock(storeId, b.id))]);
      return null;
    }),
  ]);
}

/// Waits for a fresh value from the server: a cached stream first replays
/// the copy on the device, so the second value is the live one (if there
/// was no copy, the first one already is — and gets stored).
Future<void> liveValue(Stream<Object?> stream) async {
  var seen = 0;
  final done = Completer<void>();
  late final StreamSubscription<Object?> sub;
  sub = stream.listen(
    (_) {
      seen++;
      if (seen >= 2 && !done.isCompleted) done.complete();
    },
    onError: (Object _) {},
    onDone: () {
      if (!done.isCompleted) done.complete();
    },
  );
  try {
    await done.future.timeout(const Duration(seconds: 15));
  } on TimeoutException {
    // Only one value came: it was the live one (no earlier copy).
  } finally {
    await sub.cancel();
  }
}
