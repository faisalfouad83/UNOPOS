import 'package:drift/drift.dart';

/// Singleton-per-store settings row. `id` is always equal to `storeId`.
class AppSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get defaultLanguage => text().withDefault(const Constant('en'))(); // en/ar/ckb
  TextColumn get themeMode => text().withDefault(const Constant('system'))(); // light/dark/system
  TextColumn get currencyCode => text().withDefault(const Constant('IQD'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('د.ع'))();
  RealColumn get defaultVatRatePercent => real().withDefault(const Constant(0))();

  /// JSON-encoded PrinterConfig (driver type + connection details + paper width).
  TextColumn get printerConfigJson => text().withDefault(const Constant('{}'))();

  BoolColumn get autoBackupEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get autoBackupTimeOfDay => text().withDefault(const Constant('22:00'))(); // HH:mm
  TextColumn get autoBackupFolderPath => text().nullable()();
  IntColumn get lowStockThresholdDefault => integer().withDefault(const Constant(5))();

  /// Iraqi dinars per US dollar; 0 = not set (dual-currency display off).
  RealColumn get usdExchangeRate => real().withDefault(const Constant(0))();

  /// Loyalty: spend this much (minor units) to earn one point; 0 = off.
  IntColumn get loyaltySpendPerPointMinor => integer().withDefault(const Constant(0))();

  /// Loyalty: what one point is worth when redeemed (minor units).
  IntColumn get loyaltyPointValueMinor => integer().withDefault(const Constant(0))();

  BoolColumn get loyaltyEnabled => boolean().withDefault(const Constant(false))();

  /// A 100% discount still charges cost + 5% instead of giving the item away.
  BoolColumn get fullDiscountKeepsMargin => boolean().withDefault(const Constant(false))();

  /// Employee breaks: on/off, minutes per break, breaks per day, and the
  /// roles that may take them (comma-separated role names).
  BoolColumn get breakEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get breakMaxMinutes => integer().withDefault(const Constant(15))();
  IntColumn get breakMaxPerDay => integer().withDefault(const Constant(2))();
  TextColumn get breakRoles => text().withDefault(const Constant('cashier,warehouseManager'))();

  @override
  Set<Column> get primaryKey => {id};
}
