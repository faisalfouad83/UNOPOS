import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../supabase/supabase_config.dart';
import 'offline_cache.dart';

/// Takes a copy of what the till needs to keep working without internet,
/// every time a store is opened: products, categories, tax rates,
/// discounts, settings, customers and debts, accounts, branches with their
/// stock and held sales, recent invoices, expenses, the books, shifts,
/// suppliers, purchase orders and stock transfers (with their lines, so
/// receiving one offline shows on the stock). Each is kept on the device
/// by its own repository and refreshed live while online. Copies not used
/// for a long time are dropped afterwards ([OfflineCache.prune]). Best
/// effort and in the background — it never holds the app up.
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
  final pos = read(posRepositoryProvider);
  final debts = read(debtsRepositoryProvider);
  final now = DateTime.now();
  await Future.wait([
    take(() => liveValue(inventory.watchProducts(storeId))),
    take(() => liveValue(inventory.watchCategories(storeId))),
    take(() => liveValue(inventory.watchTaxRates(storeId))),
    take(() => liveValue(inventory.watchDiscounts(storeId))),
    take(() => read(settingsRepositoryProvider).ensureSettings(storeId)),
    take(() => liveValue(debts.watchCustomers(storeId))),
    take(() => liveValue(debts.watchOpenDebts(storeId))),
    take(() => liveValue(auth.watchEmployees(storeId))),
    // Recent invoices and the books, so lists, totals and shift closing
    // work offline too.
    take(() => liveValue(pos.watchCompletedSales(storeId, from: DateTime(now.year, now.month - 1)))),
    take(() => liveValue(read(expenseDetailsRepositoryProvider).watch(storeId, from: DateTime(now.year)))),
    take(() => liveValue(read(accountingRepositoryProvider).watchJournalEntries(storeId))),
    take(() => liveValue(read(shiftsRepositoryProvider).watchShiftHistory(storeId))),
    take(() => liveValue(read(suppliersRepositoryProvider).watchSuppliers(storeId))),
    take(() => liveValue(inventory.watchPurchaseOrders(storeId))),
    take(() => liveValue(inventory.watchStockTransfers(storeId))),
    take(() async {
      // Each branch's stock and held sales, so the till knows what is left
      // and can resume a held sale while offline.
      final branches = await auth.listBranches(storeId);
      await Future.wait([
        for (final b in branches) ...[
          liveValue(inventory.watchStock(storeId, b.id)),
          liveValue(pos.watchHeldSales(storeId, b.id)),
        ],
      ]);
      return null;
    }),
  ]);
  await OfflineCache.prune();
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
