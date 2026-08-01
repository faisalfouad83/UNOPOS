enum AppThemeMode { light, dark, system }

class PrinterConfig {
  const PrinterConfig({
    this.driverType = 'none',
    this.connectionAddress,
    this.paperWidthMm = 58,
    this.showLogo = false,
  });

  /// none/network/usb/bluetooth/windowsSystem
  final String driverType;
  final String? connectionAddress;
  final int paperWidthMm;
  final bool showLogo;

  Map<String, dynamic> toJson() => {
        'driverType': driverType,
        'connectionAddress': connectionAddress,
        'paperWidthMm': paperWidthMm,
        'showLogo': showLogo,
      };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) => PrinterConfig(
        driverType: json['driverType'] as String? ?? 'none',
        connectionAddress: json['connectionAddress'] as String?,
        paperWidthMm: json['paperWidthMm'] as int? ?? 58,
        showLogo: json['showLogo'] as bool? ?? false,
      );

  PrinterConfig copyWith({
    String? driverType,
    String? connectionAddress,
    int? paperWidthMm,
    bool? showLogo,
  }) =>
      PrinterConfig(
        driverType: driverType ?? this.driverType,
        connectionAddress: connectionAddress ?? this.connectionAddress,
        paperWidthMm: paperWidthMm ?? this.paperWidthMm,
        showLogo: showLogo ?? this.showLogo,
      );
}

class AppSettingsRecord {
  const AppSettingsRecord({
    required this.storeId,
    this.defaultLanguage = 'en',
    this.themeMode = AppThemeMode.system,
    this.currencyCode = 'USD',
    this.currencySymbol = r'$',
    this.defaultVatRatePercent = 0,
    this.printerConfig = const PrinterConfig(),
    this.autoBackupEnabled = false,
    this.autoBackupTimeOfDay = '22:00',
    this.autoBackupFolderPath,
    this.lowStockThresholdDefault = 5,
  });

  final String storeId;
  final String defaultLanguage;
  final AppThemeMode themeMode;
  final String currencyCode;
  final String currencySymbol;
  final double defaultVatRatePercent;
  final PrinterConfig printerConfig;
  final bool autoBackupEnabled;
  final String autoBackupTimeOfDay;
  final String? autoBackupFolderPath;
  final int lowStockThresholdDefault;

  AppSettingsRecord copyWith({
    String? defaultLanguage,
    AppThemeMode? themeMode,
    String? currencyCode,
    String? currencySymbol,
    double? defaultVatRatePercent,
    PrinterConfig? printerConfig,
    bool? autoBackupEnabled,
    String? autoBackupTimeOfDay,
    String? autoBackupFolderPath,
    int? lowStockThresholdDefault,
  }) =>
      AppSettingsRecord(
        storeId: storeId,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
        themeMode: themeMode ?? this.themeMode,
        currencyCode: currencyCode ?? this.currencyCode,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        defaultVatRatePercent: defaultVatRatePercent ?? this.defaultVatRatePercent,
        printerConfig: printerConfig ?? this.printerConfig,
        autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
        autoBackupTimeOfDay: autoBackupTimeOfDay ?? this.autoBackupTimeOfDay,
        autoBackupFolderPath: autoBackupFolderPath ?? this.autoBackupFolderPath,
        lowStockThresholdDefault: lowStockThresholdDefault ?? this.lowStockThresholdDefault,
      );
}
