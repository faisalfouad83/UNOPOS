import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/domain/session_controller.dart';
import '../features/settings/domain/settings_models.dart';
import 'providers.dart';

/// Live Settings of the store this device is signed into (null before a
/// store is loaded). Shared by everything that needs store-wide preferences
/// outside the Settings screen itself — currency, exchange rate, etc.
final currentStoreSettingsProvider = StreamProvider<AppSettingsRecord?>((ref) {
  final storeId = ref.watch(sessionControllerProvider.select((s) => s.store?.id));
  if (storeId == null) return Stream.value(null);
  return ref.watch(settingsRepositoryProvider).watchSettings(storeId);
});
