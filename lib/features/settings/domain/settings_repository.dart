import 'settings_models.dart';

abstract class SettingsRepository {
  /// Creates a default settings row if none exists yet for this store.
  Future<AppSettingsRecord> ensureSettings(String storeId);

  Stream<AppSettingsRecord> watchSettings(String storeId);

  Future<void> updateSettings(AppSettingsRecord settings);
}
