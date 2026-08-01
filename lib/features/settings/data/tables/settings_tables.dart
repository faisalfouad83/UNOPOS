import 'package:drift/drift.dart';

/// Singleton-per-store settings row. `id` is always equal to `storeId`.
class AppSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get defaultLanguage => text().withDefault(const Constant('en'))(); // en/ar/ckb
  TextColumn get themeMode => text().withDefault(const Constant('system'))(); // light/dark/system
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('\$'))();
  RealColumn get defaultVatRatePercent => real().withDefault(const Constant(0))();

  /// JSON-encoded PrinterConfig (driver type + connection details + paper width).
  TextColumn get printerConfigJson => text().withDefault(const Constant('{}'))();

  BoolColumn get autoBackupEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get autoBackupTimeOfDay => text().withDefault(const Constant('22:00'))(); // HH:mm
  TextColumn get autoBackupFolderPath => text().nullable()();
  IntColumn get lowStockThresholdDefault => integer().withDefault(const Constant(5))();

  @override
  Set<Column> get primaryKey => {id};
}
