// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'يونوبوس';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionDone => 'تم';

  @override
  String get actionYes => 'نعم';

  @override
  String get actionNo => 'لا';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionSignOut => 'تسجيل الخروج';

  @override
  String get actionPrint => 'طباعة';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get commonName => 'الاسم';

  @override
  String get commonPhone => 'رقم الهاتف';

  @override
  String get commonAddress => 'العنوان';

  @override
  String get commonAmount => 'المبلغ';

  @override
  String get commonDate => 'التاريخ';

  @override
  String get commonStatus => 'الحالة';

  @override
  String get commonNotes => 'ملاحظات';

  @override
  String get commonTotal => 'الإجمالي';

  @override
  String get commonSubtotal => 'المجموع الفرعي';

  @override
  String get commonTax => 'الضريبة';

  @override
  String get commonDiscount => 'الخصم';

  @override
  String get commonQuantity => 'الكمية';

  @override
  String get commonPrice => 'السعر';

  @override
  String get splashTagline => 'نظام نقاط بيع للتجارة الحديثة';

  @override
  String get activationTitle => 'تفعيل يونوبوس';

  @override
  String get activationSubtitle => 'أدخل رمز التفعيل المزوّد من ممثل يونوبوس';

  @override
  String get activationCodeLabel => 'رمز التفعيل';

  @override
  String get activationCodeHint => 'UNPS-XXXXX-XXXXX';

  @override
  String get activationButton => 'تفعيل';

  @override
  String get activationInvalid => 'رمز التفعيل غير صالح أو منتهي الصلاحية';

  @override
  String get activationExpired =>
      'انتهت صلاحية الترخيص. الرجاء إدخال رمز تفعيل جديد';

  @override
  String get activationSuccess => 'تم التفعيل بنجاح';

  @override
  String activationDaysRemaining(int days) {
    return 'متبقٍ $days يوم';
  }

  @override
  String get activationLifetime => 'ترخيص دائم';

  @override
  String get onboardingCreateStoreTitle => 'إنشاء متجرك';

  @override
  String get onboardingStoreId => 'معرّف المتجر';

  @override
  String get onboardingStorePassword => 'كلمة مرور المتجر';

  @override
  String get onboardingConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get onboardingCreateManagerTitle => 'إنشاء حساب المدير';

  @override
  String get onboardingManagerName => 'اسم المدير';

  @override
  String get onboardingManagerPasscode => 'اختر رمزاً سرياً من 4 أرقام';

  @override
  String get onboardingBranchCount => 'عدد الفروع';

  @override
  String get onboardingBranchDetails => 'تفاصيل الفرع';

  @override
  String get onboardingBranchName => 'اسم الفرع';

  @override
  String get onboardingBranchLocation => 'موقع الفرع';

  @override
  String get onboardingFinish => 'إنهاء الإعداد';

  @override
  String get loginStoreTitle => 'تسجيل دخول المتجر';

  @override
  String get loginStoreIdHint => 'أدخل معرّف المتجر';

  @override
  String get loginStorePasswordHint => 'أدخل كلمة مرور المتجر';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginInvalidCredentials => 'معرّف المتجر أو كلمة المرور غير صحيحة';

  @override
  String get loginCreateStoreLink => 'ليس لديك متجر بعد؟ أنشئ واحدًا';

  @override
  String get developerSignInTitle => 'تسجيل دخول المطوّر';

  @override
  String get developerSignInEmail => 'البريد الإلكتروني';

  @override
  String get developerSignInPassword => 'كلمة المرور';

  @override
  String get actionCreateStore => 'إنشاء متجر جديد';

  @override
  String get onboardingOwnerName => 'اسم المالك';

  @override
  String get pickAccountTitle => 'من يعمل الآن؟';

  @override
  String get pinPadTitle => 'أدخل الرمز السري';

  @override
  String get pinPadIncorrect => 'الرمز السري غير صحيح';

  @override
  String pinPadLocked(int seconds) {
    return 'محاولات كثيرة جداً. حاول مجدداً بعد $seconds ثانية';
  }

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navSales => 'المبيعات';

  @override
  String get navInventory => 'المخزون';

  @override
  String get navDebts => 'الديون';

  @override
  String get navSuppliers => 'الموردون';

  @override
  String get navAccounting => 'المحاسبة';

  @override
  String get navExpensesCash => 'المصاريف والصندوق';

  @override
  String get navHr => 'الموظفون';

  @override
  String get navReports => 'التقارير';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get posTitle => 'نقطة البيع';

  @override
  String get posSearchProducts => 'ابحث عن منتج أو امسح الباركود';

  @override
  String get posCart => 'سلة المشتريات';

  @override
  String get posEmptyCart => 'السلة فارغة';

  @override
  String get posHoldSale => 'تعليق البيع';

  @override
  String get posHeldSales => 'المبيعات المعلّقة';

  @override
  String get posResumeSale => 'استئناف';

  @override
  String get posCheckout => 'الدفع';

  @override
  String get posPayCash => 'نقداً';

  @override
  String get posPayCard => 'بطاقة';

  @override
  String get posPayLater => 'الدفع لاحقاً';

  @override
  String get posCustomerName => 'اسم الزبون';

  @override
  String get posAmountTendered => 'المبلغ المدفوع';

  @override
  String get posChangeDue => 'المبلغ المتبقي';

  @override
  String get posCompleteSale => 'إتمام البيع';

  @override
  String get posSaleCompleted => 'تم إتمام عملية البيع';

  @override
  String get posPrintReceipt => 'طباعة الإيصال';

  @override
  String get posShiftOpen => 'فتح الوردية';

  @override
  String get posShiftClose => 'إغلاق الوردية';

  @override
  String get posOpeningFloat => 'رصيد الصندوق الافتتاحي';

  @override
  String get posSalesHistory => 'سجل المبيعات';

  @override
  String get posProcessReturn => 'معالجة المرتجع';

  @override
  String get posRefundMethod => 'طريقة الاسترجاع';

  @override
  String get posReturnReducesBalance =>
      'سيؤدي هذا إلى تخفيض رصيد الزبون المستحق';

  @override
  String get posNoReturnableQuantitySelected =>
      'اختر عنصراً واحداً على الأقل للإرجاع';

  @override
  String get expensesCashTitle => 'المصاريف والصندوق';

  @override
  String get expensesCashSubtitle =>
      'متابعة المصاريف التشغيلية والإيرادات، ومطابقة الرصيد الفعلي للصندوق';

  @override
  String get expensesCashNoOpenShift =>
      'لا توجد وردية مفتوحة — افتح وردية لبدء متابعة الصندوق';

  @override
  String get expensesCashOpeningCash => 'الكاش الافتتاحي';

  @override
  String get expensesCashSalesTotal => 'إجمالي مبيعات الكاش';

  @override
  String get expensesCashTotalExpenses => 'إجمالي المصاريف المقتطعة';

  @override
  String get expensesCashExpected => 'الكاش المتوقع';

  @override
  String get expensesCashLog => 'سجل المصاريف';

  @override
  String get expensesCashNoExpenses => 'لا توجد مصاريف مسجلة بهذي الوردية';

  @override
  String get inventoryTitle => 'المخزون';

  @override
  String get inventoryProducts => 'المنتجات';

  @override
  String get inventoryCategories => 'الفئات';

  @override
  String get inventoryAddProduct => 'إضافة منتج';

  @override
  String get inventoryStockLevel => 'مستوى المخزون';

  @override
  String get inventoryLowStock => 'مخزون منخفض';

  @override
  String get inventoryGenerateQr => 'توليد رمز QR';

  @override
  String get inventoryBarcode => 'الباركود';

  @override
  String get inventoryGenerateBarcode => 'توليد باركود';

  @override
  String get inventoryBarcodeAutoHint => 'اتركه فارغاً ليتم توليده تلقائياً';

  @override
  String get inventoryPrintLabel => 'طباعة ملصق';

  @override
  String get inventoryGenerateMissingBarcodes =>
      'توليد باركود للمنتجات التي لا تملك باركود';

  @override
  String inventoryBarcodesGenerated(int count) {
    return 'تم توليد $count باركود';
  }

  @override
  String get inventoryTransferStock => 'نقل المخزون';

  @override
  String get inventoryPurchaseOrders => 'أوامر الشراء';

  @override
  String get inventoryAdjustStock => 'تعديل المخزون';

  @override
  String get inventoryUnit => 'الوحدة';

  @override
  String get unitPiece => 'قطعة';

  @override
  String get unitBottle => 'قنينة';

  @override
  String get unitCarton => 'كرتون';

  @override
  String get unitBox => 'صندوق';

  @override
  String get unitPack => 'عبوة';

  @override
  String get unitKilogram => 'كيلوغرام';

  @override
  String get unitLiter => 'لتر';

  @override
  String get debtsTitle => 'دفتر الديون';

  @override
  String get debtsCustomer => 'الزبون';

  @override
  String get debtsBalanceOwed => 'المبلغ المستحق';

  @override
  String get debtsRecordPayment => 'تسجيل دفعة';

  @override
  String get debtsHistory => 'سجل الدفعات';

  @override
  String get debtsOpen => 'مفتوح';

  @override
  String get debtsPartiallyPaid => 'مدفوع جزئياً';

  @override
  String get debtsPaid => 'مدفوع';

  @override
  String get suppliersTitle => 'الموردون';

  @override
  String get suppliersContact => 'معلومات التواصل';

  @override
  String get suppliersBalanceOwed => 'المستحق عليّ';

  @override
  String get suppliersShipmentDate => 'تاريخ الشحنة';

  @override
  String get suppliersAddSupplier => 'إضافة مورّد';

  @override
  String get suppliersRecordPayment => 'تسجيل دفعة';

  @override
  String get accountingTitle => 'المحاسبة';

  @override
  String get accountingChartOfAccounts => 'دليل الحسابات';

  @override
  String get accountingJournal => 'قيود اليومية';

  @override
  String get accountingGeneralLedger => 'دفتر الأستاذ العام';

  @override
  String get accountingTrialBalance => 'ميزان المراجعة';

  @override
  String get accountingProfitLoss => 'الأرباح والخسائر';

  @override
  String get accountingBalanceSheet => 'الميزانية العمومية';

  @override
  String get accountingExpenses => 'المصروفات';

  @override
  String get accountingAddExpense => 'إضافة مصروف';

  @override
  String get hrTitle => 'دليل الموظفين';

  @override
  String get hrAddEmployee => 'إضافة موظف';

  @override
  String get hrRole => 'الوظيفة';

  @override
  String get hrSalary => 'الراتب';

  @override
  String get hrAllowances => 'البدلات';

  @override
  String get hrBranch => 'الفرع';

  @override
  String get hrRoleOwner => 'المالك';

  @override
  String get hrRoleManager => 'المدير';

  @override
  String get hrRoleCashier => 'الكاشير';

  @override
  String get hrRoleWarehouseManager => 'مدير المستودع';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsGeneral => 'عام';

  @override
  String get settingsPrinter => 'طابعة الإيصالات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'حسب النظام';

  @override
  String get settingsActivation => 'التفعيل';

  @override
  String get settingsBranches => 'الفروع';

  @override
  String get settingsAddBranch => 'إضافة فرع';

  @override
  String get settingsSetActiveBranch => 'تعيين كفرع نشط';

  @override
  String get settingsActiveBranch => 'الفرع النشط';

  @override
  String get settingsBranchDeactivate => 'تعطيل';

  @override
  String get settingsBranchActivate => 'إعادة تفعيل';

  @override
  String get settingsBranchDeactivated => 'معطّل';

  @override
  String get settingsBackup => 'النسخ الاحتياطي والاستعادة';

  @override
  String get settingsBackupNow => 'نسخ احتياطي الآن';

  @override
  String get settingsRestore => 'استعادة من نسخة احتياطية';

  @override
  String get settingsAutoBackup => 'نسخ احتياطي تلقائي يومي';

  @override
  String get settingsFactoryReset => 'إعادة ضبط المصنع';

  @override
  String get settingsFactoryResetWarning =>
      'سيؤدي هذا إلى حذف جميع البيانات نهائياً. أدخل رمز إعادة الضبط للمتابعة.';

  @override
  String get settingsDeveloper => 'المطوّر';

  @override
  String get developerTitle => 'لوحة المطوّر';

  @override
  String get developerGenerateCode => 'توليد رمز تفعيل';

  @override
  String get developerStoreName => 'اسم المتجر / مرجع';

  @override
  String get developerLicenseTier => 'مدة الترخيص';

  @override
  String get developerTier1Month => 'شهر واحد (تجريبي)';

  @override
  String get developerTier3Months => '3 أشهر';

  @override
  String get developerTier6Months => '6 أشهر';

  @override
  String get developerTier12Months => '12 شهراً';

  @override
  String get developerTierLifetime => 'مدى الحياة';

  @override
  String get developerCodeGenerated => 'تم توليد رمز التفعيل';

  @override
  String get developerRecentCodes => 'الرموز المولّدة مؤخراً';

  @override
  String get errorGeneric => 'حدث خطأ ما. الرجاء المحاولة مجدداً';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorNoConnection => 'لا يوجد اتصال بالطابعة';

  @override
  String get errorInsufficientStock => 'الكمية المتوفرة في المخزون غير كافية';

  @override
  String get settingsCurrency => 'العملة';

  @override
  String get currencyIqd => 'دينار عراقي (IQD)';

  @override
  String get currencyUsd => 'دولار أمريكي (USD)';

  @override
  String get receiptSale => 'فاتورة';

  @override
  String get receiptCashier => 'الكاشير';

  @override
  String get receiptCustomer => 'الزبون';

  @override
  String get receiptSubtotal => 'المجموع الفرعي';

  @override
  String get receiptTax => 'الضريبة';

  @override
  String get receiptPayment => 'طريقة الدفع';

  @override
  String get receiptTendered => 'المدفوع';

  @override
  String get receiptCash => 'نقداً';

  @override
  String get receiptCard => 'بطاقة';

  @override
  String get receiptThankYou => 'شكراً لتسوقكم معنا!';

  @override
  String offlinePendingSales(int count) {
    return '$count بانتظار الإرسال';
  }

  @override
  String get offlineSaleSaved =>
      'لا يوجد إنترنت — تم حفظ البيع على الجهاز وسيُرسل تلقائياً';

  @override
  String get settingsExchangeRate => 'سعر صرف الدولار';

  @override
  String get settingsExchangeRateHint =>
      'كم دينار مقابل 1 دولار. اتركه فارغاً لإخفاء أسعار الدولار.';

  @override
  String posPaidIn(String currency) {
    return 'مدفوع بـ $currency';
  }

  @override
  String get importProductsTitle => 'استيراد المنتجات من Excel';

  @override
  String get importProductsHelp =>
      'استخدم ملف Excel (.xlsx) أو CSV يحتوي الصف الأول فيه على أسماء الأعمدة. الاسم وسعر البيع مطلوبان؛ أما الكلفة وسعر الجملة والباركود والفئة والوحدة والكمية وتاريخ الانتهاء فاختيارية. المنتجات التي يوجد باركودها مسبقاً يتم تحديثها.';

  @override
  String get importDownloadTemplate => 'تنزيل نموذج';

  @override
  String get importChooseFile => 'اختيار ملف';

  @override
  String get importTemplateSaved => 'تم حفظ النموذج';

  @override
  String get importReadFailed =>
      'تعذّرت قراءة الملف. احفظه بصيغة ‎.xlsx أو ‎.csv وحاول مجدداً.';

  @override
  String importRowsReady(int count) {
    return '$count منتج جاهز للاستيراد';
  }

  @override
  String importMissingColumn(String column) {
    return 'الملف لا يحتوي على عمود \"$column\"';
  }

  @override
  String importRowProblem(int row, String column) {
    return 'الصف $row: $column مفقود أو غير صالح';
  }

  @override
  String get importProductsAction => 'استيراد';

  @override
  String importDone(int created, int updated) {
    return 'تم: إضافة $created وتحديث $updated';
  }

  @override
  String importFailedRows(String rows) {
    return 'تعذّر حفظ الصفوف: $rows';
  }

  @override
  String get commonOptional => 'اختياري';

  @override
  String get inventoryWholesalePrice => 'سعر الجملة';

  @override
  String get inventoryExpiryDate => 'تاريخ الانتهاء';

  @override
  String get posWholesalePrices => 'أسعار الجملة';

  @override
  String get whatsappSendReceipt => 'إرسال الفاتورة عبر واتساب';

  @override
  String get whatsappPhone => 'رقم واتساب الزبون';

  @override
  String get whatsappSend => 'فتح واتساب';

  @override
  String get whatsappInvalidPhone => 'أدخل رقم هاتف صحيح';

  @override
  String get posCustomerPhone => 'هاتف الزبون';

  @override
  String get posCustomerPhoneHint => 'اختياري — لتذكيره بالدفع عبر واتساب';

  @override
  String get debtsNone => 'لا توجد ديون مستحقة';

  @override
  String get debtsTotalOutstanding => 'إجمالي الديون';

  @override
  String debtsSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فاتورة',
      few: '$count فواتير',
      two: 'فاتورتان',
      one: 'فاتورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String debtsDaysOutstanding(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get debtsSendReminder => 'إرسال تذكير عبر واتساب';

  @override
  String debtsReminderMessage(String name, String store, String amount) {
    return 'مرحباً $name، نود تذكيركم بأن المبلغ المتبقي عليكم لدى $store هو $amount. شكراً لكم!';
  }

  @override
  String get expiryTitle => 'قريبة الانتهاء';

  @override
  String expiryWithinDays(int days) {
    return 'خلال $days يوم';
  }

  @override
  String get expiryNone => 'لا توجد منتجات تنتهي خلال هذه الفترة';

  @override
  String expiryInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بعد $days يوم',
      one: 'غداً',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String expiryExpiredDaysAgo(int days) {
    return 'منتهي منذ $days يوم';
  }

  @override
  String expiryExpiredCount(int count) {
    return '$count منتهية الصلاحية';
  }

  @override
  String get reportsToday => 'اليوم';

  @override
  String get reportsLast7Days => '7 أيام';

  @override
  String get reportsLast30Days => '30 يوم';

  @override
  String get reportsRevenue => 'المبيعات';

  @override
  String get reportsProfit => 'الربح';

  @override
  String reportsMargin(int percent) {
    return 'هامش $percent%';
  }

  @override
  String get reportsSalesCount => 'عدد الفواتير';

  @override
  String get reportsAverageSale => 'متوسط الفاتورة';

  @override
  String get reportsSalesByHour => 'المبيعات حسب الساعة';

  @override
  String get reportsSalesByDay => 'المبيعات حسب اليوم';

  @override
  String reportsSalesShort(int count) {
    return '$count فاتورة';
  }

  @override
  String get reportsNoSales => 'لا توجد مبيعات في هذه الفترة';

  @override
  String get reportsByPaymentMethod => 'طرق الدفع';

  @override
  String get reportsTopProducts => 'الأكثر مبيعاً';

  @override
  String get reportsNothingLow => 'لا يوجد منتج تحت حد الطلب';

  @override
  String reportsReorderAt(int level) {
    return 'حد الطلب $level';
  }

  @override
  String get loyaltyTitle => 'نقاط الولاء';

  @override
  String get loyaltySettingsHelp =>
      'يكسب الزبون نقطة واحدة عن كل مبلغ أدناه يشتري به، ويمكنه استخدام النقاط كخصم.';

  @override
  String get loyaltySpendPerPoint => 'المبلغ مقابل نقطة واحدة';

  @override
  String get loyaltyPointValue => 'قيمة النقطة الواحدة';

  @override
  String get loyaltyNoCustomer => 'بدون زبون (نقاط الولاء)';

  @override
  String get loyaltyChooseCustomer => 'اختيار زبون';

  @override
  String get loyaltyNewCustomer => 'زبون جديد';

  @override
  String get loyaltyNoMatches => 'لا يوجد زبائن مطابقون';

  @override
  String loyaltyPointsBalance(int points) {
    return '$points نقطة';
  }

  @override
  String loyaltyUsePoints(int max) {
    return 'استخدام النقاط (حتى $max)';
  }

  @override
  String loyaltyPointWorth(String value) {
    return 'النقطة = $value';
  }

  @override
  String get loyaltyPointsRedeemed => 'نقاط مستخدمة';

  @override
  String get loyaltyPointsEarned => 'نقاط مكتسبة';

  @override
  String get loyaltyBalance => 'رصيد النقاط';

  @override
  String get backupNoFolder =>
      'لم يتم اختيار مجلد — النسخ التلقائي يُحفظ في مجلد مستندات التطبيق';

  @override
  String get backupChooseFolder => 'اختيار مجلد';

  @override
  String backupAutoHelp(String time, int keep) {
    return 'مرة يومياً، في أي وقت يكون التطبيق مفتوحاً بعد الساعة $time. يتم الاحتفاظ بآخر $keep نسخة تلقائية.';
  }

  @override
  String backupTime(String time) {
    return 'وقت النسخ: $time';
  }

  @override
  String get backupTypeAutomatic => 'تلقائي';

  @override
  String get backupTypeManual => 'يدوي';

  @override
  String get backupRestoreWarningLocal =>
      'سيتم استبدال كل البيانات الحالية على هذا الجهاز بالنسخة الاحتياطية. هل تريد المتابعة؟';

  @override
  String get backupRestoreWarningCloud =>
      'ستُعاد السجلات الموجودة في النسخة إلى بيانات المتجر السحابية وتستبدل نسخها الحالية. ما أُضيف بعد النسخة يبقى كما هو. هل تريد المتابعة؟';

  @override
  String get backupRestoreDone => 'تمت الاستعادة';

  @override
  String get backupRestoreReopen =>
      'أغلق UNOPOS وافتحه من جديد لتحميل البيانات المستعادة.';

  @override
  String get unitPacket => 'باكيت';

  @override
  String get unitTikka => 'تكة';

  @override
  String get unitBale => 'بالة / شليف';

  @override
  String get unitGram => 'غرام';

  @override
  String get unitMilliliter => 'ملي لتر';

  @override
  String get navCustomers => 'الزبائن';

  @override
  String get hrPasscodeNew => 'رمز الدخول (4 أرقام)';

  @override
  String get hrPasscodeReset =>
      'رمز دخول جديد (اتركه فارغاً للإبقاء على الحالي)';

  @override
  String get permissionsTitle => 'الصلاحيات';

  @override
  String get permissionsOwnerAll => 'المالك لديه جميع الصلاحيات دائماً.';

  @override
  String get permissionSell => 'البيع (شاشة الكاشير)';

  @override
  String get permissionGiveDiscount => 'إعطاء خصومات';

  @override
  String get permissionProcessReturns => 'إرجاع المبيعات';

  @override
  String get permissionDebts => 'الديون';

  @override
  String get permissionCustomers => 'الزبائن';

  @override
  String get permissionInventory => 'عرض المخزون';

  @override
  String get permissionEditProducts => 'إضافة وتعديل المنتجات';

  @override
  String get permissionSuppliers => 'الموردون';

  @override
  String get permissionExpenses => 'المصاريف والصندوق';

  @override
  String get permissionAccounting => 'المحاسبة';

  @override
  String get permissionReports => 'التقارير';

  @override
  String get permissionHr => 'الموظفون';

  @override
  String get permissionSettings => 'الإعدادات';

  @override
  String get posLineDiscount => 'خصم على هذا المنتج';

  @override
  String get posInvoiceDiscount => 'خصم على الفاتورة';

  @override
  String get posDiscountPercent => 'نسبة الخصم %';

  @override
  String get posDiscountAmount => 'مبلغ الخصم';

  @override
  String get posRemoveDiscount => 'إزالة الخصم';

  @override
  String get settingsKeepMargin => 'الاحتفاظ بهامش ربح 5% عند خصم 100%';

  @override
  String get settingsKeepMarginHelp =>
      'عند الخصم الكامل يُحسب سعر الكلفة مضافاً إليه 5% بدلاً من إعطاء المنتج مجاناً.';

  @override
  String get customerWalkIn => 'زبون نقدي عابر';

  @override
  String get customersNone => 'لا يوجد زبائن بعد';

  @override
  String get customersTotalSales => 'إجمالي المشتريات';

  @override
  String get customersOwes => 'عليه دين';

  @override
  String get licenseExpiredTitle => 'انتهى الاشتراك';

  @override
  String licenseExpiredOn(String date) {
    return 'انتهى في $date';
  }

  @override
  String get licenseExpiredHelp =>
      'أدخل كود تفعيل جديد لمواصلة استخدام UNOPOS. بياناتك محفوظة وستجدها كما هي عند المتابعة.';

  @override
  String get activationAlreadyUsed =>
      'لا يمكن استخدام هذا الكود (مستخدم مسبقاً أو غير موجود).';

  @override
  String get developerTier2Weeks => 'تجربة أسبوعين';

  @override
  String get developerCodeNotActivated => 'لم يُفعَّل بعد';

  @override
  String developerCodeActivatedBy(String store) {
    return 'مُفعَّل من قِبل $store';
  }

  @override
  String developerCodeActivatedOn(String date) {
    return 'تاريخ التفعيل $date';
  }

  @override
  String developerCodeExpiresIn(int days, String date) {
    return 'ينتهي بعد $days يوم ($date)';
  }

  @override
  String developerCodeExpiredOn(String date) {
    return 'انتهى في $date';
  }

  @override
  String get developerLocalStatusNote =>
      'النسخة المحلية: يظهر فقط التفعيل الذي تم على هذا الجهاز.';

  @override
  String get roleDeveloper => 'المطوّر';

  @override
  String get expenseType => 'نوع المصروف';

  @override
  String get expenseCategory => 'البند';

  @override
  String get expenseCustomName => 'اسم النوع المخصص';

  @override
  String get expenseEditType => 'تعديل نوع المصروف';

  @override
  String get expenseGroupFixed => 'ثابتة';

  @override
  String get expenseGroupVariable => 'متغيرة';

  @override
  String get expenseGroupNegligible => 'مهملة';

  @override
  String get expenseGroupCustom => 'مخصص';

  @override
  String get expenseRent => 'الإيجار';

  @override
  String get expenseSalaries => 'رواتب الموظفين';

  @override
  String get expenseGeneratorElectricity => 'الكهرباء (سحب)';

  @override
  String get expenseNationalElectricity => 'الكهرباء (وطني)';

  @override
  String get expenseWater => 'الماء';

  @override
  String get expenseInternet => 'الإنترنت';

  @override
  String get expenseSolarPower => 'الطاقة الشمسية';

  @override
  String get expenseSoftware => 'البرامج';

  @override
  String get expenseMaterials => 'المواد';

  @override
  String get expenseTransport => 'النقل';

  @override
  String get expenseCleaningSupplies => 'المنظفات';

  @override
  String get expensePackaging => 'التغليف';

  @override
  String get expenseDeliveryAppCommission => 'عمولة تطبيقات التوصيل';

  @override
  String get expenseWasteAndDamage => 'الهدر والتالف';

  @override
  String get expenseMaintenance => 'الصيانة';

  @override
  String get expenseStaffMeals => 'أكل الموظفين';

  @override
  String get expenseAnnualFees => 'الرسوم السنوية (الصحة والبلدية)';

  @override
  String get expenseHospitality => 'الضيافة';

  @override
  String get expensesThisMonth => 'مصاريف هذا الشهر';

  @override
  String get expensesThisYear => 'مصاريف هذه السنة';

  @override
  String get expensesMonth => 'الشهر';

  @override
  String get expensesYear => 'السنة';

  @override
  String get expensesNone => 'لا توجد مصاريف مسجلة في هذه الفترة';

  @override
  String get expensesUntyped => 'المصاريف القديمة بدون نوع غير محسوبة هنا.';

  @override
  String get devStores => 'المتاجر';

  @override
  String get devPlans => 'الخطط';

  @override
  String get devLicenses => 'التراخيص';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get devAuditLog => 'سجل العمليات';

  @override
  String errorWithDetails(String details) {
    return 'حدث خطأ: $details';
  }

  @override
  String devEditPlanLimits(String plan) {
    return 'تعديل حدود الخطة: $plan';
  }

  @override
  String get devMaxEmployees => 'أقصى عدد للموظفين';

  @override
  String get devMaxBranches => 'أقصى عدد للفروع';

  @override
  String get devMaxProducts => 'أقصى عدد للمنتجات';

  @override
  String get devMaxUsers => 'أقصى عدد للمستخدمين';

  @override
  String get devMaxWarehouses => 'أقصى عدد للمخازن';

  @override
  String get devMaxStorage => 'أقصى مساحة تخزين (ميغابايت)';

  @override
  String get devMaxDailyTransactions => 'أقصى عدد مبيعات يومياً';

  @override
  String devPlanSummary(
    int employees,
    int branches,
    int products,
    int daily,
    int storage,
  ) {
    return 'الموظفون: $employees · الفروع: $branches · المنتجات: $products · المبيعات اليومية: $daily · التخزين: $storage ميغابايت';
  }

  @override
  String get devTotalStores => 'إجمالي المتاجر';

  @override
  String get devOnTrial => 'تجريبي';

  @override
  String get devActiveSubscriptions => 'اشتراكات فعالة';

  @override
  String get devExpired => 'منتهية';

  @override
  String get devDisabled => 'معطّل';

  @override
  String get devSuspended => 'موقوف';

  @override
  String get devNoStores => 'لا توجد متاجر بعد';

  @override
  String get commonDone => 'تم';

  @override
  String get devEditStore => 'تعديل المتجر';

  @override
  String get devOwnerName => 'المالك';

  @override
  String get devChangePlan => 'تغيير الخطة';

  @override
  String get devResetStorePassword => 'إعادة تعيين كلمة مرور المتجر';

  @override
  String get devNewPassword => 'كلمة المرور الجديدة';

  @override
  String get devReset => 'إعادة تعيين';

  @override
  String get devPasswordWasReset => 'تمت إعادة تعيين كلمة المرور';

  @override
  String get devSubscriptionExtended => 'تم تمديد الاشتراك';

  @override
  String get devGenerateAssignLicense => 'توليد كود وتعيينه للمتجر';

  @override
  String devLicenseAssigned(String code) {
    return 'تم التعيين: $code';
  }

  @override
  String get devLicenseKey => 'الترخيص';

  @override
  String get devExpires => 'ينتهي';

  @override
  String get devNever => 'لا ينتهي';

  @override
  String get devEnable => 'تفعيل';

  @override
  String get devDisable => 'تعطيل';

  @override
  String get devSuspend => 'إيقاف مؤقت';

  @override
  String get devUnsuspend => 'استئناف';

  @override
  String get devExtendSubscription => 'تمديد الاشتراك';

  @override
  String get devGenerateLicense => 'توليد كود';

  @override
  String get devResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get devDeleteStore => 'حذف المتجر';

  @override
  String devDeleteStoreWarning(String store) {
    return 'سيتم حذف \"$store\" نهائياً مع جميع بياناته (المبيعات والمخزون والحسابات — كل شيء). لا يمكن التراجع عن ذلك.';
  }

  @override
  String get devNotificationSent => 'تم إرسال الإشعار';

  @override
  String get devTitle => 'العنوان';

  @override
  String get devMessage => 'الرسالة';

  @override
  String get devTarget => 'إرسال إلى';

  @override
  String get devAllStores => 'كل المتاجر';

  @override
  String get devNoAuditEntries => 'لا توجد عمليات مسجلة بعد';

  @override
  String get devStatusActive => 'فعّال';

  @override
  String get devStatusTrial => 'تجريبي';

  @override
  String get devStatusPending => 'قيد الانتظار';

  @override
  String get devStatusRevoked => 'ملغى';

  @override
  String get acctRevenue => 'الإيرادات';

  @override
  String get acctCogs => 'كلفة البضاعة المباعة';

  @override
  String get acctExpenses => 'المصاريف';

  @override
  String get acctNetIncome => 'صافي الربح';

  @override
  String get acctAssets => 'الأصول';

  @override
  String get acctLiabilities => 'الالتزامات';

  @override
  String get acctEquity => 'حقوق الملكية';

  @override
  String get acctNetIncomeNote =>
      'ملاحظة: صافي ربح الفترة الحالية لا يُضاف إلى حقوق الملكية إلا بعد تسجيل قيد إقفال الفترة (غير مؤتمت بعد).';

  @override
  String get acctDebitTotal => 'مجموع الجانب المدين';

  @override
  String get acctCreditTotal => 'مجموع الجانب الدائن';

  @override
  String get acctBalanced => 'الحسابات متوازنة ✓';

  @override
  String get acctNotBalanced => 'الحسابات غير متوازنة — راجع القيود';

  @override
  String get acctDebit => 'مدين';

  @override
  String get acctCredit => 'دائن';

  @override
  String get acctRevenueType => 'الإيرادات';

  @override
  String get inventoryCatalog => 'الأصناف';

  @override
  String get discountPercentOff => 'خصم %';

  @override
  String get discountAmountOff => 'خصم بمبلغ';

  @override
  String get discountsTitle => 'الخصومات المحفوظة';

  @override
  String get taxRatePercent => 'النسبة %';

  @override
  String get taxDefaultForNew => 'افتراضي للمنتجات الجديدة';

  @override
  String get taxRatesTitle => 'نسب الضريبة';

  @override
  String get taxDefault => 'افتراضي';

  @override
  String get taxRate => 'نسبة الضريبة';

  @override
  String get transferIncoming => 'وارد';

  @override
  String get transferOutgoing => 'صادر';

  @override
  String get transferOneBranchOnly =>
      'هذا المتجر لديه فرع واحد فقط — لا يوجد فرع للتحويل إليه.';

  @override
  String get transferToBranch => 'إلى الفرع';

  @override
  String get addProductLine => 'إضافة منتج';

  @override
  String get actionReceive => 'استلام';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get poShort => 'طلب شراء';

  @override
  String get poNew => 'طلب شراء جديد';

  @override
  String get poSupplier => 'المورد';

  @override
  String get poNeedSupplierAndProduct =>
      'أضف مورداً ومنتجاً واحداً على الأقل أولاً.';

  @override
  String get commonNone => 'بدون';

  @override
  String get inventorySku => 'رمز المنتج (SKU)';

  @override
  String get inventoryCostPrice => 'سعر الكلفة';

  @override
  String get inventoryReorderLevel => 'حد إعادة الطلب';

  @override
  String get printerType => 'نوع الطابعة';

  @override
  String get printerNetwork => 'طابعة حرارية شبكة / واي فاي (ESC/POS)';

  @override
  String get printerUsb => 'طابعة حرارية USB';

  @override
  String get printerBluetooth => 'طابعة حرارية بلوتوث';

  @override
  String get printerSystem => 'طابعة النظام (ويندوز)';

  @override
  String get printerPaperWidth => 'عرض الورق';

  @override
  String get printerTestOk => 'متصلة';

  @override
  String get printerTestFailed => 'تعذّر الاتصال';

  @override
  String get printerTestConnection => 'اختبار الاتصال';

  @override
  String get settingsDefaultVat => 'ضريبة القيمة المضافة الافتراضية %';

  @override
  String get factoryResetDone => 'تمت إعادة الضبط';

  @override
  String get factoryResetDoneHelp =>
      'تم مسح جميع البيانات. أغلق UNOPOS وافتحه من جديد للبدء من الصفر.';

  @override
  String get notificationsNone => 'لا توجد إشعارات';

  @override
  String get hrDeactivate => 'إيقاف الحساب';

  @override
  String get shiftCountedCash => 'النقد المعدود في الصندوق';

  @override
  String get supplierContactPerson => 'الشخص المسؤول';

  @override
  String get barcodeScan => 'مسح';

  @override
  String get barcodeScanTitle => 'مسح الباركود';

  @override
  String get tilePickerNoEmployees => 'لا يوجد موظفون لهذا المتجر.';

  @override
  String dashboardSalesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فاتورة اليوم',
      few: '$count فواتير اليوم',
      two: 'فاتورتان اليوم',
      one: 'فاتورة واحدة اليوم',
      zero: 'لا مبيعات اليوم',
    );
    return '$_temp0';
  }

  @override
  String get journalSale => 'بيع';

  @override
  String get journalPurchase => 'شراء';

  @override
  String get journalSupplierPayment => 'دفعة لمورد';

  @override
  String get journalDebtPayment => 'تسديد دين';

  @override
  String get journalExpense => 'مصروف';

  @override
  String get journalReturn => 'إرجاع';

  @override
  String get journalAdjustment => 'تسوية';

  @override
  String get journalManual => 'قيد يدوي';

  @override
  String get journalOpeningBalance => 'رصيد افتتاحي';

  @override
  String get acctTypeCogs => 'كلفة المبيعات';

  @override
  String get account1000 => 'النقد في الصندوق';

  @override
  String get account1010 => 'الحساب المصرفي';

  @override
  String get account1100 => 'ديون الزبائن (مدينون)';

  @override
  String get account1200 => 'المخزون';

  @override
  String get account2000 => 'ديون الموردين (دائنون)';

  @override
  String get account2100 => 'ضريبة المبيعات المستحقة';

  @override
  String get account3000 => 'رأس مال المالك';

  @override
  String get account3100 => 'الأرباح المحتجزة';

  @override
  String get account4000 => 'إيرادات المبيعات';

  @override
  String get account4100 => 'مرتجعات المبيعات';

  @override
  String get account4200 => 'الخصومات الممنوحة';

  @override
  String get account5000 => 'كلفة البضاعة المباعة';

  @override
  String get account6000 => 'الإيجار';

  @override
  String get account6010 => 'الخدمات (كهرباء، ماء، إنترنت)';

  @override
  String get account6020 => 'الرواتب والأجور';

  @override
  String get account6030 => 'المستلزمات';

  @override
  String get account6040 => 'مصاريف عامة';

  @override
  String get account6050 => 'رسوم البطاقات';

  @override
  String get account6060 => 'نقص المخزون';

  @override
  String transferItemCount(int count) {
    return '$count مادة';
  }

  @override
  String get memoCashSale => 'بيع نقدي';

  @override
  String get memoCardSale => 'بيع بالبطاقة';

  @override
  String get memoPayLaterSale => 'بيع بالآجل (على الحساب)';

  @override
  String get memoDebtPayment => 'استلام دفعة دين من زبون';

  @override
  String get memoPurchasePaid => 'شراء من مورد (مدفوع)';

  @override
  String get memoPurchaseCredit => 'شراء من مورد (بالآجل)';

  @override
  String get memoSupplierPayment => 'دفعة إلى مورد';

  @override
  String get memoSaleReturn => 'مرتجع مبيعات / استرداد';

  @override
  String get memoShrinkage => 'نقص مخزون / تسوية';

  @override
  String get printerAddressNetwork =>
      'عنوان IP:المنفذ (مثال 192.168.1.50:9100)';

  @override
  String get printerAddressGeneric => 'عنوان الاتصال';

  @override
  String get pickBranchTitle => 'اختر الفرع';

  @override
  String get pickBranchChange => 'تغيير الفرع';

  @override
  String get pickBranchMain => 'الفرع الرئيسي';

  @override
  String get errorPasswordTooShort =>
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get errorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get errorStoreIdFormat =>
      'استخدم حروفًا إنجليزية وأرقامًا فقط، بدون مسافات';

  @override
  String get errorStoreIdTaken => 'معرّف المتجر هذا مستخدم — اختر معرّفًا آخر';

  @override
  String get returnInvoice => 'استرجاع فاتورة';

  @override
  String get returnInvoiceNumber => 'رقم الفاتورة';

  @override
  String get returnInvoiceNumberHint => 'مثال: 125 أو S-000125';

  @override
  String get returnFind => 'بحث عن الفاتورة';

  @override
  String get returnNotFound => 'لا توجد فاتورة بهذا الرقم';

  @override
  String get returnNothingLeft => 'تم استرجاع كل مواد هذه الفاتورة مسبقاً';

  @override
  String get returnNotReturnable => 'لا يمكن استرجاع هذه الفاتورة';

  @override
  String get returnAll => 'استرجاع الكل';

  @override
  String get returnRefund => 'المبلغ المسترجع';

  @override
  String get returnRefundTo => 'إرجاع المبلغ';

  @override
  String returnSoldReturned(int sold, int returned) {
    return 'المباع $sold · المسترجع $returned';
  }

  @override
  String returnDone(String amount) {
    return 'تم الاسترجاع — المبلغ المسترجع $amount';
  }

  @override
  String get returnFailed => 'لم يتم الاسترجاع — تحقق من الاتصال وحاول مجدداً';

  @override
  String get returnStatusRefunded => 'مسترجعة';

  @override
  String get returnStatusPartial => 'مسترجعة جزئياً';

  @override
  String get returnWhatHappens =>
      'ترجع الكمية للمخزون، وتنقص المبيعات والربح، ويُرجع المبلغ للزبون.';
}
