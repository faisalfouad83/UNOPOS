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
    this.currencyCode = 'IQD',
    this.currencySymbol = 'د.ع',
    this.defaultVatRatePercent = 0,
    this.printerConfig = const PrinterConfig(),
    this.autoBackupEnabled = false,
    this.autoBackupTimeOfDay = '22:00',
    this.autoBackupFolderPath,
    this.lowStockThresholdDefault = 5,
    this.usdExchangeRate = 0,
    this.loyaltySpendPerPointMinor = 0,
    this.loyaltyPointValueMinor = 0,
    this.loyaltyEnabledFlag = false,
    this.fullDiscountKeepsMargin = false,
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

  /// Iraqi dinars per US dollar; 0 when not set.
  final double usdExchangeRate;

  /// Spend this much (minor units) to earn one loyalty point; 0 = loyalty off.
  final int loyaltySpendPerPointMinor;

  /// What one point is worth when redeemed (minor units); 0 = can't redeem.
  final int loyaltyPointValueMinor;

  /// The Settings switch for loyalty points.
  final bool loyaltyEnabledFlag;

  /// Loyalty is in effect: switched on and an earn rate is set.
  bool get loyaltyEnabled => loyaltyEnabledFlag && loyaltySpendPerPointMinor > 0;

  /// A 100% discount still charges cost + 5% instead of giving goods away.
  final bool fullDiscountKeepsMargin;

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
    double? usdExchangeRate,
    int? loyaltySpendPerPointMinor,
    int? loyaltyPointValueMinor,
    bool? loyaltyEnabledFlag,
    bool? fullDiscountKeepsMargin,
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
        usdExchangeRate: usdExchangeRate ?? this.usdExchangeRate,
        loyaltySpendPerPointMinor: loyaltySpendPerPointMinor ?? this.loyaltySpendPerPointMinor,
        loyaltyPointValueMinor: loyaltyPointValueMinor ?? this.loyaltyPointValueMinor,
        loyaltyEnabledFlag: loyaltyEnabledFlag ?? this.loyaltyEnabledFlag,
        fullDiscountKeepsMargin: fullDiscountKeepsMargin ?? this.fullDiscountKeepsMargin,
      );
}
