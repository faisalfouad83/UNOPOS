import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  AppSettingsRecord _mapRow(AppSettingsTableData row) => AppSettingsRecord(
        storeId: row.storeId,
        defaultLanguage: row.defaultLanguage,
        themeMode: AppThemeMode.values.firstWhere((m) => m.name == row.themeMode, orElse: () => AppThemeMode.system),
        currencyCode: row.currencyCode,
        currencySymbol: row.currencySymbol,
        defaultVatRatePercent: row.defaultVatRatePercent,
        printerConfig: PrinterConfig.fromJson(jsonDecode(row.printerConfigJson) as Map<String, dynamic>),
        autoBackupEnabled: row.autoBackupEnabled,
        autoBackupTimeOfDay: row.autoBackupTimeOfDay,
        autoBackupFolderPath: row.autoBackupFolderPath,
        lowStockThresholdDefault: row.lowStockThresholdDefault,
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
            printerConfigJson: Value(jsonEncode(defaults.printerConfig.toJson())),
          ),
        );
    return defaults;
  }

  @override
  Stream<AppSettingsRecord> watchSettings(String storeId) {
    return (_db.select(_db.appSettingsTable)..where((t) => t.storeId.equals(storeId)))
        .watchSingle()
        .map(_mapRow);
  }

  @override
  Future<void> updateSettings(AppSettingsRecord settings) async {
    await (_db.update(_db.appSettingsTable)..where((t) => t.storeId.equals(settings.storeId))).write(
      AppSettingsTableCompanion(
        defaultLanguage: Value(settings.defaultLanguage),
        themeMode: Value(settings.themeMode.name),
        currencyCode: Value(settings.currencyCode),
        currencySymbol: Value(settings.currencySymbol),
        defaultVatRatePercent: Value(settings.defaultVatRatePercent),
        printerConfigJson: Value(jsonEncode(settings.printerConfig.toJson())),
        autoBackupEnabled: Value(settings.autoBackupEnabled),
        autoBackupTimeOfDay: Value(settings.autoBackupTimeOfDay),
        autoBackupFolderPath: Value(settings.autoBackupFolderPath),
        lowStockThresholdDefault: Value(settings.lowStockThresholdDefault),
      ),
    );
  }
}
