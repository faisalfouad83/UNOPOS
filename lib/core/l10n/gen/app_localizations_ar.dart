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
}
