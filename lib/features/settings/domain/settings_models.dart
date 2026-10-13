import '../../printing/domain/receipt_models.dart';

enum AppThemeMode { light, dark, system }

/// What happens after a sale is paid: print the receipt straight away, ask
/// the cashier, or don't print.
enum ReceiptPrintMode {
  auto,
  ask,
  off;

  static ReceiptPrintMode fromName(String? name) =>
      ReceiptPrintMode.values.where((m) => m.name == name).firstOrNull ?? ReceiptPrintMode.auto;
}

class PrinterConfig {
  const PrinterConfig({
    this.driverType = 'none',
    this.connectionAddress,
    this.paperWidthMm = 58,
    this.showLogo = false,
    this.printMode = ReceiptPrintMode.auto,
    this.paper = ReceiptPaper.thermal,
    this.style = ReceiptStyle.classic,
    this.brandName,
    this.brandPhone,
    this.brandAddress,
    this.brandFooter,
    this.logoBase64,
  });

  /// none/network/usb/bluetooth/windowsSystem
  final String driverType;
  final String? connectionAddress;
  final int paperWidthMm;
  final bool showLogo;

  /// Stores set up before this setting existed printed every receipt
  /// automatically, so that stays the default.
  final ReceiptPrintMode printMode;

  /// Receipt template: paper and style.
  final ReceiptPaper paper;
  final ReceiptStyle style;

  /// Invoice branding. Empty/null falls back to the store's name, the
  /// branch's phone and address, and the default thank-you line.
  final String? brandName;
  final String? brandPhone;
  final String? brandAddress;
  final String? brandFooter;

  /// The logo as a small PNG (resized when chosen), base64 — kept with the
  /// store's settings so every till of the store prints the same logo.
  final String? logoBase64;

  ReceiptLayout get layout => ReceiptLayout(paper: paper, style: style, paperWidthMm: paperWidthMm);

  Map<String, dynamic> toJson() => {
        'driverType': driverType,
        'connectionAddress': connectionAddress,
        'paperWidthMm': paperWidthMm,
        'showLogo': showLogo,
        'printMode': printMode.name,
        'paper': paper.name,
        'style': style.name,
        'brandName': brandName,
        'brandPhone': brandPhone,
        'brandAddress': brandAddress,
        'brandFooter': brandFooter,
        'logoBase64': logoBase64,
      };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) => PrinterConfig(
        driverType: json['driverType'] as String? ?? 'none',
        connectionAddress: json['connectionAddress'] as String?,
        paperWidthMm: json['paperWidthMm'] as int? ?? 58,
        showLogo: json['showLogo'] as bool? ?? false,
        printMode: ReceiptPrintMode.fromName(json['printMode'] as String?),
        paper: ReceiptPaper.fromName(json['paper'] as String?),
        style: ReceiptStyle.fromName(json['style'] as String?),
        brandName: json['brandName'] as String?,
        brandPhone: json['brandPhone'] as String?,
        brandAddress: json['brandAddress'] as String?,
        brandFooter: json['brandFooter'] as String?,
        logoBase64: json['logoBase64'] as String?,
      );

  PrinterConfig copyWith({
    String? driverType,
    String? connectionAddress,
    int? paperWidthMm,
    bool? showLogo,
    ReceiptPrintMode? printMode,
    ReceiptPaper? paper,
    ReceiptStyle? style,
    String? brandName,
    String? brandPhone,
    String? brandAddress,
    String? brandFooter,
    String? logoBase64,
    bool clearLogo = false,
  }) =>
      PrinterConfig(
        driverType: driverType ?? this.driverType,
        connectionAddress: connectionAddress ?? this.connectionAddress,
        paperWidthMm: paperWidthMm ?? this.paperWidthMm,
        showLogo: showLogo ?? this.showLogo,
        printMode: printMode ?? this.printMode,
        paper: paper ?? this.paper,
        style: style ?? this.style,
        brandName: brandName ?? this.brandName,
        brandPhone: brandPhone ?? this.brandPhone,
        brandAddress: brandAddress ?? this.brandAddress,
        brandFooter: brandFooter ?? this.brandFooter,
        logoBase64: clearLogo ? null : (logoBase64 ?? this.logoBase64),
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
    this.breakEnabled = false,
    this.breakMaxMinutes = 15,
    this.breakMaxPerDay = 2,
    this.breakRoles = 'cashier,warehouseManager',
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

  /// Employee breaks: on/off, minutes per break, breaks per employee per
  /// day, and which roles may take them (comma-separated role names).
  final bool breakEnabled;
  final int breakMaxMinutes;
  final int breakMaxPerDay;
  final String breakRoles;

  Set<String> get breakRoleNames => breakRoles.split(',').map((r) => r.trim()).where((r) => r.isNotEmpty).toSet();

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
    bool? breakEnabled,
    int? breakMaxMinutes,
    int? breakMaxPerDay,
    String? breakRoles,
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
        breakEnabled: breakEnabled ?? this.breakEnabled,
        breakMaxMinutes: breakMaxMinutes ?? this.breakMaxMinutes,
        breakMaxPerDay: breakMaxPerDay ?? this.breakMaxPerDay,
        breakRoles: breakRoles ?? this.breakRoles,
      );
}
