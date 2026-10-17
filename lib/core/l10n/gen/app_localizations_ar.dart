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
      'ستُعاد السجلات الموجودة في النسخة والمحذوفة من المتجر. السجلات الموجودة حالياً (وكل ما أُضيف بعد النسخة) تبقى كما هي. هل تريد المتابعة؟';

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

  @override
  String get actionFullScreen => 'ملء الشاشة (F11)';

  @override
  String get actionExitFullScreen => 'الخروج من ملء الشاشة (F11)';

  @override
  String get posScanHint => 'امسح الباركود أو ابحث عن منتج';

  @override
  String posBarcodeNotFound(String code) {
    return 'لا يوجد منتج فعّال بالرمز $code';
  }

  @override
  String get posNoProductsFound => 'لا توجد منتجات مطابقة';

  @override
  String posHeldItems(int count) {
    return '$count قطعة';
  }

  @override
  String get posHeldInCart => 'مفتوحة في السلة';

  @override
  String get posHeldSaleClosed =>
      'هذه الفاتورة المعلّقة أُكملت أو أُلغيت مسبقاً (ربما على جهاز آخر). لم يُسجَّل أي مبلغ.';

  @override
  String get posSaleHeld => 'تم تعليق الفاتورة';

  @override
  String get payAmountDue => 'المبلغ المطلوب';

  @override
  String get payReceived => 'المبلغ المستلم';

  @override
  String get payPaidNow => 'المدفوع الآن (اختياري)';

  @override
  String get payRemaining => 'المتبقي';

  @override
  String get payOnAccount => 'دين على الزبون';

  @override
  String get payExact => 'المبلغ بالضبط';

  @override
  String get payClear => 'مسح';

  @override
  String get payInsufficient =>
      'المبلغ المستلم أقل من المجموع. استلم الباقي أو سجّله ديناً على الزبون.';

  @override
  String get payRestOnAccount => 'تسجيل الباقي ديناً';

  @override
  String get payCustomerNeeded => 'اختر الزبون أو اكتب اسمه للبيع بالآجل.';

  @override
  String get payPaidNowTooMuch => 'المبلغ مدفوع بالكامل: اختر نقداً أو بطاقة.';

  @override
  String get printModeTitle => 'بعد إتمام البيع';

  @override
  String get printModeAuto => 'طباعة تلقائية';

  @override
  String get printModeAsk => 'السؤال قبل الطباعة';

  @override
  String get printModeOff => 'بدون طباعة';

  @override
  String get printAskTitle => 'طباعة الفاتورة؟';

  @override
  String get printAction => 'طباعة';

  @override
  String get printSkip => 'تخطي';

  @override
  String printFailed(String reason) {
    return 'تم حفظ البيع، لكن فشلت الطباعة: $reason';
  }

  @override
  String get printRetry => 'إعادة المحاولة';

  @override
  String get printNoPrinter => 'لا توجد طابعة مضبوطة (الإعدادات ← الطابعة).';

  @override
  String get branchCurrent => 'الفرع الحالي';

  @override
  String get tilePickerLoadFailed =>
      'تعذّر تحميل الحسابات. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get loyaltySpendPerPointHelp =>
      'الكسب: يحصل الزبون على نقطة واحدة عن كل هذا المبلغ';

  @override
  String get loyaltyPointValueHelp =>
      'الاستخدام: قيمة الخصم الذي تعطيه النقطة الواحدة عند الدفع';

  @override
  String get navInvoices => 'الفواتير';

  @override
  String get invoiceStatusCompleted => 'مكتملة';

  @override
  String get invoiceStatusCancelled => 'ملغاة';

  @override
  String get invoiceStatusUnpaid => 'غير مدفوعة';

  @override
  String get invoiceStatusPartiallyPaid => 'مدفوعة جزئياً';

  @override
  String get invoiceStatusPaid => 'مدفوعة';

  @override
  String get invoiceSearchHint => 'رقم الفاتورة أو اسم الزبون';

  @override
  String get invoiceAnyDate => 'كل التواريخ';

  @override
  String get invoiceAllBranches => 'كل الفروع';

  @override
  String get invoiceAnyPayment => 'كل طرق الدفع';

  @override
  String get invoiceAnyCashier => 'كل الكاشيرية';

  @override
  String get invoiceAnyStatus => 'كل الحالات';

  @override
  String get invoiceNone => 'لا توجد فواتير مطابقة';

  @override
  String get invoiceSortNewest => 'الأحدث أولاً';

  @override
  String get invoiceSortOldest => 'الأقدم أولاً';

  @override
  String get invoiceSortNumberDesc => 'الرقم (تنازلي)';

  @override
  String get invoiceSortNumberAsc => 'الرقم (تصاعدي)';

  @override
  String get invoiceSortAmountDesc => 'المبلغ (الأعلى أولاً)';

  @override
  String get invoiceSortAmountAsc => 'المبلغ (الأقل أولاً)';

  @override
  String get invoiceCreditCustomer => 'زبون آجل';

  @override
  String get invoiceTitle => 'فاتورة';

  @override
  String get invoiceDate => 'التاريخ';

  @override
  String get invoiceBranch => 'الفرع';

  @override
  String get invoiceNetTotal => 'الصافي بعد الإرجاع';

  @override
  String get invoicePaid => 'المدفوع';

  @override
  String get invoicePaymentHistory => 'سجل الدفعات';

  @override
  String get invoiceNoPayments => 'لا توجد دفعات بعد';

  @override
  String get invoiceReprint => 'إعادة الطباعة';

  @override
  String get printPreview => 'معاينة';

  @override
  String get printSample => 'نموذج';

  @override
  String get receiptItem => 'المادة';

  @override
  String get invoiceTemplateTitle => 'قالب الفاتورة';

  @override
  String get invoicePaper => 'الورق';

  @override
  String get invoicePaperThermal => 'رول حراري';

  @override
  String get invoiceStyle => 'الشكل';

  @override
  String get invoiceStyleClassic => 'كلاسيكي';

  @override
  String get invoiceStyleModern => 'حديث';

  @override
  String get invoiceStyleCompact => 'مضغوط';

  @override
  String get invoiceBranding => 'معلومات المتجر على الفاتورة';

  @override
  String get invoiceLogoChoose => 'اختيار الشعار';

  @override
  String get invoiceLogoChange => 'تغيير الشعار';

  @override
  String get invoiceLogoShow => 'طباعة الشعار';

  @override
  String get invoiceBrandName => 'اسم المتجر على الفاتورة';

  @override
  String get invoiceBrandDefaultHint =>
      'اتركه فارغاً لاستخدام اسم المتجر وهاتف الفرع وعنوانه';

  @override
  String get invoiceFooter => 'رسالة أسفل الفاتورة / الشكر';

  @override
  String get settingsSaved => 'تم الحفظ';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get imageTooLarge => 'الصورة كبيرة جداً (5 ميغابايت كحد أقصى).';

  @override
  String get imageWrongType => 'اختر صورة بصيغة PNG أو JPG أو WebP.';

  @override
  String get printerAskEachTime => 'السؤال عن الطابعة في كل مرة';

  @override
  String get printerSystemHelp => 'اختر طابعة للطباعة عليها مباشرة بدون نافذة.';

  @override
  String get printerChoose => 'اختيار الطابعة';

  @override
  String get productCodeInvalidChars => 'استخدم الحروف والأرقام و - _ . فقط';

  @override
  String get productCodeTooLong => 'طويل جداً (64 حرفاً كحد أقصى)';

  @override
  String get productCodeBadCheckDigit =>
      'رقم التحقق في هذا الباركود خاطئ — تأكد من كتابته بشكل صحيح';

  @override
  String productCodeTaken(String name) {
    return 'مستخدم مسبقاً للمنتج \"$name\"';
  }

  @override
  String get productCodeHelp =>
      'امسح باركود المنتج أو اكتبه، أو اضغط ✨ لتوليد واحد';

  @override
  String get productCodeGeneratedInfo =>
      'يُحفظ هذا الباركود مع المنتج. تجده في المخزون ← المنتجات (زر الملصق) لطباعته ولصقه على المنتج، ومسحه عند الكاشير يضيف هذا المنتج.';

  @override
  String get productSkuOptional => 'الرمز الداخلي (SKU) — اختياري';

  @override
  String get productSkuHelp =>
      'اتركه فارغاً لاستخدام الباركود. البحث أو المسح بأي من الرمزين يجد المنتج.';

  @override
  String get productPhotoChoose => 'إضافة صورة';

  @override
  String get productPhotoChange => 'تغيير الصورة';

  @override
  String get productOpeningStock => 'الكمية الابتدائية في المخزون';

  @override
  String productStockInBranch(String branch) {
    return 'في فرع: $branch';
  }

  @override
  String get errorQuantityInvalid => 'أدخل كمية صحيحة';

  @override
  String get customerLoyaltyValue => 'قيمة النقاط';

  @override
  String get customerLoyaltyMember =>
      'عضو في برنامج الولاء — يكسب نقاطاً مع كل شراء';

  @override
  String get customerDebts => 'الديون';

  @override
  String get customerNoDebts => 'لا توجد ديون';

  @override
  String get customerInvoices => 'آخر الفواتير';

  @override
  String get confirmYourPin => 'رمزك السري';

  @override
  String get accountOwnerProtected =>
      'لا يمكن إيقاف حساب المالك أو تغيير دوره. نقل الملكية يتم بإجراء منفصل ومصرّح به.';

  @override
  String get accountOnlyOwnerForManager =>
      'فقط المالك يستطيع إيقاف حساب مدير أو تغيير المدراء.';

  @override
  String get accountNotYourself => 'لا يمكنك إيقاف حسابك بنفسك.';

  @override
  String get accountNotAllowed => 'حسابك لا يملك صلاحية هذا الإجراء.';

  @override
  String accountDeactivateConfirm(String name) {
    return 'لن يتمكن $name من تسجيل الدخول بعد الآن. تبقى مبيعاته وسجله محفوظة. أدخل رمزك للتأكيد.';
  }

  @override
  String accountDeactivated(String name) {
    return 'تم إيقاف حساب $name';
  }

  @override
  String accountRoleChangeConfirm(String name) {
    return 'تغيير دور المدير لـ $name يحتاج إلى المالك. أدخل رمزك للتأكيد.';
  }

  @override
  String get activationRevoked =>
      'تم إلغاء هذا الكود من قبل المطوّر. اطلب كوداً جديداً.';

  @override
  String get codeRevoke => 'إلغاء الكود';

  @override
  String get codeRevoked => 'ملغى';

  @override
  String get codeRevokeTitle => 'إلغاء هذا الكود؟';

  @override
  String codeRevokeMessage(String store) {
    return 'لن يعود بالإمكان استخدام كود \"$store\" لتفعيل أي متجر.';
  }

  @override
  String codeRevokeEndStore(String store) {
    return 'إنهاء تفعيل متجر \"$store\" أيضاً';
  }

  @override
  String get codeRevokeEndStoreHelp =>
      'يُقفل ذلك المتجر فقط حتى يُدخل كوداً جديداً. اتركه بدون تحديد ليبقى تفعيله الحالي.';

  @override
  String get codeRemoveTitle => 'حذف هذا الكود؟';

  @override
  String codeRemoveMessage(String store) {
    return 'سيُحذف كود \"$store\" غير المستخدم نهائياً.';
  }

  @override
  String get codeRemoveUsed =>
      'استخدم متجرٌ هذا الكود — قم بإلغائه بدلاً من الحذف.';

  @override
  String get breakStart => 'أخذ استراحة';

  @override
  String breakStartConfirm(int minutes, int perDay) {
    return 'الاستراحة حتى $minutes دقيقة، و$perDay مرات في اليوم. يُقفل الجهاز حتى تعود وتُدخل رمزك، وتبقى ورديتك مفتوحة.';
  }

  @override
  String get breakOff => 'الاستراحات متوقفة.';

  @override
  String get breakRoleNotAllowed => 'دورك لا يسمح بالاستراحات.';

  @override
  String get breakAlreadyOn => 'أنت في استراحة بالفعل.';

  @override
  String breakNoneLeft(int max) {
    return 'لا توجد استراحات متبقية اليوم ($max في اليوم).';
  }

  @override
  String breakOnBreak(String name) {
    return '$name في استراحة';
  }

  @override
  String get breakTillLocked => 'الجهاز مقفل حتى العودة.';

  @override
  String get breakTimeLeft => 'متبقية';

  @override
  String get breakOverTime => 'تجاوز الوقت المسموح';

  @override
  String get breakEnterPinToReturn => 'عدت؟ أدخل رمزك';

  @override
  String get breakWrongPin =>
      'فقط الموظف الذي في الاستراحة يمكنه إنهاؤها برمزه الخاص.';

  @override
  String get breakExceededTitle => 'تجاوزت الاستراحة الوقت';

  @override
  String breakExceededMessage(int minutes) {
    return 'تجاوزت هذه الاستراحة الحد بـ $minutes دقيقة. سُجّل ذلك في تقرير اليوم للمدير.';
  }

  @override
  String get breakSettingsTitle => 'الاستراحات';

  @override
  String get breakEnable => 'السماح بالاستراحات';

  @override
  String get breakEnableHelp =>
      'يمكن للموظف الابتعاد دون إغلاق ورديته؛ يُقفل الجهاز حتى يعود برمزه.';

  @override
  String get breakMaxMinutes => 'دقائق الاستراحة الواحدة';

  @override
  String get breakMaxPerDay => 'عدد الاستراحات في اليوم';

  @override
  String get breakMinutesRange => 'من 1 إلى 240';

  @override
  String get breakPerDayRange => 'من 1 إلى 10';

  @override
  String get breakRolesTitle => 'من يحق له الاستراحة';

  @override
  String get breakReportTitle => 'استراحات اليوم';

  @override
  String get breakNoneToday => 'لا توجد استراحات اليوم';

  @override
  String breakCount(int count) {
    return '$count اليوم';
  }

  @override
  String get breakStillAway => 'لم يعد بعد';

  @override
  String breakMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get breakEndedEarly => 'انتهت مبكراً';

  @override
  String get breakReconciled => 'أُغلقت عند الدخول التالي';

  @override
  String breakOverBy(int minutes) {
    return 'تجاوز $minutes دقيقة';
  }

  @override
  String get gateLocked => 'رموز خاطئة كثيرة. حاول بعد بضع دقائق.';

  @override
  String get supportSignInTitle => 'دخول موظفي الدعم الفني';

  @override
  String get supportPhoneCopied => 'تم نسخ الرقم';

  @override
  String get supportPhoneLabel => 'هاتف الدعم الفني';

  @override
  String get supportNoMessages => 'لا توجد رسائل بعد';

  @override
  String get supportStartHint =>
      'اكتب سؤالك في الأسفل — سيرد فريق الدعم هنا، وتبقى المحادثة كاملة محفوظة.';

  @override
  String get supportYou => 'أنت';

  @override
  String get supportTeam => 'فريق الدعم';

  @override
  String get supportNotSent => 'لم تُرسل';

  @override
  String get supportSending => 'جارٍ الإرسال…';

  @override
  String get supportInternalNote => 'ملاحظة داخلية';

  @override
  String get supportNoteHint => 'ملاحظة لفريق الدعم فقط — لن يراها المتجر';

  @override
  String get supportMessageHint => 'اكتب رسالة';

  @override
  String get supportSend => 'إرسال';

  @override
  String get supportTapToRetry => 'اضغط لإعادة الإرسال';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get contactUsHelp => 'تحدث مع فريق الدعم الفني';

  @override
  String get contactUsSignInToChat =>
      'سجّل الدخول إلى متجرك للمحادثة مع الدعم، أو اتصل بنا.';

  @override
  String get supportOffline =>
      'تعذّر الوصول إلى الدعم. تحقق من الاتصال أو اتصل بالرقم أعلاه.';

  @override
  String get supportStatusOpen => 'مفتوحة';

  @override
  String get supportStatusPending => 'قيد الانتظار';

  @override
  String get supportStatusClosed => 'مغلقة';

  @override
  String get supportPickConversation => 'اختر محادثة';

  @override
  String get supportPortalTitle => 'الدعم الفني';

  @override
  String get supportPresenceOnline => 'متصل';

  @override
  String get supportPresenceBreak => 'في استراحة';

  @override
  String get supportPresenceSignedOut => 'سجّل الخروج';

  @override
  String get supportPresenceDisconnected => 'منقطع';

  @override
  String get supportSearchHint => 'اسم المتجر أو المعرّف أو الهاتف';

  @override
  String get supportNoConversations => 'لا توجد محادثات';

  @override
  String get supportStoreId => 'معرّف المتجر';

  @override
  String get supportActivation => 'التفعيل';

  @override
  String get supportOpened => 'بدأت';

  @override
  String get supportLastMessage => 'آخر رسالة';

  @override
  String get supportAssigned => 'المسؤول';

  @override
  String get supportTake => 'استلام';

  @override
  String get supportTakeOver => 'استلام المحادثة';

  @override
  String get supportEmploymentActive => 'فعّال';

  @override
  String get supportEmploymentSuspended => 'موقوف';

  @override
  String get supportEmploymentTerminated => 'منتهي الخدمة';

  @override
  String get supportAgentsTitle => 'حسابات موظفي الدعم الفني';

  @override
  String supportCheckedAt(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String get supportNoAgents => 'لا يوجد موظفو دعم بعد';

  @override
  String supportLastSeen(String time) {
    return 'آخر ظهور $time';
  }

  @override
  String get supportAddAgent => 'إضافة موظف دعم';

  @override
  String get supportAgentCredentialsHint =>
      'أدخل بريداً صحيحاً وكلمة مرور من 8 أحرف على الأقل.';

  @override
  String get supportResetPassword => 'تعيين كلمة مرور جديدة';

  @override
  String get supportPasswordRule => '8 أحرف على الأقل';

  @override
  String supportEmploymentConfirm(String name, String status) {
    return '$name: $status؟ الحساب الموقوف أو المنتهي لا يستطيع الدخول، وتبقى رسائله وسجلاته.';
  }

  @override
  String get supportSalaryAdjustment => 'تعديل على الراتب';

  @override
  String get supportSalaryAdjustments => 'الخصومات والمكافآت';

  @override
  String get supportDeduction => 'خصم';

  @override
  String get supportBonus => 'مكافأة';

  @override
  String get supportReason => 'السبب';

  @override
  String get supportAdjustmentRule => 'أدخل المبلغ والسبب.';

  @override
  String supportCreatedOn(String date) {
    return 'منذ $date';
  }

  @override
  String get supportFullName => 'الاسم الكامل';

  @override
  String get supportJobTitle => 'المسمى الوظيفي';

  @override
  String get supportNotes => 'ملاحظات';

  @override
  String get supportReactivate => 'إعادة التفعيل';

  @override
  String get supportSuspend => 'إيقاف مؤقت';

  @override
  String get supportTerminate => 'إنهاء الخدمة';

  @override
  String get breakOffHowTo =>
      'الاستراحات متوقفة. يستطيع المالك أو المدير تفعيلها من الإعدادات ← الاستراحات.';

  @override
  String get productDelete => 'حذف المنتج';

  @override
  String productDeleteTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get productDeleteMessage =>
      'سيختفي من قائمة المنتجات ومن شاشة البيع. تبقى الفواتير السابقة والمرتجعات وسجل المخزون تعرضه.';

  @override
  String productDeleted(String name) {
    return 'تم حذف \"$name\"';
  }

  @override
  String get stockReceiveTitle => 'إضافة بضاعة للمخزون';

  @override
  String get stockReceiveHelp =>
      'امسح أو ابحث عن كل منتج وصلك، اكتب الكمية، والسعر الجديد (الكلفة أو البيع) فقط إذا تغيّر — اتركه فارغاً ليبقى السعر الحالي.';

  @override
  String get stockReceiveEmpty => 'لم تُضف منتجات بعد';

  @override
  String get stockReceiveNewCost => 'كلفة جديدة';

  @override
  String get stockReceiveNewPrice => 'سعر بيع جديد';

  @override
  String get stockReceiveKeepIfEmpty => 'فارغ = بدون تغيير';

  @override
  String stockReceiveSave(int count) {
    return 'إضافة للمخزون ($count)';
  }

  @override
  String stockReceiveDone(int count) {
    return 'تمت إضافة المخزون لـ $count منتج';
  }

  @override
  String stockReceiveInvalid(String name) {
    return 'تحقق من الكمية والأسعار لـ \"$name\"';
  }

  @override
  String stockReceivePartial(int done, int total) {
    return 'حُفظ $done من $total. تحقق من الاتصال واحفظ الباقي مرة أخرى.';
  }

  @override
  String get statusOnline => 'متصل';

  @override
  String get statusOffline => 'بدون إنترنت';

  @override
  String offlineWithPending(int count) {
    return 'بدون إنترنت · $count بانتظار المزامنة';
  }

  @override
  String syncInProgress(int count) {
    return 'جارٍ المزامنة ($count)…';
  }

  @override
  String get statusOnlineHelp => 'متصل — كل شيء يُحفظ على السيرفر أثناء العمل.';

  @override
  String get statusOfflineHelp =>
      'لا يوجد إنترنت — استمر بالبيع. تُحفظ المبيعات على هذا الجهاز وتُرسل تلقائياً عند عودة الاتصال. اضغط للتحقق الآن.';

  @override
  String posStockLeft(String name, int count) {
    return '$name: باقي $count بالمخزن';
  }

  @override
  String posStockOut(String name) {
    return '$name نفد من المخزن — ما انضاف';
  }

  @override
  String posStockMaxReached(String name, int count) {
    return '$name: الموجود بالمخزن $count بس';
  }

  @override
  String posStockCartAdjusted(String items) {
    return 'المخزن تغيّر وتعدّلت الكميات: $items. راجع السلة وعيد المحاولة.';
  }

  @override
  String posStockBadge(int count) {
    return 'المخزن: $count';
  }

  @override
  String get posStockOutBadge => 'نفد';

  @override
  String get posSetQuantity => 'الكمية';

  @override
  String pinDeviceInUse(String device) {
    return 'هذا الحساب مفتوح على جهاز ثاني ($device). سجّل خروج من هناك أول، أو خلي المالك أو المدير يطلّعه.';
  }

  @override
  String hrOpenOnDevice(String device) {
    return 'مفتوح على: $device';
  }

  @override
  String get hrReleaseDevice => 'تطليع من الجهاز';

  @override
  String hrReleaseDeviceConfirm(String name) {
    return 'تطلّع $name من الجهاز المفتوح عليه، حتى يكدر يدخل من جهاز ثاني؟';
  }

  @override
  String hrDeviceReleased(String name) {
    return '$name هسه يكدر يدخل من جهاز ثاني';
  }

  @override
  String syncFailedCount(int count) {
    return '$count ما انحفظت';
  }

  @override
  String get syncFailedTitle => 'تغييرات رفضها السيرفر';

  @override
  String get syncFailedHelp =>
      'هذي انعملت على هذا الجهاز بس السيرفر ما قبلها (مثلاً المادة تغيرت أو انحذفت من جهاز ثاني). محفوظة هنا، عيد المحاولة بعد ما تصلح السبب.';

  @override
  String get needsConnection =>
      'هذي العملية تحتاج إنترنت. جربها لمن يرجع الاتصال.';

  @override
  String get returnWaitSync =>
      'هاي الفاتورة انعملت بدون إنترنت وبعدها ما وصلت للسيرفر. سوّي الإرجاع بعد ما تتزامن.';

  @override
  String get navMore => 'المزيد';

  @override
  String posCartSummary(int count, String total) {
    return '$count مادة · $total';
  }

  @override
  String get posMoreActions => 'المزيد';

  @override
  String get posScanCamera => 'امسح بالكاميرا';

  @override
  String get shiftCashDebtPayments => 'تسديدات ديون نقداً';

  @override
  String get shiftCashRefunds => 'مرتجعات نقدية';

  @override
  String shiftCashForeign(String amount) {
    return 'وموجود بالقاصة أيضاً: $amount';
  }

  @override
  String get shiftCashOfflineNote =>
      'بدون اتصال: محسوب من بيانات هذا الجهاز فقط، ويُعاد حسابه على الخادم عند وصول إغلاق الشفت.';

  @override
  String shiftDifference(String amount) {
    return 'الفرق: $amount';
  }

  @override
  String debtsPayMoreThanOwed(String amount) {
    return 'المبلغ أكثر من الدين المتبقي ($amount)';
  }

  @override
  String get hrPinFourDigits => 'رمز الدخول 4 أرقام';

  @override
  String hrPinChangeConfirm(String name) {
    return 'أكّد برمزك أنت لتغيير رمز $name.';
  }

  @override
  String get storeSignOutConfirm =>
      'تسجيل خروج هذا الجهاز من المتجر؟ ستحتاج بيانات دخول المتجر للرجوع.';

  @override
  String get storeSignOutPendingWarning =>
      'توجد تغييرات على هذا الجهاز لم تصل للخادم بعد. ستبقى محفوظة وتُرسل عند تسجيل دخول هذا المتجر هنا مرة أخرى. تسجيل الخروج على أي حال؟';

  @override
  String get breakManagerUnlock => 'فتح القفل من المدير';

  @override
  String get breakManagerUnlockHelp =>
      'يُدخل المالك أو المدير رمزه لفتح الكاشير. تنتهي الاستراحة عند دخول الموظف مرة أخرى.';

  @override
  String get syncDiscard => 'تجاهل';

  @override
  String get syncDiscardTitle => 'تتجاهل هذا التغيير؟';

  @override
  String syncDiscardBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '، ويا $count تغييرات بعده تعتمد عليه.',
      one: '، ويا تغيير واحد بعده يعتمد عليه.',
      zero: '.',
    );
    return 'ما راح ينرسل للسيرفر وينشال من هذا الجهاز$_temp0 ما تكدر ترجعه.';
  }

  @override
  String syncHeldBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغييرات بعده تنتظر هذا',
      one: 'تغيير واحد بعده ينتظر هذا',
    );
    return '$_temp0';
  }

  @override
  String syncOtherStores(int count) {
    return '$count تنتظر متجر ثاني';
  }

  @override
  String get syncOtherStoresHelp =>
      'تغييرات انعملت على هذا الجهاز لمن كان متجر ثاني مسجل دخول. تنرسل لمن يسجل ذاك المتجر دخول هنا مرة ثانية.';

  @override
  String get posHeldSaleDetached =>
      'هذه الفاتورة المعلّقة أُكملت أو أُلغيت مسبقاً (ربما على جهاز آخر). لم يُسجَّل أي مبلغ. السلة الآن فاتورة مستقلة — راجعها ثم أكمل البيع أو علّقها من جديد.';

  @override
  String get posHeldSaleIncomplete =>
      'هذه الفاتورة المعلّقة ما زالت قيد الحفظ. حاول مرة أخرى بعد لحظات.';

  @override
  String posReturnDoneBalance(String amount) {
    return 'تم الاسترجاع — خُصم $amount من رصيد الزبون';
  }

  @override
  String posReturnDoneSplit(String balance, String cash) {
    return 'تم الاسترجاع — خُصم $balance من رصيد الزبون، أعِد له $cash';
  }

  @override
  String get posReturnMoreThanLeft =>
      'بعض هذه المواد استُرجعت مسبقاً (ربما بإرجاع ما زال بانتظار الإرسال). راجع الكميات وحاول مرة أخرى.';

  @override
  String get invPoAlreadyReceived =>
      'تم استلام طلب الشراء هذا مسبقاً (ربما من جهاز آخر). لم يُضَف مخزونه مرة ثانية.';

  @override
  String get invPoCancelled => 'تم إلغاء طلب الشراء هذا، لذلك لا يمكن استلامه.';

  @override
  String get invTransferAlreadyReceived =>
      'تم استلام هذا التحويل مسبقاً (ربما من جهاز آخر). لم يُنقَل مخزونه مرة ثانية.';

  @override
  String get invTransferCancelled =>
      'تم إلغاء هذا التحويل، لذلك لا يمكن استلامه.';

  @override
  String get invPoReceived => 'تم استلام طلب الشراء — أُضيف المخزون';

  @override
  String get invPhotoNotSaved =>
      'تم حفظ المنتج بدون الصورة الجديدة — لا يوجد اتصال بالإنترنت. أضف الصورة مرة أخرى عند عودة الاتصال.';

  @override
  String get invDiscountPercentInvalid => 'أدخل نسبة صحيحة من 1 إلى 100';

  @override
  String get invAmountInvalid => 'أدخل مبلغاً أكبر من صفر';

  @override
  String get invTaxRateInvalid => 'أدخل نسبة من 0 إلى 100';

  @override
  String get invImportMatchHelp =>
      'المنتجات الموجودة يتم العثور عليها بالباركود، ثم بالرمز، أو بالاسم المطابق تماماً إذا لم يكن في الصف أي منهما، ويتم تحديثها؛ والخانات الفارغة تُبقي ما في المنتج. الكمية تجعل مخزون هذا الفرع مساوياً لها، لذلك استيراد الملف نفسه مرة أخرى لا يضيف المخزون مرتين.';

  @override
  String get invPaymentNotPosted =>
      'تم تسجيل الدفعة، لكن تعذّر حفظ قيدها المحاسبي. راجع دفتر اليومية.';

  @override
  String get storeResetSubtitle =>
      'امسح المبيعات أو العملاء أو المخزون أو كل شيء وابدأ من جديد. يُحفظ ملف نسخة احتياطية ويُتحقق منه أولاً.';

  @override
  String get storeResetButton => 'إعادة ضبط…';

  @override
  String get storeResetChooseTitle => 'ماذا تريد أن تعيد ضبطه؟';

  @override
  String get storeResetImpliedNote =>
      'مُضمَّن: لا يمكن حذف الجزء الذي اخترته بدونه.';

  @override
  String get storeResetScopeFull => 'إعادة ضبط المتجر بالكامل';

  @override
  String get storeResetScopeFullHelp =>
      'كل السجلات التجارية: المبيعات والفواتير، العملاء والديون، المصروفات، الدفاتر المحاسبية، المنتجات والمخزون، الموردون، الورديات والخصومات. يبدأ المتجر من جديد كأنه جديد.';

  @override
  String get storeResetScopeSales => 'المبيعات والفواتير';

  @override
  String get storeResetScopeSalesHelp =>
      'الفواتير والمبيعات هي السجلات نفسها، لذا يحذف هذا الاثنين معاً: كل فاتورة (والمعلّقة أيضاً)، ومرتجعاتها، والديون الناتجة عنها، ونقاط الولاء المكتسبة أو المستخدمة فيها، وقيودها المحاسبية. تبدأ تقارير المبيعات من الصفر وتبدأ أرقام الفواتير من 1 مجدداً. لا تتغير كميات المخزون.';

  @override
  String get storeResetScopeDebts => 'ديون العملاء';

  @override
  String get storeResetScopeDebtsHelp =>
      'يحذف كل ديون العملاء والدفعات المستلمة عليها مع قيودها المحاسبية. يبقى العملاء والفواتير؛ ويبقى المبلغ المستحق المسجّل في قيد كل فاتورة حتى تُعاد ضبط السجلات المحاسبية.';

  @override
  String get storeResetScopeExpenses => 'المصروفات';

  @override
  String get storeResetScopeExpensesHelp =>
      'يحذف كل المصروفات مع قيودها المحاسبية. تتغير تقارير المصروفات وأرقام الأرباح ومجاميع نقد الورديات.';

  @override
  String get storeResetScopeAccounting => 'السجلات المحاسبية';

  @override
  String get storeResetScopeAccountingHelp =>
      'يحذف كل القيود اليومية بما فيها المصروفات: تبدأ أرصدة الحسابات والأرباح والخسائر وميزان المراجعة من الصفر. تبقى المبيعات والديون والمخزون والموردون بدون قيودها المحاسبية. يُحتفظ بدليل الحسابات.';

  @override
  String get storeResetScopeCustomers => 'العملاء';

  @override
  String get storeResetScopeCustomersHelp =>
      'يحذف كل العملاء مع سجل الولاء وديونهم. تبقى فواتيرهم السابقة بدون عميل.';

  @override
  String get storeResetScopeInventory => 'المنتجات والمخزون';

  @override
  String get storeResetScopeInventoryHelp =>
      'يحذف كل المنتجات مع كميات المخزون وسجل حركته، والفئات، وخصومات المنتجات والفئات، وأوامر الشراء وتحويلات المخزون. تُحذف كل الفواتير أيضاً لأن بنود الفواتير تشير إلى المنتجات. يبقى الموردون والمبالغ المستحقة لهم.';

  @override
  String get storeResetScopeSuppliers => 'الموردون';

  @override
  String get storeResetScopeSuppliersHelp =>
      'يحذف كل الموردين والمشتريات والدفعات المسجلة معهم وأوامر الشراء مع قيودها المحاسبية. يبقى المخزون المستلَم.';

  @override
  String get storeResetScopeShifts => 'الورديات';

  @override
  String get storeResetScopeShiftsHelp =>
      'يحذف الورديات المغلقة والاستراحات المنتهية. تبقى الورديات المفتوحة والاستراحات الجارية. تبقى الفواتير بدون وردية.';

  @override
  String get storeResetKeptNote =>
      'يُحتفظ دائماً بـ: المتجر وترخيصه وخطته، الفروع، الموظفين ورموزهم السرية، الإعدادات، نسب الضريبة، دليل الحسابات وسجل التدقيق.';

  @override
  String get storeResetConsequencesTitle => 'قبل المتابعة';

  @override
  String get storeResetWillRemove => 'سيحذف هذا، في كل الفروع وعلى كل الأجهزة:';

  @override
  String get storeResetNothingToRemove => 'لا توجد سجلات لحذفها فيما اخترته.';

  @override
  String get storeResetBackupNote =>
      'أولاً يُحفظ ملف نسخة احتياطية لهذه السجلات (ولتغييرات هذا الجهاز التي لم تُرسل بعد) في المكان الذي تختاره ويُتحقق منه. إن تعذّر حفظه والتحقق منه فلن يُعاد ضبط شيء.';

  @override
  String get storeResetLoadingPreview => 'جارٍ عدّ السجلات…';

  @override
  String storeResetFinalTitle(String scopes) {
    return 'مسح $scopes؟';
  }

  @override
  String get storeResetFinalFull =>
      'ستُمسح كل السجلات التجارية لهذا المتجر على كل الأجهزة. لا يمكن التراجع عن ذلك من التطبيق: ملف النسخة الاحتياطية وحده يمكنه استعادتها.';

  @override
  String storeResetFinalPartial(String scopes) {
    return 'سيُمسح $scopes على كل الأجهزة. لا يمكن التراجع عن ذلك من التطبيق: ملف النسخة الاحتياطية وحده يمكنه استعادتها.';
  }

  @override
  String get storeResetConfirmButton => 'نسخ احتياطي ثم مسح';

  @override
  String get storeResetSaveDialogTitle =>
      'احفظ النسخة الاحتياطية قبل إعادة الضبط';

  @override
  String get storeResetStageBackup => 'حفظ ملف النسخة الاحتياطية';

  @override
  String get storeResetStageVerify => 'التحقق من ملف النسخة الاحتياطية';

  @override
  String get storeResetStageServer => 'إعادة ضبط البيانات على الخادم';

  @override
  String get storeResetStageLocal => 'إعادة ضبط البيانات';

  @override
  String get storeResetStageCleanup => 'تنظيف هذا الجهاز';

  @override
  String get storeResetDoneTitle => 'اكتملت إعادة الضبط';

  @override
  String storeResetDoneRemoved(int count) {
    return 'تم حذف أو تحديث $count سجل.';
  }

  @override
  String storeResetDoneBackup(String path) {
    return 'حُفظت النسخة الاحتياطية في: $path';
  }

  @override
  String storeResetDoneDropped(int count) {
    return 'أُسقط $count من تغييرات هذا الجهاز غير المرسلة الخاصة بالسجلات الممسوحة (وهي موجودة في ملف النسخة الاحتياطية).';
  }

  @override
  String get storeResetFailedTitle => 'لم تكتمل إعادة الضبط';

  @override
  String get storeResetErrorOffline =>
      'لا يوجد اتصال بالإنترنت. بيانات المتجر محفوظة على الخادم، لذا لا يمكن إعادة ضبطها إلا عبر الإنترنت. لم يتغير شيء.';

  @override
  String get storeResetErrorUnsent =>
      'بعض التغييرات على هذا الجهاز لم تصل إلى الخادم بعد. انتظر حتى تُرسل (راجع شريط الحالة) ثم حاول مجدداً. لم يتغير شيء.';

  @override
  String storeResetErrorBackup(String error) {
    return 'تعذّر إنشاء ملف النسخة الاحتياطية أو حفظه ($error). لم يتغير شيء.';
  }

  @override
  String get storeResetErrorVerify =>
      'لم يُقرأ ملف النسخة الاحتياطية المحفوظ بشكل صحيح، لذا لم يُعَد ضبط شيء. جرّب حفظه في مكان آخر.';

  @override
  String storeResetErrorRefused(String error) {
    return 'رُفضت إعادة الضبط ($error). لم يتغير شيء.';
  }

  @override
  String get storeResetErrorUnknown =>
      'انقطع الاتصال قبل أن يرد الخادم. ربما اكتملت إعادة الضبط: سيُتحقق من ذلك تلقائياً في المرة القادمة التي يُفتح فيها التطبيق مع اتصال. لا تبدأ إعادة ضبط أخرى قبل ذلك.';

  @override
  String get storeResetErrorCancelled =>
      'لم يُختر مكان لملف النسخة الاحتياطية، لذا لم يُعَد ضبط شيء.';

  @override
  String get storeResetResumed =>
      'اكتملت على هذا الجهاز إعادة ضبط بدأت سابقاً.';

  @override
  String get storeResetTableSales => 'الفواتير';

  @override
  String get storeResetTableSaleLines => 'بنود الفواتير';

  @override
  String get storeResetTableSaleReturns => 'المرتجعات';

  @override
  String get storeResetTableSaleReturnLines => 'بنود المرتجعات';

  @override
  String get storeResetTableDebts => 'ديون العملاء';

  @override
  String get storeResetTableDebtPayments => 'دفعات الديون';

  @override
  String get storeResetTableLoyalty => 'سجلات نقاط الولاء';

  @override
  String get storeResetTablePointsAdjusted => 'عملاء صُحّحت نقاطهم';

  @override
  String get storeResetTableCustomers => 'العملاء';

  @override
  String get storeResetTableSalesUnlinked => 'فواتير لم تعد مرتبطة بعميل';

  @override
  String get storeResetTableExpenses => 'المصروفات';

  @override
  String get storeResetTableJournalEntries => 'القيود اليومية';

  @override
  String get storeResetTableJournalLines => 'بنود القيود';

  @override
  String get storeResetTableProducts => 'المنتجات';

  @override
  String get storeResetTableStockItems => 'كميات المخزون';

  @override
  String get storeResetTableStockMovements => 'سجل حركة المخزون';

  @override
  String get storeResetTableCategories => 'الفئات';

  @override
  String get storeResetTableDiscounts => 'الخصومات';

  @override
  String get storeResetTablePurchaseOrders => 'أوامر الشراء';

  @override
  String get storeResetTablePurchaseOrderLines => 'بنود أوامر الشراء';

  @override
  String get storeResetTableTransfers => 'تحويلات المخزون';

  @override
  String get storeResetTableTransferLines => 'بنود التحويلات';

  @override
  String get storeResetTableSuppliers => 'الموردون';

  @override
  String get storeResetTableSupplierTransactions => 'مشتريات ودفعات الموردين';

  @override
  String get storeResetTableShifts => 'الورديات';

  @override
  String get storeResetTableBreaks => 'الاستراحات';
}
