import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offline/offline_cache.dart';
import '../offline/offline_warmup.dart';
import '../providers.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/auth/domain/session_controller.dart';
import '../../features/price_checker/application/price_checker_mode.dart';

class AppBootstrapResult {
  const AppBootstrapResult({this.store, required this.hasValidLicense, this.hasEmployees = false});
  final StoreRecord? store;
  final bool hasValidLicense;

  /// False if a store row exists but onboarding never finished creating its
  /// first employee (owner) — e.g. the app was closed/crashed between
  /// creating the store and creating its manager account. RouteGuard uses
  /// this to send the user back to finish that step instead of stranding
  /// them on a dead-end tile picker with nothing to tap.
  final bool hasEmployees;
}

/// Reflects [AppBootstrapResult.hasValidLicense] but can also be flipped
/// immediately by the activation screen (before a store exists) or by a
/// future re-activation in Settings, without waiting for a full app restart.
final licenseValidProvider = StateProvider<bool>((ref) => false);

/// Whether the store signed in on this device already has accounts. Set at
/// start-up and again on every store sign-in (start-up only knows the store
/// that was signed in when the app opened), so signing in to an existing
/// store goes to its accounts instead of "create the manager".
final storeHasEmployeesProvider = StateProvider<bool>((ref) => false);

/// Runs once at app start: loads the (at most one) local store, if any, and
/// resolves whether the install currently has a valid license.
final appBootstrapProvider = FutureProvider<AppBootstrapResult>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final gate = ref.watch(licenseGateServiceProvider);
  // A device left as a price checker reopens as one.
  await ref.read(priceCheckerModeProvider.notifier).load();

  final store = await authRepo.getCurrentStore();
  bool valid;
  try {
    valid = await gate.hasValidLicense(storeId: store?.id);
  } catch (e) {
    // Offline: the license lock decides from the last known end date
    // (license_watch), so don't stop the app from opening here.
    if (!isNetworkError(e)) rethrow;
    valid = true;
  }

  var hasEmployees = false;
  if (store != null) {
    ref.read(sessionControllerProvider.notifier).setStore(store);
    // A fresh copy for working offline, in the background.
    unawaited(warmOfflineCopy(ref.read, store.id));
    try {
      final employees = await authRepo.watchEmployees(store.id).first.timeout(const Duration(seconds: 12));
      hasEmployees = employees.isNotEmpty;
    } catch (e) {
      // Offline with no copy yet: an existing store has its accounts.
      hasEmployees = true;
    }
  }
  ref.read(licenseValidProvider.notifier).state = valid;
  ref.read(storeHasEmployeesProvider.notifier).state = hasEmployees;

  return AppBootstrapResult(store: store, hasValidLicense: valid, hasEmployees: hasEmployees);
});
