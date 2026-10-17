import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theming/store_themes.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  /// The local database has no theme_key column (its schema stays as it
  /// is), so its theme_mode column holds the store's theme choice: a theme
  /// key, 'system' (follow the device — what older versions saved by
  /// default, so they keep looking the same) or [_automatic].
  static const _automatic = 'auto';

  static String _themeColumn(AppSettingsRecord s) => s.themeKey ?? _automatic;

  AppSettingsRecord _mapRow(AppSettingsTableData row) => AppSettingsRecord(
        storeId: row.storeId,
        defaultLanguage: row.defaultLanguage,
        themeMode: switch (row.themeMode) {
          'light' => AppThemeMode.light,
          'dark' => AppThemeMode.dark,
          'system' || _automatic => AppThemeMode.system,
          final key => StoreThemeKey.fromDb(key)?.palette.isDark == true ? AppThemeMode.dark : AppThemeMode.light,
        },
        themeKey: row.themeMode == _automatic ? null : row.themeMode,
        currencyCode: row.currencyCode,
        currencySymbol: row.currencySymbol,
        defaultVatRatePercent: row.defaultVatRatePercent,
        printerConfig: PrinterConfig.fromJson(jsonDecode(row.printerConfigJson) as Map<String, dynamic>),
        autoBackupEnabled: row.autoBackupEnabled,
        autoBackupTimeOfDay: row.autoBackupTimeOfDay,
        autoBackupFolderPath: row.autoBackupFolderPath,
        lowStockThresholdDefault: row.lowStockThresholdDefault,
        usdExchangeRate: row.usdExchangeRate,
        loyaltySpendPerPointMinor: row.loyaltySpendPerPointMinor,
        loyaltyPointValueMinor: row.loyaltyPointValueMinor,
        loyaltyEnabledFlag: row.loyaltyEnabled,
        fullDiscountKeepsMargin: row.fullDiscountKeepsMargin,
        breakEnabled: row.breakEnabled,
        breakMaxMinutes: row.breakMaxMinutes,
        breakMaxPerDay: row.breakMaxPerDay,
        breakRoles: row.breakRoles,
      );

  @override
  Future<AppSettingsRecord> ensureSettings(String storeId) async {
    final existing =
        await (_db.select(_db.appSettingsTable)..where((t) => t.storeId.equals(storeId))).getSingleOrNull();
    if (existing != null) return _mapRow(existing);

    final defaults = AppSettingsRecord(storeId: storeId);
    await _db.into(_db.appSettingsTable).insert(
          AppSettingsTableCompanion.insert(
            id: storeId,
            storeId: storeId,
            currencyCode: Value(defaults.currencyCode),
            currencySymbol: Value(defaults.currencySymbol),
            printerConfigJson: Value(jsonEncode(defaults.printerConfig.toJson())),
          ),
        );
    return defaults;
  }

  @override
  Stream<AppSettingsRecord> watchSettings(String storeId) {
    return (_db.select(_db.appSettingsTable)..where((t) => t.storeId.equals(storeId))).watchSingle().map(_mapRow);
  }

  @override
  Future<void> updateSettings(AppSettingsRecord settings) async {
    await (_db.update(_db.appSettingsTable)..where((t) => t.storeId.equals(settings.storeId))).write(
      AppSettingsTableCompanion(
        defaultLanguage: Value(settings.defaultLanguage),
        themeMode: Value(_themeColumn(settings)),
        currencyCode: Value(settings.currencyCode),
        currencySymbol: Value(settings.currencySymbol),
        defaultVatRatePercent: Value(settings.defaultVatRatePercent),
        printerConfigJson: Value(jsonEncode(settings.printerConfig.toJson())),
        autoBackupEnabled: Value(settings.autoBackupEnabled),
        autoBackupTimeOfDay: Value(settings.autoBackupTimeOfDay),
        autoBackupFolderPath: Value(settings.autoBackupFolderPath),
        lowStockThresholdDefault: Value(settings.lowStockThresholdDefault),
        usdExchangeRate: Value(settings.usdExchangeRate),
        loyaltySpendPerPointMinor: Value(settings.loyaltySpendPerPointMinor),
        loyaltyPointValueMinor: Value(settings.loyaltyPointValueMinor),
        loyaltyEnabled: Value(settings.loyaltyEnabledFlag),
        fullDiscountKeepsMargin: Value(settings.fullDiscountKeepsMargin),
        breakEnabled: Value(settings.breakEnabled),
        breakMaxMinutes: Value(settings.breakMaxMinutes),
        breakMaxPerDay: Value(settings.breakMaxPerDay),
        breakRoles: Value(settings.breakRoles),
      ),
    );
  }
}
