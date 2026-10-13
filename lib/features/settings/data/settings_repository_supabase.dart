import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class SupabaseSettingsRepository implements SettingsRepository {
  SupabaseSettingsRepository(this._client);

  final SupabaseClient _client;

  static String _cacheKey(String storeId) => 'app_settings.$storeId';

  AppSettingsRecord _mapRow(Map<String, dynamic> row) => AppSettingsRecord(
        storeId: row['store_id'] as String,
        defaultLanguage: row['default_language'] as String,
        themeMode:
            AppThemeMode.values.firstWhere((m) => m.name == row['theme_mode'], orElse: () => AppThemeMode.system),
        currencyCode: row['currency_code'] as String,
        currencySymbol: row['currency_symbol'] as String,
        defaultVatRatePercent: (row['default_vat_rate_percent'] as num).toDouble(),
        printerConfig: PrinterConfig.fromJson(jsonDecode(row['printer_config_json'] as String) as Map<String, dynamic>),
        autoBackupEnabled: row['auto_backup_enabled'] as bool,
        autoBackupTimeOfDay: row['auto_backup_time_of_day'] as String,
        autoBackupFolderPath: row['auto_backup_folder_path'] as String?,
        lowStockThresholdDefault: (row['low_stock_threshold_default'] as num).toInt(),
        usdExchangeRate: (row['usd_exchange_rate'] as num?)?.toDouble() ?? 0,
        loyaltySpendPerPointMinor: (row['loyalty_spend_per_point_minor'] as num?)?.toInt() ?? 0,
        loyaltyPointValueMinor: (row['loyalty_point_value_minor'] as num?)?.toInt() ?? 0,
        loyaltyEnabledFlag: row['loyalty_enabled'] as bool? ?? false,
        fullDiscountKeepsMargin: row['full_discount_keeps_margin'] as bool? ?? false,
        breakEnabled: row['break_enabled'] as bool? ?? false,
        breakMaxMinutes: (row['break_max_minutes'] as num?)?.toInt() ?? 15,
        breakMaxPerDay: (row['break_max_per_day'] as num?)?.toInt() ?? 2,
        breakRoles: row['break_roles'] as String? ?? 'cashier,warehouseManager',
      );

  @override
  Future<AppSettingsRecord> ensureSettings(String storeId) async {
    final Map<String, dynamic>? existing;
    try {
      existing = await _client.from('app_settings').select().eq('store_id', storeId).maybeSingle();
    } catch (e) {
      // Offline: fall back to the last settings this device saw.
      final cached = await OfflineCache.readRows(_cacheKey(storeId));
      if (isNetworkError(e) && cached != null && cached.isNotEmpty) return _mapRow(cached.first);
      rethrow;
    }
    if (existing != null) {
      await OfflineCache.write(_cacheKey(storeId), [existing]);
      return _mapRow(existing);
    }

    // register_store() already inserts this row at store-creation time, so
    // this path is defensive-only — but two callers racing to create it
    // (e.g. two devices signing in for the first time simultaneously) could
    // still both reach here, so a unique-violation on retry is expected and
    // handled by re-reading rather than crashing.
    final defaults = AppSettingsRecord(storeId: storeId);
    try {
      await _client.from('app_settings').insert({
        'id': storeId,
        'store_id': storeId,
        'currency_code': defaults.currencyCode,
        'currency_symbol': defaults.currencySymbol,
        'printer_config_json': jsonEncode(defaults.printerConfig.toJson()),
      });
      return defaults;
    } on PostgrestException {
      final row = await _client.from('app_settings').select().eq('store_id', storeId).single();
      return _mapRow(row);
    }
  }

  @override
  Stream<AppSettingsRecord> watchSettings(String storeId) {
    return resilientRows(
      _cacheKey(storeId),
      () => _client.from('app_settings').stream(primaryKey: ['id']).eq('store_id', storeId),
    ).where((rows) => rows.isNotEmpty).map((rows) => _mapRow(rows.first));
  }

  @override
  Future<void> updateSettings(AppSettingsRecord settings) async {
    await _client.from('app_settings').update({
      'default_language': settings.defaultLanguage,
      'theme_mode': settings.themeMode.name,
      'currency_code': settings.currencyCode,
      'currency_symbol': settings.currencySymbol,
      'default_vat_rate_percent': settings.defaultVatRatePercent,
      'printer_config_json': jsonEncode(settings.printerConfig.toJson()),
      'auto_backup_enabled': settings.autoBackupEnabled,
      'auto_backup_time_of_day': settings.autoBackupTimeOfDay,
      'auto_backup_folder_path': settings.autoBackupFolderPath,
      'low_stock_threshold_default': settings.lowStockThresholdDefault,
      'usd_exchange_rate': settings.usdExchangeRate,
      'loyalty_spend_per_point_minor': settings.loyaltySpendPerPointMinor,
      'loyalty_point_value_minor': settings.loyaltyPointValueMinor,
      'loyalty_enabled': settings.loyaltyEnabledFlag,
      'full_discount_keeps_margin': settings.fullDiscountKeepsMargin,
      'break_enabled': settings.breakEnabled,
      'break_max_minutes': settings.breakMaxMinutes,
      'break_max_per_day': settings.breakMaxPerDay,
      'break_roles': settings.breakRoles,
    }).eq('store_id', settings.storeId);
  }
}
