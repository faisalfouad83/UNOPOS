import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/auth/domain/session_controller.dart';

class AppBootstrapResult {
  const AppBootstrapResult({this.store, required this.hasValidLicense});
  final StoreRecord? store;
  final bool hasValidLicense;
}

/// Reflects [AppBootstrapResult.hasValidLicense] but can also be flipped
/// immediately by the activation screen (before a store exists) or by a
/// future re-activation in Settings, without waiting for a full app restart.
final licenseValidProvider = StateProvider<bool>((ref) => false);

/// Runs once at app start: loads the (at most one) local store, if any, and
/// resolves whether the install currently has a valid license.
final appBootstrapProvider = FutureProvider<AppBootstrapResult>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final gate = ref.watch(licenseGateServiceProvider);

  final store = await authRepo.getCurrentStore();
  final valid = await gate.hasValidLicense(storeId: store?.id);

  if (store != null) {
    ref.read(sessionControllerProvider.notifier).setStore(store);
  }
  ref.read(licenseValidProvider.notifier).state = valid;

  return AppBootstrapResult(store: store, hasValidLicense: valid);
});
