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
  String get inventoryTransferStock => 'Transfer Stock';

  @override
  String get inventoryPurchaseOrders => 'Purchase Orders';

  @override
  String get inventoryAdjustStock => 'Adjust Stock';

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
}
