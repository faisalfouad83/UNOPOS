import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';

/// True while the signed-in store's code (or trial) has run out; the router
/// then locks the app on the "license expired" screen.
final licenseExpiredProvider = StateProvider<bool>((ref) => false);

/// When the store's current code / trial ends (null = no end date or not
/// known yet). Shown in Settings and on the lock screen.
final licenseExpiresAtProvider = StateProvider<DateTime?>((ref) => null);

/// Re-reads the store's license and updates [licenseExpiredProvider]. Run at
/// start-up, on store sign-in, every minute while the app is open, and after
/// a new code is entered. Offline, it decides from the last end date it saw
/// rather than locking or unlocking on a network error.
Future<void> refreshLicenseState(Ref ref) async {
  final storeId = ref.read(sessionControllerProvider).store?.id;
  if (storeId == null) {
    ref.read(licenseExpiredProvider.notifier).state = false;
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
