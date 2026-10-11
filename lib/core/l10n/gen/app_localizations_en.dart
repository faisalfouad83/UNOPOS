// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UNOPOS';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionDone => 'Done';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSignOut => 'Sign Out';

  @override
  String get actionPrint => 'Print';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get commonName => 'Name';

  @override
  String get commonPhone => 'Phone Number';

  @override
  String get commonAddress => 'Address';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonDate => 'Date';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonSubtotal => 'Subtotal';

  @override
  String get commonTax => 'Tax';

  @override
  String get commonDiscount => 'Discount';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get commonPrice => 'Price';

  @override
  String get splashTagline => 'Point of Sale for Modern Retail';

  @override
  String get activationTitle => 'Activate UNOPOS';

  @override
  String get activationSubtitle =>
      'Enter the activation code provided by your UNOPOS representative';

  @override
  String get activationCodeLabel => 'Activation Code';

  @override
  String get activationCodeHint => 'UNPS-XXXXX-XXXXX';

  @override
  String get activationButton => 'Activate';

  @override
  String get activationInvalid =>
      'This activation code is invalid or has expired';

  @override
  String get activationExpired =>
      'Your license has expired. Please enter a new activation code';

  @override
  String get activationSuccess => 'Activated successfully';

  @override
  String activationDaysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get activationLifetime => 'Lifetime license';

  @override
  String get onboardingCreateStoreTitle => 'Create Your Store';

  @override
  String get onboardingStoreId => 'Store ID';

  @override
  String get onboardingStorePassword => 'Store Password';

  @override
  String get onboardingConfirmPassword => 'Confirm Password';

  @override
  String get onboardingCreateManagerTitle => 'Create Manager Account';

  @override
  String get onboardingManagerName => 'Manager Name';

  @override
  String get onboardingManagerPasscode => 'Choose a 4-digit Passcode';

  @override
  String get onboardingBranchCount => 'Number of Branches';

  @override
  String get onboardingBranchDetails => 'Branch Details';

  @override
  String get onboardingBranchName => 'Branch Name';

  @override
  String get onboardingBranchLocation => 'Branch Location';

  @override
  String get onboardingFinish => 'Finish Setup';

  @override
  String get loginStoreTitle => 'Store Login';

  @override
  String get loginStoreIdHint => 'Enter your Store ID';

  @override
  String get loginStorePasswordHint => 'Enter your Store Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginInvalidCredentials => 'Incorrect store ID or password';

  @override
  String get loginCreateStoreLink => 'Don\'t have a store yet? Create one';

  @override
  String get developerSignInTitle => 'Developer Sign-In';

  @override
  String get developerSignInEmail => 'Email';

  @override
  String get developerSignInPassword => 'Password';

  @override
  String get actionCreateStore => 'Create a New Store';

  @override
  String get onboardingOwnerName => 'Owner Name';

  @override
  String get pickAccountTitle => 'Who\'s working?';

  @override
  String get pinPadTitle => 'Enter Passcode';

  @override
  String get pinPadIncorrect => 'Incorrect passcode';

  @override
  String pinPadLocked(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSales => 'Sales';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navDebts => 'Debts';

  @override
  String get navSuppliers => 'Suppliers';

  @override
  String get navAccounting => 'Accounting';

  @override
  String get navExpensesCash => 'Expenses & Cash';

  @override
  String get navHr => 'Staff';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get posTitle => 'Point of Sale';

  @override
  String get posSearchProducts => 'Search products or scan barcode';

  @override
  String get posCart => 'Cart';

  @override
  String get posEmptyCart => 'Cart is empty';

  @override
  String get posHoldSale => 'Hold Sale';

  @override
  String get posHeldSales => 'Held Sales';

  @override
  String get posResumeSale => 'Resume';

  @override
  String get posCheckout => 'Checkout';

  @override
  String get posPayCash => 'Cash';

  @override
  String get posPayCard => 'Card';

  @override
  String get posPayLater => 'Pay Later';

  @override
  String get posCustomerName => 'Customer Name';

  @override
  String get posAmountTendered => 'Amount Tendered';

  @override
  String get posChangeDue => 'Change Due';

  @override
  String get posCompleteSale => 'Complete Sale';

  @override
  String get posSaleCompleted => 'Sale completed';

  @override
  String get posPrintReceipt => 'Print Receipt';

  @override
  String get posShiftOpen => 'Open Shift';

  @override
  String get posShiftClose => 'Close Shift';

  @override
  String get posOpeningFloat => 'Opening Cash Float';

  @override
  String get posSalesHistory => 'Sales History';

  @override
  String get posProcessReturn => 'Process Return';

  @override
  String get posRefundMethod => 'Refund Method';

  @override
  String get posReturnReducesBalance =>
      'This reduces the customer\'s outstanding balance';

  @override
  String get posNoReturnableQuantitySelected =>
      'Select at least one item to return';

  @override
  String get expensesCashTitle => 'Expenses & Cash';

  @override
  String get expensesCashSubtitle =>
      'Track operating expenses, revenue, and reconcile the drawer\'s actual balance';

  @override
  String get expensesCashNoOpenShift =>
      'No open shift — open one to start tracking cash';

  @override
  String get expensesCashOpeningCash => 'Opening Cash';

  @override
  String get expensesCashSalesTotal => 'Cash Sales Total';

  @override
  String get expensesCashTotalExpenses => 'Total Deducted Expenses';

  @override
  String get expensesCashExpected => 'Expected Cash';

  @override
  String get expensesCashLog => 'Expense Log';

  @override
  String get expensesCashNoExpenses => 'No expenses recorded this shift';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get inventoryProducts => 'Products';

  @override
  String get inventoryCategories => 'Categories';

  @override
  String get inventoryAddProduct => 'Add Product';

  @override
  String get inventoryStockLevel => 'Stock Level';

  @override
  String get inventoryLowStock => 'Low Stock';

  @override
  String get inventoryGenerateQr => 'Generate QR Code';

  @override
  String get inventoryBarcode => 'Barcode';

  @override
  String get inventoryGenerateBarcode => 'Generate barcode';

  @override
  String get inventoryBarcodeAutoHint =>
      'Leave empty to generate one automatically';

  @override
  String get inventoryPrintLabel => 'Print label';

  @override
  String get inventoryGenerateMissingBarcodes =>
      'Generate barcodes for products without one';

  @override
  String inventoryBarcodesGenerated(int count) {
    return 'Generated $count barcodes';
  }

  @override
  String get inventoryTransferStock => 'Transfer Stock';

  @override
  String get inventoryPurchaseOrders => 'Purchase Orders';

  @override
  String get inventoryAdjustStock => 'Adjust Stock';

  @override
  String get inventoryUnit => 'Unit';

  @override
  String get unitPiece => 'Piece';

  @override
  String get unitBottle => 'Bottle';

  @override
  String get unitCarton => 'Carton';

  @override
  String get unitBox => 'Box';

  @override
  String get unitPack => 'Pack';

  @override
  String get unitKilogram => 'Kilogram';

  @override
  String get unitLiter => 'Liter';

  @override
  String get debtsTitle => 'Debt Ledger';

  @override
  String get debtsCustomer => 'Customer';

  @override
  String get debtsBalanceOwed => 'Balance Owed';

  @override
  String get debtsRecordPayment => 'Record Payment';

  @override
  String get debtsHistory => 'Payment History';

  @override
  String get debtsOpen => 'Open';

  @override
  String get debtsPartiallyPaid => 'Partially Paid';

  @override
  String get debtsPaid => 'Paid';

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String get suppliersContact => 'Contact';

  @override
  String get suppliersBalanceOwed => 'We Owe';

  @override
  String get suppliersShipmentDate => 'Shipment Date';

  @override
  String get suppliersAddSupplier => 'Add Supplier';

  @override
  String get suppliersRecordPayment => 'Record Payment';

  @override
  String get accountingTitle => 'Accounting';

  @override
  String get accountingChartOfAccounts => 'Chart of Accounts';

  @override
  String get accountingJournal => 'Journal Entries';

  @override
  String get accountingGeneralLedger => 'General Ledger';

  @override
  String get accountingTrialBalance => 'Trial Balance';

  @override
  String get accountingProfitLoss => 'Profit & Loss';

  @override
  String get accountingBalanceSheet => 'Balance Sheet';

  @override
  String get accountingExpenses => 'Expenses';

  @override
  String get accountingAddExpense => 'Add Expense';

  @override
  String get hrTitle => 'Staff Directory';

  @override
  String get hrAddEmployee => 'Add Employee';

  @override
  String get hrRole => 'Role';

  @override
  String get hrSalary => 'Salary';

  @override
  String get hrAllowances => 'Allowances';

  @override
  String get hrBranch => 'Branch';

  @override
  String get hrRoleOwner => 'Owner';

  @override
  String get hrRoleManager => 'Manager';

  @override
  String get hrRoleCashier => 'Cashier';

  @override
  String get hrRoleWarehouseManager => 'Warehouse Manager';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsPrinter => 'Receipt Printer';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsActivation => 'Activation';

  @override
  String get settingsBranches => 'Branches';

  @override
  String get settingsAddBranch => 'Add Branch';

  @override
  String get settingsSetActiveBranch => 'Set as Active';

  @override
  String get settingsActiveBranch => 'Active branch';

  @override
  String get settingsBranchDeactivate => 'Deactivate';

  @override
  String get settingsBranchActivate => 'Reactivate';

  @override
  String get settingsBranchDeactivated => 'Deactivated';

  @override
  String get settingsBackup => 'Backup & Restore';

  @override
  String get settingsBackupNow => 'Backup Now';

  @override
  String get settingsRestore => 'Restore from Backup';

  @override
  String get settingsAutoBackup => 'Automatic Daily Backup';

  @override
  String get settingsFactoryReset => 'Factory Reset';

  @override
  String get settingsFactoryResetWarning =>
      'This will permanently erase all data. Enter the reset passcode to continue.';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get developerTitle => 'Developer Console';

  @override
  String get developerGenerateCode => 'Generate Activation Code';

  @override
  String get developerStoreName => 'Store Name / Reference';

  @override
  String get developerLicenseTier => 'License Duration';

  @override
  String get developerTier1Month => '1 Month (Test)';

  @override
  String get developerTier3Months => '3 Months';

  @override
  String get developerTier6Months => '6 Months';

  @override
  String get developerTier12Months => '12 Months';

  @override
  String get developerTierLifetime => 'Lifetime';

  @override
  String get developerCodeGenerated => 'Activation code generated';

  @override
  String get developerRecentCodes => 'Recently Generated Codes';

  @override
  String get errorGeneric => 'Something went wrong. Please try again';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorNoConnection => 'No connection to printer';

  @override
  String get errorInsufficientStock => 'Not enough stock available';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get currencyIqd => 'Iraqi Dinar (IQD)';

  @override
  String get currencyUsd => 'US Dollar (USD)';

  @override
  String get receiptSale => 'Sale';

  @override
  String get receiptCashier => 'Cashier';

  @override
  String get receiptCustomer => 'Customer';

  @override
  String get receiptSubtotal => 'Subtotal';

  @override
  String get receiptTax => 'Tax';

  @override
  String get receiptPayment => 'Payment';

  @override
  String get receiptTendered => 'Paid';

  @override
  String get receiptCash => 'Cash';

  @override
  String get receiptCard => 'Card';

  @override
  String get receiptThankYou => 'Thank you for shopping with us!';

  @override
  String offlinePendingSales(int count) {
    return '$count offline';
  }

  @override
  String get offlineSaleSaved =>
      'No internet — sale saved on this device and will be sent automatically';

  @override
  String get settingsExchangeRate => 'Dollar exchange rate';

  @override
  String get settingsExchangeRateHint =>
      'Dinars per 1 US dollar. Leave empty to hide dollar prices.';

  @override
  String posPaidIn(String currency) {
    return 'Paid in $currency';
  }

  @override
  String get importProductsTitle => 'Import products from Excel';

  @override
  String get importProductsHelp =>
      'Use an Excel (.xlsx) or CSV file whose first row has the column names. Name and selling price are required; cost, wholesale price, barcode, category, unit, quantity and expiry date are optional. Products whose barcode already exists are updated.';

  @override
  String get importDownloadTemplate => 'Download template';

  @override
  String get importChooseFile => 'Choose file';

  @override
  String get importTemplateSaved => 'Template saved';

  @override
  String get importReadFailed =>
      'Couldn\'t read this file. Save it as .xlsx or .csv and try again.';

  @override
  String importRowsReady(int count) {
    return '$count products ready to import';
  }

  @override
  String importMissingColumn(String column) {
    return 'The file has no \"$column\" column';
  }

  @override
  String importRowProblem(int row, String column) {
    return 'Row $row: missing or invalid $column';
  }

  @override
  String get importProductsAction => 'Import';

  @override
  String importDone(int created, int updated) {
    return 'Done: $created added, $updated updated';
  }

  @override
  String importFailedRows(String rows) {
    return 'Couldn\'t save rows: $rows';
  }

  @override
  String get commonOptional => 'Optional';

  @override
  String get inventoryWholesalePrice => 'Wholesale price';

  @override
  String get inventoryExpiryDate => 'Expiry date';

  @override
  String get posWholesalePrices => 'Wholesale prices';

  @override
  String get whatsappSendReceipt => 'Send receipt on WhatsApp';

  @override
  String get whatsappPhone => 'Customer\'s WhatsApp number';

  @override
  String get whatsappSend => 'Open WhatsApp';

  @override
  String get whatsappInvalidPhone => 'Enter a valid phone number';

  @override
  String get posCustomerPhone => 'Customer phone';

  @override
  String get posCustomerPhoneHint =>
      'Optional — for WhatsApp payment reminders';

  @override
  String get debtsNone => 'No outstanding debts';

  @override
  String get debtsTotalOutstanding => 'Total outstanding';

  @override
  String debtsSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
    );
    return '$_temp0';
  }

  @override
  String debtsDaysOutstanding(int days) {
    return '$days days';
  }

  @override
  String get debtsSendReminder => 'Send WhatsApp reminder';

  @override
  String debtsReminderMessage(String name, String store, String amount) {
    return 'Hello $name, this is a friendly reminder from $store that your outstanding balance is $amount. Thank you!';
  }

  @override
  String get expiryTitle => 'Expiring soon';

  @override
  String expiryWithinDays(int days) {
    return 'Within $days days';
  }

  @override
  String get expiryNone => 'Nothing is expiring in this period';

  @override
  String expiryInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $days days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String expiryExpiredDaysAgo(int days) {
    return 'Expired $days days ago';
  }

  @override
  String expiryExpiredCount(int count) {
    return '$count already expired';
  }

  @override
  String get reportsToday => 'Today';

  @override
  String get reportsLast7Days => '7 days';

  @override
  String get reportsLast30Days => '30 days';

  @override
  String get reportsRevenue => 'Sales';

  @override
  String get reportsProfit => 'Profit';

  @override
  String reportsMargin(int percent) {
    return '$percent% margin';
  }

  @override
  String get reportsSalesCount => 'Invoices';

  @override
  String get reportsAverageSale => 'Average invoice';

  @override
  String get reportsSalesByHour => 'Sales by hour';

  @override
  String get reportsSalesByDay => 'Sales by day';

  @override
  String reportsSalesShort(int count) {
    return '$count sales';
  }

  @override
  String get reportsNoSales => 'No sales in this period';

  @override
  String get reportsByPaymentMethod => 'How customers paid';

  @override
  String get reportsTopProducts => 'Best sellers';

  @override
  String get reportsNothingLow => 'Nothing below reorder level';

  @override
  String reportsReorderAt(int level) {
    return 'Reorder at $level';
  }

  @override
  String get loyaltyTitle => 'Loyalty points';

  @override
  String get loyaltySettingsHelp =>
      'Customers earn 1 point for every amount below they spend, and can spend points as a discount. Leave empty to turn loyalty off.';

  @override
  String get loyaltySpendPerPoint => 'Spend for 1 point';

  @override
  String get loyaltyPointValue => 'Value of 1 point';

  @override
  String get loyaltyNoCustomer => 'No customer (loyalty points)';

  @override
  String get loyaltyChooseCustomer => 'Choose customer';

  @override
  String get loyaltyNewCustomer => 'New customer';

  @override
  String get loyaltyNoMatches => 'No customers found';

  @override
  String loyaltyPointsBalance(int points) {
    return '$points pts';
  }

  @override
  String loyaltyUsePoints(int max) {
    return 'Use points (up to $max)';
  }

  @override
  String loyaltyPointWorth(String value) {
    return '1 point = $value';
  }

  @override
  String get loyaltyPointsRedeemed => 'Points used';

  @override
  String get loyaltyPointsEarned => 'Points earned';

  @override
  String get loyaltyBalance => 'Points balance';
}
