import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_models.dart';

/// The settings that belong to this device rather than to the store: the
/// printer it is connected to (kind, address, paper) and where and when it
/// saves backups. The store's other settings are shared by all its devices.
///
/// A device that has none of its own yet starts from what the store had
/// (which, before these were kept per device, was the one device's setup).
class DeviceSettings {
  const DeviceSettings._();

  static final _memory = <String, Map<String, dynamic>>{};

  static String _key(String storeId) => 'device_settings.v1.$storeId';

  static Map<String, dynamic> _from(AppSettingsRecord s) => {
        'driver_type': s.printerConfig.driverType,
        'connection_address': s.printerConfig.connectionAddress,
        'paper_width_mm': s.printerConfig.paperWidthMm,
        'paper': s.printerConfig.paper.name,
        'auto_backup_enabled': s.autoBackupEnabled,
        'auto_backup_time_of_day': s.autoBackupTimeOfDay,
        'auto_backup_folder_path': s.autoBackupFolderPath,
      };

  static Future<Map<String, dynamic>?> _read(String storeId) async {
    final cached = _memory[storeId];
    if (cached != null) return cached;
    final raw = (await SharedPreferences.getInstance()).getString(_key(storeId));
    if (raw == null) return null;
    return _memory[storeId] = (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  /// Keeps [settings]' device part as this device's own.
  static Future<void> save(AppSettingsRecord settings) async {
    final d = _from(settings);
    _memory[settings.storeId] = d;
    await (await SharedPreferences.getInstance()).setString(_key(settings.storeId), jsonEncode(d));
  }

  /// [settings] (as the store has them) with this device's own part.
  static Future<AppSettingsRecord> applyTo(AppSettingsRecord settings) async {
    final d = await _read(settings.storeId);
    if (d == null) {
      await save(settings);
      return settings;
    }
    return AppSettingsRecord(
      storeId: settings.storeId,
      defaultLanguage: settings.defaultLanguage,
      themeMode: settings.themeMode,
      themeKey: settings.themeKey,
      currencyCode: settings.currencyCode,
      currencySymbol: settings.currencySymbol,
      defaultVatRatePercent: settings.defaultVatRatePercent,
      printerConfig: PrinterConfig.fromJson({
        ...settings.printerConfig.toJson(),
        'driverType': d['driver_type'],
        'connectionAddress': d['connection_address'],
        'paperWidthMm': d['paper_width_mm'],
        'paper': d['paper'],
      }),
      autoBackupEnabled: d['auto_backup_enabled'] as bool? ?? settings.autoBackupEnabled,
      autoBackupTimeOfDay: d['auto_backup_time_of_day'] as String? ?? settings.autoBackupTimeOfDay,
      autoBackupFolderPath: d['auto_backup_folder_path'] as String?,
      lowStockThresholdDefault: settings.lowStockThresholdDefault,
      usdExchangeRate: settings.usdExchangeRate,
      loyaltySpendPerPointMinor: settings.loyaltySpendPerPointMinor,
      loyaltyPointValueMinor: settings.loyaltyPointValueMinor,
      loyaltyEnabledFlag: settings.loyaltyEnabledFlag,
      fullDiscountKeepsMargin: settings.fullDiscountKeepsMargin,
      breakEnabled: settings.breakEnabled,
      breakMaxMinutes: settings.breakMaxMinutes,
      breakMaxPerDay: settings.breakMaxPerDay,
      breakRoles: settings.breakRoles,
    );
  }
}
