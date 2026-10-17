import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import 'entitlement.dart';

/// True while the signed-in store's code (or trial) has run out; the router
/// then locks the app on the "license expired" screen.
final licenseExpiredProvider = StateProvider<bool>((ref) => false);

/// When the store's current code / trial ends (null = no end date or not
/// known yet). Shown in Settings and on the lock screen.
final licenseExpiresAtProvider = StateProvider<DateTime?>((ref) => null);

/// The signed-in store's plan: limits, included sections, end date, and
/// when the server last confirmed it. Null = not known yet, or no plans
/// (local build) — then every section is open.
final entitlementProvider = StateProvider<Entitlement?>((ref) => null);

/// Re-reads the store's license and updates [licenseExpiredProvider]. Run at
/// start-up, on store sign-in, every minute while the app is open, and after
/// a new code is entered. Offline, it decides from the last end date it saw
/// rather than locking or unlocking on a network error.
Future<void> refreshLicenseState(Ref ref) async {
  final storeId = ref.read(sessionControllerProvider).store?.id;
  if (storeId == null) {
    ref.read(licenseExpiredProvider.notifier).state = false;
    ref.read(entitlementProvider.notifier).state = null;
    return;
  }
  final cacheKey = 'license.$storeId';
  bool licensed;
  DateTime? expiresAt;
  try {
    final license = await ref.read(licensingRepositoryProvider).licenseFor(storeId);
    licensed = license.licensed;
    expiresAt = license.expiresAt;
    await OfflineCache.write(cacheKey, {'licensed': licensed, 'expiresAt': expiresAt?.toIso8601String()});
  } catch (e) {
    if (!isNetworkError(e)) rethrow;
    final cached = await OfflineCache.read(cacheKey);
    if (cached is! Map) return;
    expiresAt = cached['expiresAt'] == null ? null : DateTime.parse(cached['expiresAt'] as String).toLocal();
    licensed = (cached['licensed'] as bool? ?? true) && (expiresAt == null || DateTime.now().isBefore(expiresAt));
  }
  ref.read(licenseExpiresAtProvider.notifier).state = expiresAt;
  ref.read(licenseExpiredProvider.notifier).state = !licensed;

  final repo = ref.read(licensingRepositoryProvider);
  final entitlement = await loadEntitlement(storeId, () => repo.entitlementFor(storeId));
  // Still the same store (the check above took a moment).
  if (ref.read(sessionControllerProvider).store?.id == storeId) {
    ref.read(entitlementProvider.notifier).state = entitlement;
  }
}

/// Asks the server for the store's plan with [fetch] and keeps a copy on
/// the device. When it can't be asked (no connection, or a server without
/// plans yet), the copy kept last time is used, marked
/// [Entitlement.fromCache]; with no copy, null (nothing is shut).
Future<Entitlement?> loadEntitlement(String storeId, Future<Entitlement?> Function() fetch) async {
  final key = 'entitlement.$storeId';
  try {
    final fresh = await fetch();
    if (fresh != null) await OfflineCache.write(key, fresh.toJson());
    return fresh;
  } catch (_) {
    final cached = await OfflineCache.read(key);
    if (cached is! Map) return null;
    return Entitlement.fromJson(cached.cast<String, dynamic>(), fromCache: true);
  }
}

/// Keeps the license state fresh: on sign-in/out and once a minute.
final licenseWatcherProvider = Provider<void>((ref) {
  ref.listen(sessionControllerProvider.select((s) => s.store?.id), (_, __) => refreshLicenseState(ref),
      fireImmediately: true);
  final timer = Stream.periodic(const Duration(minutes: 1)).listen((_) => refreshLicenseState(ref));
  ref.onDispose(timer.cancel);
});

/// For widgets: `ref.read(licenseRefresherProvider)()` re-checks the license
/// (e.g. right after a new code is entered).
final licenseRefresherProvider = Provider<Future<void> Function()>((ref) => () => refreshLicenseState(ref));
