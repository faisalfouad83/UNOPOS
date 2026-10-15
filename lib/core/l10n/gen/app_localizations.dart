import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
  ];

  /// Application name, shown on splash and title bars
  ///
  /// In en, this message translates to:
  /// **'UNOPOS'**
  String get appName;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// No description provided for @actionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get actionSignOut;

  /// No description provided for @actionPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get actionPrint;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get commonPhone;

  /// No description provided for @commonAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get commonAddress;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get commonSubtotal;

  /// No description provided for @commonTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get commonTax;

  /// No description provided for @commonDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get commonDiscount;

  /// No description provided for @commonQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get commonQuantity;

  /// No description provided for @commonPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get commonPrice;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale for Modern Retail'**
  String get splashTagline;

  /// No description provided for @activationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate UNOPOS'**
  String get activationTitle;

  /// No description provided for @activationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code provided by your UNOPOS representative'**
  String get activationSubtitle;

  /// No description provided for @activationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation Code'**
  String get activationCodeLabel;

  /// No description provided for @activationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'UNPS-XXXXX-XXXXX'**
  String get activationCodeHint;

  /// No description provided for @activationButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activationButton;

  /// No description provided for @activationInvalid.
  ///
  /// In en, this message translates to:
  /// **'This activation code is invalid or has expired'**
  String get activationInvalid;

  /// No description provided for @activationExpired.
  ///
  /// In en, this message translates to:
  /// **'Your license has expired. Please enter a new activation code'**
  String get activationExpired;

  /// No description provided for @activationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Activated successfully'**
  String get activationSuccess;

  /// No description provided for @activationDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String activationDaysRemaining(int days);

  /// No description provided for @activationLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime license'**
  String get activationLifetime;

  /// No description provided for @onboardingCreateStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Store'**
  String get onboardingCreateStoreTitle;

  /// No description provided for @onboardingStoreId.
  ///
  /// In en, this message translates to:
  /// **'Store ID'**
  String get onboardingStoreId;

  /// No description provided for @onboardingStorePassword.
  ///
  /// In en, this message translates to:
  /// **'Store Password'**
  String get onboardingStorePassword;

  /// No description provided for @onboardingConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get onboardingConfirmPassword;

  /// No description provided for @onboardingCreateManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Manager Account'**
  String get onboardingCreateManagerTitle;

  /// No description provided for @onboardingManagerName.
  ///
  /// In en, this message translates to:
  /// **'Manager Name'**
  String get onboardingManagerName;

  /// No description provided for @onboardingManagerPasscode.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit Passcode'**
  String get onboardingManagerPasscode;

  /// No description provided for @onboardingBranchCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Branches'**
  String get onboardingBranchCount;

  /// No description provided for @onboardingBranchDetails.
  ///
  /// In en, this message translates to:
  /// **'Branch Details'**
  String get onboardingBranchDetails;

  /// No description provided for @onboardingBranchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get onboardingBranchName;

  /// No description provided for @onboardingBranchLocation.
  ///
  /// In en, this message translates to:
  /// **'Branch Location'**
  String get onboardingBranchLocation;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get onboardingFinish;

  /// No description provided for @loginStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Login'**
  String get loginStoreTitle;

  /// No description provided for @loginStoreIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Store ID'**
  String get loginStoreIdHint;

  /// No description provided for @loginStorePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Store Password'**
  String get loginStorePasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect store ID or password'**
  String get loginInvalidCredentials;

  /// No description provided for @loginCreateStoreLink.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a store yet? Create one'**
  String get loginCreateStoreLink;

  /// No description provided for @developerSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Sign-In'**
  String get developerSignInTitle;

  /// No description provided for @developerSignInEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get developerSignInEmail;

  /// No description provided for @developerSignInPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get developerSignInPassword;

  /// No description provided for @actionCreateStore.
  ///
  /// In en, this message translates to:
  /// **'Create a New Store'**
  String get actionCreateStore;

  /// No description provided for @onboardingOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get onboardingOwnerName;

  /// No description provided for @pickAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s working?'**
  String get pickAccountTitle;

  /// No description provided for @pinPadTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Passcode'**
  String get pinPadTitle;

  /// No description provided for @pinPadIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passcode'**
  String get pinPadIncorrect;

  /// No description provided for @pinPadLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s'**
  String pinPadLocked(int seconds);

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navDebts;

  /// No description provided for @navSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get navSuppliers;

  /// No description provided for @navAccounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get navAccounting;

  /// No description provided for @navExpensesCash.
  ///
  /// In en, this message translates to:
  /// **'Expenses & Cash'**
  String get navExpensesCash;

  /// No description provided for @navHr.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get navHr;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @posTitle.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get posTitle;

  /// No description provided for @posSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products or scan barcode'**
  String get posSearchProducts;

  /// No description provided for @posCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get posCart;

  /// No description provided for @posEmptyCart.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get posEmptyCart;

  /// No description provided for @posHoldSale.
  ///
  /// In en, this message translates to:
  /// **'Hold Sale'**
  String get posHoldSale;

  /// No description provided for @posHeldSales.
  ///
  /// In en, this message translates to:
  /// **'Held Sales'**
  String get posHeldSales;

  /// No description provided for @posResumeSale.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get posResumeSale;

  /// No description provided for @posCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get posCheckout;

  /// No description provided for @posPayCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get posPayCash;

  /// No description provided for @posPayCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get posPayCard;

  /// No description provided for @posPayLater.
  ///
  /// In en, this message translates to:
  /// **'Pay Later'**
  String get posPayLater;

  /// No description provided for @posCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get posCustomerName;

  /// No description provided for @posAmountTendered.
  ///
  /// In en, this message translates to:
  /// **'Amount Tendered'**
  String get posAmountTendered;

  /// No description provided for @posChangeDue.
  ///
  /// In en, this message translates to:
  /// **'Change Due'**
  String get posChangeDue;

  /// No description provided for @posCompleteSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get posCompleteSale;

  /// No description provided for @posSaleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sale completed'**
  String get posSaleCompleted;

  /// No description provided for @posPrintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get posPrintReceipt;

  /// No description provided for @posShiftOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Shift'**
  String get posShiftOpen;

  /// No description provided for @posShiftClose.
  ///
  /// In en, this message translates to:
  /// **'Close Shift'**
  String get posShiftClose;

  /// No description provided for @posOpeningFloat.
  ///
  /// In en, this message translates to:
  /// **'Opening Cash Float'**
  String get posOpeningFloat;

  /// No description provided for @posSalesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get posSalesHistory;

  /// No description provided for @posProcessReturn.
  ///
  /// In en, this message translates to:
  /// **'Process Return'**
  String get posProcessReturn;

  /// No description provided for @posRefundMethod.
  ///
  /// In en, this message translates to:
  /// **'Refund Method'**
  String get posRefundMethod;

  /// No description provided for @posReturnReducesBalance.
  ///
  /// In en, this message translates to:
  /// **'This reduces the customer\'s outstanding balance'**
  String get posReturnReducesBalance;

  /// No description provided for @posNoReturnableQuantitySelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one item to return'**
  String get posNoReturnableQuantitySelected;

  /// No description provided for @expensesCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses & Cash'**
  String get expensesCashTitle;

  /// No description provided for @expensesCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track operating expenses, revenue, and reconcile the drawer\'s actual balance'**
  String get expensesCashSubtitle;

  /// No description provided for @expensesCashNoOpenShift.
  ///
  /// In en, this message translates to:
  /// **'No open shift — open one to start tracking cash'**
  String get expensesCashNoOpenShift;

  /// No description provided for @expensesCashOpeningCash.
  ///
  /// In en, this message translates to:
  /// **'Opening Cash'**
  String get expensesCashOpeningCash;

  /// No description provided for @expensesCashSalesTotal.
  ///
  /// In en, this message translates to:
  /// **'Cash Sales Total'**
  String get expensesCashSalesTotal;

  /// No description provided for @expensesCashTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Deducted Expenses'**
  String get expensesCashTotalExpenses;

  /// No description provided for @expensesCashExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected Cash'**
  String get expensesCashExpected;

  /// No description provided for @expensesCashLog.
  ///
  /// In en, this message translates to:
  /// **'Expense Log'**
  String get expensesCashLog;

  /// No description provided for @expensesCashNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded this shift'**
  String get expensesCashNoExpenses;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTitle;

  /// No description provided for @inventoryProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get inventoryProducts;

  /// No description provided for @inventoryCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get inventoryCategories;

  /// No description provided for @inventoryAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get inventoryAddProduct;

  /// No description provided for @inventoryStockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get inventoryStockLevel;

  /// No description provided for @inventoryLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get inventoryLowStock;

  /// No description provided for @inventoryGenerateQr.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get inventoryGenerateQr;

  /// No description provided for @inventoryBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get inventoryBarcode;

  /// No description provided for @inventoryGenerateBarcode.
  ///
  /// In en, this message translates to:
  /// **'Generate barcode'**
  String get inventoryGenerateBarcode;

  /// No description provided for @inventoryBarcodeAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to generate one automatically'**
  String get inventoryBarcodeAutoHint;

  /// No description provided for @inventoryPrintLabel.
  ///
  /// In en, this message translates to:
  /// **'Print label'**
  String get inventoryPrintLabel;

  /// No description provided for @inventoryGenerateMissingBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Generate barcodes for products without one'**
  String get inventoryGenerateMissingBarcodes;

  /// No description provided for @inventoryBarcodesGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated {count} barcodes'**
  String inventoryBarcodesGenerated(int count);

  /// No description provided for @inventoryTransferStock.
  ///
  /// In en, this message translates to:
  /// **'Transfer Stock'**
  String get inventoryTransferStock;

  /// No description provided for @inventoryPurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get inventoryPurchaseOrders;

  /// No description provided for @inventoryAdjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get inventoryAdjustStock;

  /// No description provided for @inventoryUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get inventoryUnit;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// No description provided for @unitBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get unitBottle;

  /// No description provided for @unitCarton.
  ///
  /// In en, this message translates to:
  /// **'Carton'**
  String get unitCarton;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBox;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get unitPack;

  /// No description provided for @unitKilogram.
  ///
  /// In en, this message translates to:
  /// **'Kilogram'**
  String get unitKilogram;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'Liter'**
  String get unitLiter;

  /// No description provided for @debtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Debt Ledger'**
  String get debtsTitle;

  /// No description provided for @debtsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get debtsCustomer;

  /// No description provided for @debtsBalanceOwed.
  ///
  /// In en, this message translates to:
  /// **'Balance Owed'**
  String get debtsBalanceOwed;

  /// No description provided for @debtsRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get debtsRecordPayment;

  /// No description provided for @debtsHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get debtsHistory;

  /// No description provided for @debtsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get debtsOpen;

  /// No description provided for @debtsPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get debtsPartiallyPaid;

  /// No description provided for @debtsPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get debtsPaid;

  /// No description provided for @suppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersTitle;

  /// No description provided for @suppliersContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get suppliersContact;

  /// No description provided for @suppliersBalanceOwed.
  ///
  /// In en, this message translates to:
  /// **'We Owe'**
  String get suppliersBalanceOwed;

  /// No description provided for @suppliersShipmentDate.
  ///
  /// In en, this message translates to:
  /// **'Shipment Date'**
  String get suppliersShipmentDate;

  /// No description provided for @suppliersAddSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get suppliersAddSupplier;

  /// No description provided for @suppliersRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get suppliersRecordPayment;

  /// No description provided for @accountingTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accountingTitle;

  /// No description provided for @accountingChartOfAccounts.
  ///
  /// In en, this message translates to:
  /// **'Chart of Accounts'**
  String get accountingChartOfAccounts;

  /// No description provided for @accountingJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal Entries'**
  String get accountingJournal;

  /// No description provided for @accountingGeneralLedger.
  ///
  /// In en, this message translates to:
  /// **'General Ledger'**
  String get accountingGeneralLedger;

  /// No description provided for @accountingTrialBalance.
  ///
  /// In en, this message translates to:
  /// **'Trial Balance'**
  String get accountingTrialBalance;

  /// No description provided for @accountingProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get accountingProfitLoss;

  /// No description provided for @accountingBalanceSheet.
  ///
  /// In en, this message translates to:
  /// **'Balance Sheet'**
  String get accountingBalanceSheet;

  /// No description provided for @accountingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get accountingExpenses;

  /// No description provided for @accountingAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get accountingAddExpense;

  /// No description provided for @hrTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Directory'**
  String get hrTitle;

  /// No description provided for @hrAddEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get hrAddEmployee;

  /// No description provided for @hrRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get hrRole;

  /// No description provided for @hrSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get hrSalary;

  /// No description provided for @hrAllowances.
  ///
  /// In en, this message translates to:
  /// **'Allowances'**
  String get hrAllowances;

  /// No description provided for @hrBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get hrBranch;

  /// No description provided for @hrRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get hrRoleOwner;

  /// No description provided for @hrRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get hrRoleManager;

  /// No description provided for @hrRoleCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get hrRoleCashier;

  /// No description provided for @hrRoleWarehouseManager.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Manager'**
  String get hrRoleWarehouseManager;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsPrinter.
  ///
  /// In en, this message translates to:
  /// **'Receipt Printer'**
  String get settingsPrinter;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsActivation.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get settingsActivation;

  /// No description provided for @settingsBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get settingsBranches;

  /// No description provided for @settingsAddBranch.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get settingsAddBranch;

  /// No description provided for @settingsSetActiveBranch.
  ///
  /// In en, this message translates to:
  /// **'Set as Active'**
  String get settingsSetActiveBranch;

  /// No description provided for @settingsActiveBranch.
  ///
  /// In en, this message translates to:
  /// **'Active branch'**
  String get settingsActiveBranch;

  /// No description provided for @settingsBranchDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get settingsBranchDeactivate;

  /// No description provided for @settingsBranchActivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get settingsBranchActivate;

  /// No description provided for @settingsBranchDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get settingsBranchDeactivated;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsBackup;

  /// No description provided for @settingsBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get settingsBackupNow;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get settingsRestore;

  /// No description provided for @settingsAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Daily Backup'**
  String get settingsAutoBackup;

  /// No description provided for @settingsFactoryReset.
  ///
  /// In en, this message translates to:
  /// **'Factory Reset'**
  String get settingsFactoryReset;

  /// No description provided for @settingsFactoryResetWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently erase all data. Enter the reset passcode to continue.'**
  String get settingsFactoryResetWarning;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDeveloper;

  /// No description provided for @developerTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Console'**
  String get developerTitle;

  /// No description provided for @developerGenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Activation Code'**
  String get developerGenerateCode;

  /// No description provided for @developerStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store Name / Reference'**
  String get developerStoreName;

  /// No description provided for @developerLicenseTier.
  ///
  /// In en, this message translates to:
  /// **'License Duration'**
  String get developerLicenseTier;

  /// No description provided for @developerTier1Month.
  ///
  /// In en, this message translates to:
  /// **'1 Month (Test)'**
  String get developerTier1Month;

  /// No description provided for @developerTier3Months.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get developerTier3Months;

  /// No description provided for @developerTier6Months.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get developerTier6Months;

  /// No description provided for @developerTier12Months.
  ///
  /// In en, this message translates to:
  /// **'12 Months'**
  String get developerTier12Months;

  /// No description provided for @developerTierLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get developerTierLifetime;

  /// No description provided for @developerCodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'Activation code generated'**
  String get developerCodeGenerated;

  /// No description provided for @developerRecentCodes.
  ///
  /// In en, this message translates to:
  /// **'Recently Generated Codes'**
  String get developerRecentCodes;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get errorGeneric;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection to printer'**
  String get errorNoConnection;

  /// No description provided for @errorInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock available'**
  String get errorInsufficientStock;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @currencyIqd.
  ///
  /// In en, this message translates to:
  /// **'Iraqi Dinar (IQD)'**
  String get currencyIqd;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD)'**
  String get currencyUsd;

  /// No description provided for @receiptSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get receiptSale;

  /// No description provided for @receiptCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get receiptCashier;

  /// No description provided for @receiptCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get receiptCustomer;

  /// No description provided for @receiptSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get receiptSubtotal;

  /// No description provided for @receiptTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get receiptTax;

  /// No description provided for @receiptPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get receiptPayment;

  /// No description provided for @receiptTendered.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get receiptTendered;

  /// No description provided for @receiptCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get receiptCash;

  /// No description provided for @receiptCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get receiptCard;

  /// No description provided for @receiptThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for shopping with us!'**
  String get receiptThankYou;

  /// No description provided for @offlinePendingSales.
  ///
  /// In en, this message translates to:
  /// **'{count} offline'**
  String offlinePendingSales(int count);

  /// No description provided for @offlineSaleSaved.
  ///
  /// In en, this message translates to:
  /// **'No internet — sale saved on this device and will be sent automatically'**
  String get offlineSaleSaved;

  /// No description provided for @settingsExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Dollar exchange rate'**
  String get settingsExchangeRate;

  /// No description provided for @settingsExchangeRateHint.
  ///
  /// In en, this message translates to:
  /// **'Dinars per 1 US dollar. Leave empty to hide dollar prices.'**
  String get settingsExchangeRateHint;

  /// No description provided for @posPaidIn.
  ///
  /// In en, this message translates to:
  /// **'Paid in {currency}'**
  String posPaidIn(String currency);

  /// No description provided for @importProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import products from Excel'**
  String get importProductsTitle;

  /// No description provided for @importProductsHelp.
  ///
  /// In en, this message translates to:
  /// **'Use an Excel (.xlsx) or CSV file whose first row has the column names. Name and selling price are required; cost, wholesale price, barcode, category, unit, quantity and expiry date are optional. Products whose barcode already exists are updated.'**
  String get importProductsHelp;

  /// No description provided for @importDownloadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download template'**
  String get importDownloadTemplate;

  /// No description provided for @importChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get importChooseFile;

  /// No description provided for @importTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get importTemplateSaved;

  /// No description provided for @importReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this file. Save it as .xlsx or .csv and try again.'**
  String get importReadFailed;

  /// No description provided for @importRowsReady.
  ///
  /// In en, this message translates to:
  /// **'{count} products ready to import'**
  String importRowsReady(int count);

  /// No description provided for @importMissingColumn.
  ///
  /// In en, this message translates to:
  /// **'The file has no \"{column}\" column'**
  String importMissingColumn(String column);

  /// No description provided for @importRowProblem.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: missing or invalid {column}'**
  String importRowProblem(int row, String column);

  /// No description provided for @importProductsAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importProductsAction;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Done: {created} added, {updated} updated'**
  String importDone(int created, int updated);

  /// No description provided for @importFailedRows.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save rows: {rows}'**
  String importFailedRows(String rows);

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @inventoryWholesalePrice.
  ///
  /// In en, this message translates to:
  /// **'Wholesale price'**
  String get inventoryWholesalePrice;

  /// No description provided for @inventoryExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get inventoryExpiryDate;

  /// No description provided for @posWholesalePrices.
  ///
  /// In en, this message translates to:
  /// **'Wholesale prices'**
  String get posWholesalePrices;

  /// No description provided for @whatsappSendReceipt.
  ///
  /// In en, this message translates to:
  /// **'Send receipt on WhatsApp'**
  String get whatsappSendReceipt;

  /// No description provided for @whatsappPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer\'s WhatsApp number'**
  String get whatsappPhone;

  /// No description provided for @whatsappSend.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get whatsappSend;

  /// No description provided for @whatsappInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get whatsappInvalidPhone;

  /// No description provided for @posCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get posCustomerPhone;

  /// No description provided for @posCustomerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — for WhatsApp payment reminders'**
  String get posCustomerPhoneHint;

  /// No description provided for @debtsNone.
  ///
  /// In en, this message translates to:
  /// **'No outstanding debts'**
  String get debtsNone;

  /// No description provided for @debtsTotalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total outstanding'**
  String get debtsTotalOutstanding;

  /// No description provided for @debtsSalesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sale} other{{count} sales}}'**
  String debtsSalesCount(int count);

  /// No description provided for @debtsDaysOutstanding.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String debtsDaysOutstanding(int days);

  /// No description provided for @debtsSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send WhatsApp reminder'**
  String get debtsSendReminder;

  /// No description provided for @debtsReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}, this is a friendly reminder from {store} that your outstanding balance is {amount}. Thank you!'**
  String debtsReminderMessage(String name, String store, String amount);

  /// No description provided for @expiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiryTitle;

  /// No description provided for @expiryWithinDays.
  ///
  /// In en, this message translates to:
  /// **'Within {days} days'**
  String expiryWithinDays(int days);

  /// No description provided for @expiryNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing is expiring in this period'**
  String get expiryNone;

  /// No description provided for @expiryInDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today} =1{Tomorrow} other{In {days} days}}'**
  String expiryInDays(int days);

  /// No description provided for @expiryExpiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days ago'**
  String expiryExpiredDaysAgo(int days);

  /// No description provided for @expiryExpiredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} already expired'**
  String expiryExpiredCount(int count);

  /// No description provided for @reportsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportsToday;

  /// No description provided for @reportsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get reportsLast7Days;

  /// No description provided for @reportsLast30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get reportsLast30Days;

  /// No description provided for @reportsRevenue.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get reportsRevenue;

  /// No description provided for @reportsProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get reportsProfit;

  /// No description provided for @reportsMargin.
  ///
  /// In en, this message translates to:
  /// **'{percent}% margin'**
  String reportsMargin(int percent);

  /// No description provided for @reportsSalesCount.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get reportsSalesCount;

  /// No description provided for @reportsAverageSale.
  ///
  /// In en, this message translates to:
  /// **'Average invoice'**
  String get reportsAverageSale;

  /// No description provided for @reportsSalesByHour.
  ///
  /// In en, this message translates to:
  /// **'Sales by hour'**
  String get reportsSalesByHour;

  /// No description provided for @reportsSalesByDay.
  ///
  /// In en, this message translates to:
  /// **'Sales by day'**
  String get reportsSalesByDay;

  /// No description provided for @reportsSalesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} sales'**
  String reportsSalesShort(int count);

  /// No description provided for @reportsNoSales.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period'**
  String get reportsNoSales;

  /// No description provided for @reportsByPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'How customers paid'**
  String get reportsByPaymentMethod;

  /// No description provided for @reportsTopProducts.
  ///
  /// In en, this message translates to:
  /// **'Best sellers'**
  String get reportsTopProducts;

  /// No description provided for @reportsNothingLow.
  ///
  /// In en, this message translates to:
  /// **'Nothing below reorder level'**
  String get reportsNothingLow;

  /// No description provided for @reportsReorderAt.
  ///
  /// In en, this message translates to:
  /// **'Reorder at {level}'**
  String reportsReorderAt(int level);

  /// No description provided for @loyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty points'**
  String get loyaltyTitle;

  /// No description provided for @loyaltySettingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Customers earn 1 point for every amount below they spend, and can spend points as a discount.'**
  String get loyaltySettingsHelp;

  /// No description provided for @loyaltySpendPerPoint.
  ///
  /// In en, this message translates to:
  /// **'Spend for 1 point'**
  String get loyaltySpendPerPoint;

  /// No description provided for @loyaltyPointValue.
  ///
  /// In en, this message translates to:
  /// **'Value of 1 point'**
  String get loyaltyPointValue;

  /// No description provided for @loyaltyNoCustomer.
  ///
  /// In en, this message translates to:
  /// **'No customer (loyalty points)'**
  String get loyaltyNoCustomer;

  /// No description provided for @loyaltyChooseCustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose customer'**
  String get loyaltyChooseCustomer;

  /// No description provided for @loyaltyNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get loyaltyNewCustomer;

  /// No description provided for @loyaltyNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get loyaltyNoMatches;

  /// No description provided for @loyaltyPointsBalance.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String loyaltyPointsBalance(int points);

  /// No description provided for @loyaltyUsePoints.
  ///
  /// In en, this message translates to:
  /// **'Use points (up to {max})'**
  String loyaltyUsePoints(int max);

  /// No description provided for @loyaltyPointWorth.
  ///
  /// In en, this message translates to:
  /// **'1 point = {value}'**
  String loyaltyPointWorth(String value);

  /// No description provided for @loyaltyPointsRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Points used'**
  String get loyaltyPointsRedeemed;

  /// No description provided for @loyaltyPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points earned'**
  String get loyaltyPointsEarned;

  /// No description provided for @loyaltyBalance.
  ///
  /// In en, this message translates to:
  /// **'Points balance'**
  String get loyaltyBalance;

  /// No description provided for @backupNoFolder.
  ///
  /// In en, this message translates to:
  /// **'No backup folder chosen — automatic backups go to the app\'s documents folder'**
  String get backupNoFolder;

  /// No description provided for @backupChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get backupChooseFolder;

  /// No description provided for @backupAutoHelp.
  ///
  /// In en, this message translates to:
  /// **'Once a day, any time the app is open at or after {time}. The last {keep} automatic backups are kept.'**
  String backupAutoHelp(String time, int keep);

  /// No description provided for @backupTime.
  ///
  /// In en, this message translates to:
  /// **'Backup time: {time}'**
  String backupTime(String time);

  /// No description provided for @backupTypeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get backupTypeAutomatic;

  /// No description provided for @backupTypeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get backupTypeManual;

  /// No description provided for @backupRestoreWarningLocal.
  ///
  /// In en, this message translates to:
  /// **'This replaces all current data on this device with the backup. Continue?'**
  String get backupRestoreWarningLocal;

  /// No description provided for @backupRestoreWarningCloud.
  ///
  /// In en, this message translates to:
  /// **'Records in the backup are written back to the store\'s cloud data, overwriting their current versions. Anything added since the backup is kept. Continue?'**
  String get backupRestoreWarningCloud;

  /// No description provided for @backupRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restore complete'**
  String get backupRestoreDone;

  /// No description provided for @backupRestoreReopen.
  ///
  /// In en, this message translates to:
  /// **'Close and reopen UNOPOS to load the restored data.'**
  String get backupRestoreReopen;

  /// No description provided for @unitPacket.
  ///
  /// In en, this message translates to:
  /// **'Packet'**
  String get unitPacket;

  /// No description provided for @unitTikka.
  ///
  /// In en, this message translates to:
  /// **'Tikka (piece)'**
  String get unitTikka;

  /// No description provided for @unitBale.
  ///
  /// In en, this message translates to:
  /// **'Bale (sack)'**
  String get unitBale;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unitGram;

  /// No description provided for @unitMilliliter.
  ///
  /// In en, this message translates to:
  /// **'Milliliter'**
  String get unitMilliliter;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @hrPasscodeNew.
  ///
  /// In en, this message translates to:
  /// **'Passcode (4 digits)'**
  String get hrPasscodeNew;

  /// No description provided for @hrPasscodeReset.
  ///
  /// In en, this message translates to:
  /// **'New passcode (leave empty to keep)'**
  String get hrPasscodeReset;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsOwnerAll.
  ///
  /// In en, this message translates to:
  /// **'The owner always has every permission.'**
  String get permissionsOwnerAll;

  /// No description provided for @permissionSell.
  ///
  /// In en, this message translates to:
  /// **'Sell (cashier screen)'**
  String get permissionSell;

  /// No description provided for @permissionGiveDiscount.
  ///
  /// In en, this message translates to:
  /// **'Give discounts'**
  String get permissionGiveDiscount;

  /// No description provided for @permissionProcessReturns.
  ///
  /// In en, this message translates to:
  /// **'Process returns'**
  String get permissionProcessReturns;

  /// No description provided for @permissionDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get permissionDebts;

  /// No description provided for @permissionCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get permissionCustomers;

  /// No description provided for @permissionInventory.
  ///
  /// In en, this message translates to:
  /// **'View inventory'**
  String get permissionInventory;

  /// No description provided for @permissionEditProducts.
  ///
  /// In en, this message translates to:
  /// **'Add and edit products'**
  String get permissionEditProducts;

  /// No description provided for @permissionSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get permissionSuppliers;

  /// No description provided for @permissionExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses and cash'**
  String get permissionExpenses;

  /// No description provided for @permissionAccounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get permissionAccounting;

  /// No description provided for @permissionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get permissionReports;

  /// No description provided for @permissionHr.
  ///
  /// In en, this message translates to:
  /// **'Employees (HR)'**
  String get permissionHr;

  /// No description provided for @permissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get permissionSettings;

  /// No description provided for @posLineDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount on this item'**
  String get posLineDiscount;

  /// No description provided for @posInvoiceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount on invoice'**
  String get posInvoiceDiscount;

  /// No description provided for @posDiscountPercent.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get posDiscountPercent;

  /// No description provided for @posDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount amount'**
  String get posDiscountAmount;

  /// No description provided for @posRemoveDiscount.
  ///
  /// In en, this message translates to:
  /// **'Remove discount'**
  String get posRemoveDiscount;

  /// No description provided for @settingsKeepMargin.
  ///
  /// In en, this message translates to:
  /// **'Keep a 5% margin on 100% discounts'**
  String get settingsKeepMargin;

  /// No description provided for @settingsKeepMarginHelp.
  ///
  /// In en, this message translates to:
  /// **'A full discount charges the item\'s cost plus 5% instead of giving it away.'**
  String get settingsKeepMarginHelp;

  /// No description provided for @customerWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer (cash)'**
  String get customerWalkIn;

  /// No description provided for @customersNone.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get customersNone;

  /// No description provided for @customersTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total purchases'**
  String get customersTotalSales;

  /// No description provided for @customersOwes.
  ///
  /// In en, this message translates to:
  /// **'Owes'**
  String get customersOwes;

  /// No description provided for @licenseExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get licenseExpiredTitle;

  /// No description provided for @licenseExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired on {date}'**
  String licenseExpiredOn(String date);

  /// No description provided for @licenseExpiredHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter a new activation code to keep using UNOPOS. Your data is safe and will be there when you continue.'**
  String get licenseExpiredHelp;

  /// No description provided for @activationAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This code can\'t be used (already used or not found).'**
  String get activationAlreadyUsed;

  /// No description provided for @developerTier2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2-week trial'**
  String get developerTier2Weeks;

  /// No description provided for @developerCodeNotActivated.
  ///
  /// In en, this message translates to:
  /// **'Not activated yet'**
  String get developerCodeNotActivated;

  /// No description provided for @developerCodeActivatedBy.
  ///
  /// In en, this message translates to:
  /// **'Activated by {store}'**
  String developerCodeActivatedBy(String store);

  /// No description provided for @developerCodeActivatedOn.
  ///
  /// In en, this message translates to:
  /// **'Activated on {date}'**
  String developerCodeActivatedOn(String date);

  /// No description provided for @developerCodeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days ({date})'**
  String developerCodeExpiresIn(int days, String date);

  /// No description provided for @developerCodeExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired on {date}'**
  String developerCodeExpiredOn(String date);

  /// No description provided for @developerLocalStatusNote.
  ///
  /// In en, this message translates to:
  /// **'Offline version: only activations on this device are shown.'**
  String get developerLocalStatusNote;

  /// No description provided for @roleDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get roleDeveloper;

  /// No description provided for @expenseType.
  ///
  /// In en, this message translates to:
  /// **'Expense type'**
  String get expenseType;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseCustomName.
  ///
  /// In en, this message translates to:
  /// **'Custom type name'**
  String get expenseCustomName;

  /// No description provided for @expenseEditType.
  ///
  /// In en, this message translates to:
  /// **'Change expense type'**
  String get expenseEditType;

  /// No description provided for @expenseGroupFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get expenseGroupFixed;

  /// No description provided for @expenseGroupVariable.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get expenseGroupVariable;

  /// No description provided for @expenseGroupNegligible.
  ///
  /// In en, this message translates to:
  /// **'Negligible'**
  String get expenseGroupNegligible;

  /// No description provided for @expenseGroupCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get expenseGroupCustom;

  /// No description provided for @expenseRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseRent;

  /// No description provided for @expenseSalaries.
  ///
  /// In en, this message translates to:
  /// **'Staff salaries'**
  String get expenseSalaries;

  /// No description provided for @expenseGeneratorElectricity.
  ///
  /// In en, this message translates to:
  /// **'Generator electricity'**
  String get expenseGeneratorElectricity;

  /// No description provided for @expenseNationalElectricity.
  ///
  /// In en, this message translates to:
  /// **'National grid electricity'**
  String get expenseNationalElectricity;

  /// No description provided for @expenseWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get expenseWater;

  /// No description provided for @expenseInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get expenseInternet;

  /// No description provided for @expenseSolarPower.
  ///
  /// In en, this message translates to:
  /// **'Solar power'**
  String get expenseSolarPower;

  /// No description provided for @expenseSoftware.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get expenseSoftware;

  /// No description provided for @expenseMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get expenseMaterials;

  /// No description provided for @expenseTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expenseTransport;

  /// No description provided for @expenseCleaningSupplies.
  ///
  /// In en, this message translates to:
  /// **'Cleaning supplies'**
  String get expenseCleaningSupplies;

  /// No description provided for @expensePackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get expensePackaging;

  /// No description provided for @expenseDeliveryAppCommission.
  ///
  /// In en, this message translates to:
  /// **'Delivery app commission'**
  String get expenseDeliveryAppCommission;

  /// No description provided for @expenseWasteAndDamage.
  ///
  /// In en, this message translates to:
  /// **'Waste and damage'**
  String get expenseWasteAndDamage;

  /// No description provided for @expenseMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get expenseMaintenance;

  /// No description provided for @expenseStaffMeals.
  ///
  /// In en, this message translates to:
  /// **'Staff meals'**
  String get expenseStaffMeals;

  /// No description provided for @expenseAnnualFees.
  ///
  /// In en, this message translates to:
  /// **'Annual fees (health, municipality)'**
  String get expenseAnnualFees;

  /// No description provided for @expenseHospitality.
  ///
  /// In en, this message translates to:
  /// **'Hospitality'**
  String get expenseHospitality;

  /// No description provided for @expensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Expenses this month'**
  String get expensesThisMonth;

  /// No description provided for @expensesThisYear.
  ///
  /// In en, this message translates to:
  /// **'Expenses this year'**
  String get expensesThisYear;

  /// No description provided for @expensesMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get expensesMonth;

  /// No description provided for @expensesYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get expensesYear;

  /// No description provided for @expensesNone.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded in this period'**
  String get expensesNone;

  /// No description provided for @expensesUntyped.
  ///
  /// In en, this message translates to:
  /// **'Older expenses without a type aren\'t included.'**
  String get expensesUntyped;

  /// No description provided for @devStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get devStores;

  /// No description provided for @devPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get devPlans;

  /// No description provided for @devLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get devLicenses;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @devAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get devAuditLog;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {details}'**
  String errorWithDetails(String details);

  /// No description provided for @devEditPlanLimits.
  ///
  /// In en, this message translates to:
  /// **'Edit limits: {plan}'**
  String devEditPlanLimits(String plan);

  /// No description provided for @devMaxEmployees.
  ///
  /// In en, this message translates to:
  /// **'Max employees'**
  String get devMaxEmployees;

  /// No description provided for @devMaxBranches.
  ///
  /// In en, this message translates to:
  /// **'Max branches'**
  String get devMaxBranches;

  /// No description provided for @devMaxProducts.
  ///
  /// In en, this message translates to:
  /// **'Max products'**
  String get devMaxProducts;

  /// No description provided for @devMaxUsers.
  ///
  /// In en, this message translates to:
  /// **'Max users'**
  String get devMaxUsers;

  /// No description provided for @devMaxWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Max warehouses'**
  String get devMaxWarehouses;

  /// No description provided for @devMaxStorage.
  ///
  /// In en, this message translates to:
  /// **'Max storage (MB)'**
  String get devMaxStorage;

  /// No description provided for @devMaxDailyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Max sales per day'**
  String get devMaxDailyTransactions;

  /// No description provided for @devPlanSummary.
  ///
  /// In en, this message translates to:
  /// **'Employees: {employees} · Branches: {branches} · Products: {products} · Daily sales: {daily} · Storage: {storage} MB'**
  String devPlanSummary(
    int employees,
    int branches,
    int products,
    int daily,
    int storage,
  );

  /// No description provided for @devTotalStores.
  ///
  /// In en, this message translates to:
  /// **'Total stores'**
  String get devTotalStores;

  /// No description provided for @devOnTrial.
  ///
  /// In en, this message translates to:
  /// **'On trial'**
  String get devOnTrial;

  /// No description provided for @devActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active subscriptions'**
  String get devActiveSubscriptions;

  /// No description provided for @devExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get devExpired;

  /// No description provided for @devDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get devDisabled;

  /// No description provided for @devSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get devSuspended;

  /// No description provided for @devNoStores.
  ///
  /// In en, this message translates to:
  /// **'No stores yet'**
  String get devNoStores;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @devEditStore.
  ///
  /// In en, this message translates to:
  /// **'Edit store'**
  String get devEditStore;

  /// No description provided for @devOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get devOwnerName;

  /// No description provided for @devChangePlan.
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get devChangePlan;

  /// No description provided for @devResetStorePassword.
  ///
  /// In en, this message translates to:
  /// **'Reset store password'**
  String get devResetStorePassword;

  /// No description provided for @devNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get devNewPassword;

  /// No description provided for @devReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get devReset;

  /// No description provided for @devPasswordWasReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get devPasswordWasReset;

  /// No description provided for @devSubscriptionExtended.
  ///
  /// In en, this message translates to:
  /// **'Subscription extended'**
  String get devSubscriptionExtended;

  /// No description provided for @devGenerateAssignLicense.
  ///
  /// In en, this message translates to:
  /// **'Generate and assign a code'**
  String get devGenerateAssignLicense;

  /// No description provided for @devLicenseAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned: {code}'**
  String devLicenseAssigned(String code);

  /// No description provided for @devLicenseKey.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get devLicenseKey;

  /// No description provided for @devExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get devExpires;

  /// No description provided for @devNever.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get devNever;

  /// No description provided for @devEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get devEnable;

  /// No description provided for @devDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get devDisable;

  /// No description provided for @devSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get devSuspend;

  /// No description provided for @devUnsuspend.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get devUnsuspend;

  /// No description provided for @devExtendSubscription.
  ///
  /// In en, this message translates to:
  /// **'Extend subscription'**
  String get devExtendSubscription;

  /// No description provided for @devGenerateLicense.
  ///
  /// In en, this message translates to:
  /// **'Generate code'**
  String get devGenerateLicense;

  /// No description provided for @devResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get devResetPassword;

  /// No description provided for @devDeleteStore.
  ///
  /// In en, this message translates to:
  /// **'Delete store'**
  String get devDeleteStore;

  /// No description provided for @devDeleteStoreWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes \"{store}\" and ALL of its data (sales, inventory, accounting — everything). This cannot be undone.'**
  String devDeleteStoreWarning(String store);

  /// No description provided for @devNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Notification sent'**
  String get devNotificationSent;

  /// No description provided for @devTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get devTitle;

  /// No description provided for @devMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get devMessage;

  /// No description provided for @devTarget.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get devTarget;

  /// No description provided for @devAllStores.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get devAllStores;

  /// No description provided for @devNoAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'No actions logged yet'**
  String get devNoAuditEntries;

  /// No description provided for @devStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get devStatusActive;

  /// No description provided for @devStatusTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get devStatusTrial;

  /// No description provided for @devStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get devStatusPending;

  /// No description provided for @devStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get devStatusRevoked;

  /// No description provided for @acctRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get acctRevenue;

  /// No description provided for @acctCogs.
  ///
  /// In en, this message translates to:
  /// **'Cost of goods sold'**
  String get acctCogs;

  /// No description provided for @acctExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get acctExpenses;

  /// No description provided for @acctNetIncome.
  ///
  /// In en, this message translates to:
  /// **'Net income'**
  String get acctNetIncome;

  /// No description provided for @acctAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get acctAssets;

  /// No description provided for @acctLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get acctLiabilities;

  /// No description provided for @acctEquity.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get acctEquity;

  /// No description provided for @acctNetIncomeNote.
  ///
  /// In en, this message translates to:
  /// **'Note: this period\'s net income moves into equity only once a period-close entry is posted (not automated yet).'**
  String get acctNetIncomeNote;

  /// No description provided for @acctDebitTotal.
  ///
  /// In en, this message translates to:
  /// **'Debit-side total'**
  String get acctDebitTotal;

  /// No description provided for @acctCreditTotal.
  ///
  /// In en, this message translates to:
  /// **'Credit-side total'**
  String get acctCreditTotal;

  /// No description provided for @acctBalanced.
  ///
  /// In en, this message translates to:
  /// **'Books balance ✓'**
  String get acctBalanced;

  /// No description provided for @acctNotBalanced.
  ///
  /// In en, this message translates to:
  /// **'Books do NOT balance — check entries'**
  String get acctNotBalanced;

  /// No description provided for @acctDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get acctDebit;

  /// No description provided for @acctCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get acctCredit;

  /// No description provided for @acctRevenueType.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get acctRevenueType;

  /// No description provided for @inventoryCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get inventoryCatalog;

  /// No description provided for @discountPercentOff.
  ///
  /// In en, this message translates to:
  /// **'% off'**
  String get discountPercentOff;

  /// No description provided for @discountAmountOff.
  ///
  /// In en, this message translates to:
  /// **'Amount off'**
  String get discountAmountOff;

  /// No description provided for @discountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved discounts'**
  String get discountsTitle;

  /// No description provided for @taxRatePercent.
  ///
  /// In en, this message translates to:
  /// **'Rate %'**
  String get taxRatePercent;

  /// No description provided for @taxDefaultForNew.
  ///
  /// In en, this message translates to:
  /// **'Default for new products'**
  String get taxDefaultForNew;

  /// No description provided for @taxRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax rates'**
  String get taxRatesTitle;

  /// No description provided for @taxDefault.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get taxDefault;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax rate'**
  String get taxRate;

  /// No description provided for @transferIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get transferIncoming;

  /// No description provided for @transferOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get transferOutgoing;

  /// No description provided for @transferOneBranchOnly.
  ///
  /// In en, this message translates to:
  /// **'This store has only one branch — there\'s nowhere to transfer to.'**
  String get transferOneBranchOnly;

  /// No description provided for @transferToBranch.
  ///
  /// In en, this message translates to:
  /// **'To branch'**
  String get transferToBranch;

  /// No description provided for @addProductLine.
  ///
  /// In en, this message translates to:
  /// **'Add a product'**
  String get addProductLine;

  /// No description provided for @actionReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get actionReceive;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @poShort.
  ///
  /// In en, this message translates to:
  /// **'PO'**
  String get poShort;

  /// No description provided for @poNew.
  ///
  /// In en, this message translates to:
  /// **'New purchase order'**
  String get poNew;

  /// No description provided for @poSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get poSupplier;

  /// No description provided for @poNeedSupplierAndProduct.
  ///
  /// In en, this message translates to:
  /// **'Add a supplier and at least one product first.'**
  String get poNeedSupplierAndProduct;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @inventorySku.
  ///
  /// In en, this message translates to:
  /// **'Product code (SKU)'**
  String get inventorySku;

  /// No description provided for @inventoryCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get inventoryCostPrice;

  /// No description provided for @inventoryReorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Reorder level'**
  String get inventoryReorderLevel;

  /// No description provided for @printerType.
  ///
  /// In en, this message translates to:
  /// **'Printer type'**
  String get printerType;

  /// No description provided for @printerNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network / Wi-Fi thermal (ESC/POS)'**
  String get printerNetwork;

  /// No description provided for @printerUsb.
  ///
  /// In en, this message translates to:
  /// **'USB thermal'**
  String get printerUsb;

  /// No description provided for @printerBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth thermal'**
  String get printerBluetooth;

  /// No description provided for @printerSystem.
  ///
  /// In en, this message translates to:
  /// **'Windows system printer'**
  String get printerSystem;

  /// No description provided for @printerPaperWidth.
  ///
  /// In en, this message translates to:
  /// **'Paper width'**
  String get printerPaperWidth;

  /// No description provided for @printerTestOk.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get printerTestOk;

  /// No description provided for @printerTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect'**
  String get printerTestFailed;

  /// No description provided for @printerTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get printerTestConnection;

  /// No description provided for @settingsDefaultVat.
  ///
  /// In en, this message translates to:
  /// **'Default VAT %'**
  String get settingsDefaultVat;

  /// No description provided for @factoryResetDone.
  ///
  /// In en, this message translates to:
  /// **'Reset complete'**
  String get factoryResetDone;

  /// No description provided for @factoryResetDoneHelp.
  ///
  /// In en, this message translates to:
  /// **'All data has been erased. Close and reopen UNOPOS to start fresh.'**
  String get factoryResetDoneHelp;

  /// No description provided for @notificationsNone.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsNone;

  /// No description provided for @hrDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get hrDeactivate;

  /// No description provided for @shiftCountedCash.
  ///
  /// In en, this message translates to:
  /// **'Cash counted in the drawer'**
  String get shiftCountedCash;

  /// No description provided for @supplierContactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get supplierContactPerson;

  /// No description provided for @barcodeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get barcodeScan;

  /// No description provided for @barcodeScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get barcodeScanTitle;

  /// No description provided for @tilePickerNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees found for this store.'**
  String get tilePickerNoEmployees;

  /// No description provided for @dashboardSalesToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sales today} =1{1 sale today} other{{count} sales today}}'**
  String dashboardSalesToday(int count);

  /// No description provided for @journalSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get journalSale;

  /// No description provided for @journalPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get journalPurchase;

  /// No description provided for @journalSupplierPayment.
  ///
  /// In en, this message translates to:
  /// **'Supplier payment'**
  String get journalSupplierPayment;

  /// No description provided for @journalDebtPayment.
  ///
  /// In en, this message translates to:
  /// **'Debt payment'**
  String get journalDebtPayment;

  /// No description provided for @journalExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get journalExpense;

  /// No description provided for @journalReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get journalReturn;

  /// No description provided for @journalAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get journalAdjustment;

  /// No description provided for @journalManual.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get journalManual;

  /// No description provided for @journalOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get journalOpeningBalance;

  /// No description provided for @acctTypeCogs.
  ///
  /// In en, this message translates to:
  /// **'Cost of sales'**
  String get acctTypeCogs;

  /// No description provided for @account1000.
  ///
  /// In en, this message translates to:
  /// **'Cash on hand'**
  String get account1000;

  /// No description provided for @account1010.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get account1010;

  /// No description provided for @account1100.
  ///
  /// In en, this message translates to:
  /// **'Customer debts (receivable)'**
  String get account1100;

  /// No description provided for @account1200.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get account1200;

  /// No description provided for @account2000.
  ///
  /// In en, this message translates to:
  /// **'Supplier debts (payable)'**
  String get account2000;

  /// No description provided for @account2100.
  ///
  /// In en, this message translates to:
  /// **'VAT / sales tax payable'**
  String get account2100;

  /// No description provided for @account3000.
  ///
  /// In en, this message translates to:
  /// **'Owner\'s equity'**
  String get account3000;

  /// No description provided for @account3100.
  ///
  /// In en, this message translates to:
  /// **'Retained earnings'**
  String get account3100;

  /// No description provided for @account4000.
  ///
  /// In en, this message translates to:
  /// **'Sales revenue'**
  String get account4000;

  /// No description provided for @account4100.
  ///
  /// In en, this message translates to:
  /// **'Sales returns'**
  String get account4100;

  /// No description provided for @account4200.
  ///
  /// In en, this message translates to:
  /// **'Discounts given'**
  String get account4200;

  /// No description provided for @account5000.
  ///
  /// In en, this message translates to:
  /// **'Cost of goods sold'**
  String get account5000;

  /// No description provided for @account6000.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get account6000;

  /// No description provided for @account6010.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get account6010;

  /// No description provided for @account6020.
  ///
  /// In en, this message translates to:
  /// **'Salaries and wages'**
  String get account6020;

  /// No description provided for @account6030.
  ///
  /// In en, this message translates to:
  /// **'Supplies'**
  String get account6030;

  /// No description provided for @account6040.
  ///
  /// In en, this message translates to:
  /// **'General expenses'**
  String get account6040;

  /// No description provided for @account6050.
  ///
  /// In en, this message translates to:
  /// **'Card processing fees'**
  String get account6050;

  /// No description provided for @account6060.
  ///
  /// In en, this message translates to:
  /// **'Inventory shrinkage'**
  String get account6060;

  /// No description provided for @transferItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String transferItemCount(int count);

  /// No description provided for @memoCashSale.
  ///
  /// In en, this message translates to:
  /// **'Cash sale'**
  String get memoCashSale;

  /// No description provided for @memoCardSale.
  ///
  /// In en, this message translates to:
  /// **'Card sale'**
  String get memoCardSale;

  /// No description provided for @memoPayLaterSale.
  ///
  /// In en, this message translates to:
  /// **'Pay-later sale (on account)'**
  String get memoPayLaterSale;

  /// No description provided for @memoDebtPayment.
  ///
  /// In en, this message translates to:
  /// **'Customer debt payment received'**
  String get memoDebtPayment;

  /// No description provided for @memoPurchasePaid.
  ///
  /// In en, this message translates to:
  /// **'Supplier purchase (paid)'**
  String get memoPurchasePaid;

  /// No description provided for @memoPurchaseCredit.
  ///
  /// In en, this message translates to:
  /// **'Supplier purchase (on credit)'**
  String get memoPurchaseCredit;

  /// No description provided for @memoSupplierPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment to supplier'**
  String get memoSupplierPayment;

  /// No description provided for @memoSaleReturn.
  ///
  /// In en, this message translates to:
  /// **'Sale return / refund'**
  String get memoSaleReturn;

  /// No description provided for @memoShrinkage.
  ///
  /// In en, this message translates to:
  /// **'Stock shrinkage / adjustment'**
  String get memoShrinkage;

  /// No description provided for @printerAddressNetwork.
  ///
  /// In en, this message translates to:
  /// **'IP address:port (e.g. 192.168.1.50:9100)'**
  String get printerAddressNetwork;

  /// No description provided for @printerAddressGeneric.
  ///
  /// In en, this message translates to:
  /// **'Connection address'**
  String get printerAddressGeneric;

  /// No description provided for @pickBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a branch'**
  String get pickBranchTitle;

  /// No description provided for @pickBranchChange.
  ///
  /// In en, this message translates to:
  /// **'Change branch'**
  String get pickBranchChange;

  /// No description provided for @pickBranchMain.
  ///
  /// In en, this message translates to:
  /// **'Main branch'**
  String get pickBranchMain;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMismatch;

  /// No description provided for @errorStoreIdFormat.
  ///
  /// In en, this message translates to:
  /// **'Use English letters and numbers only, no spaces'**
  String get errorStoreIdFormat;

  /// No description provided for @errorStoreIdTaken.
  ///
  /// In en, this message translates to:
  /// **'This store ID is already taken — choose another'**
  String get errorStoreIdTaken;

  /// No description provided for @returnInvoice.
  ///
  /// In en, this message translates to:
  /// **'Return invoice'**
  String get returnInvoice;

  /// No description provided for @returnInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice number'**
  String get returnInvoiceNumber;

  /// No description provided for @returnInvoiceNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 125 or S-000125'**
  String get returnInvoiceNumberHint;

  /// No description provided for @returnFind.
  ///
  /// In en, this message translates to:
  /// **'Find invoice'**
  String get returnFind;

  /// No description provided for @returnNotFound.
  ///
  /// In en, this message translates to:
  /// **'No invoice with this number'**
  String get returnNotFound;

  /// No description provided for @returnNothingLeft.
  ///
  /// In en, this message translates to:
  /// **'Everything on this invoice has already been returned'**
  String get returnNothingLeft;

  /// No description provided for @returnNotReturnable.
  ///
  /// In en, this message translates to:
  /// **'This invoice can\'t be returned'**
  String get returnNotReturnable;

  /// No description provided for @returnAll.
  ///
  /// In en, this message translates to:
  /// **'Return everything'**
  String get returnAll;

  /// No description provided for @returnRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get returnRefund;

  /// No description provided for @returnRefundTo.
  ///
  /// In en, this message translates to:
  /// **'Give the money back as'**
  String get returnRefundTo;

  /// No description provided for @returnSoldReturned.
  ///
  /// In en, this message translates to:
  /// **'Sold {sold} · returned {returned}'**
  String returnSoldReturned(int sold, int returned);

  /// No description provided for @returnDone.
  ///
  /// In en, this message translates to:
  /// **'Return completed — refund {amount}'**
  String returnDone(String amount);

  /// No description provided for @returnFailed.
  ///
  /// In en, this message translates to:
  /// **'The return didn\'t go through — check the connection and try again'**
  String get returnFailed;

  /// No description provided for @returnStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returnStatusRefunded;

  /// No description provided for @returnStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly returned'**
  String get returnStatusPartial;

  /// No description provided for @returnWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'Stock goes back on the shelf, the sale and its profit are reduced, and the money is refunded.'**
  String get returnWhatHappens;

  /// No description provided for @actionFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen (F11)'**
  String get actionFullScreen;

  /// No description provided for @actionExitFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen (F11)'**
  String get actionExitFullScreen;

  /// No description provided for @posScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode or search products'**
  String get posScanHint;

  /// No description provided for @posBarcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No active product with code {code}'**
  String posBarcodeNotFound(String code);

  /// No description provided for @posNoProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get posNoProductsFound;

  /// No description provided for @posHeldItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String posHeldItems(int count);

  /// No description provided for @posHeldInCart.
  ///
  /// In en, this message translates to:
  /// **'In the cart now'**
  String get posHeldInCart;

  /// No description provided for @posHeldSaleClosed.
  ///
  /// In en, this message translates to:
  /// **'This suspended sale was already completed or removed (maybe on another till). Nothing was charged.'**
  String get posHeldSaleClosed;

  /// No description provided for @posSaleHeld.
  ///
  /// In en, this message translates to:
  /// **'Sale suspended'**
  String get posSaleHeld;

  /// No description provided for @payAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get payAmountDue;

  /// No description provided for @payReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get payReceived;

  /// No description provided for @payPaidNow.
  ///
  /// In en, this message translates to:
  /// **'Paid now (optional)'**
  String get payPaidNow;

  /// No description provided for @payRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get payRemaining;

  /// No description provided for @payOnAccount.
  ///
  /// In en, this message translates to:
  /// **'On the customer\'s account'**
  String get payOnAccount;

  /// No description provided for @payExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get payExact;

  /// No description provided for @payClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get payClear;

  /// No description provided for @payInsufficient.
  ///
  /// In en, this message translates to:
  /// **'The amount received is less than the total. Take the rest, or put it on the customer\'s account.'**
  String get payInsufficient;

  /// No description provided for @payRestOnAccount.
  ///
  /// In en, this message translates to:
  /// **'Put the rest on account'**
  String get payRestOnAccount;

  /// No description provided for @payCustomerNeeded.
  ///
  /// In en, this message translates to:
  /// **'Choose the customer, or type their name, for a pay-later sale.'**
  String get payCustomerNeeded;

  /// No description provided for @payPaidNowTooMuch.
  ///
  /// In en, this message translates to:
  /// **'Paid in full: choose cash or card instead.'**
  String get payPaidNowTooMuch;

  /// No description provided for @printModeTitle.
  ///
  /// In en, this message translates to:
  /// **'After a sale'**
  String get printModeTitle;

  /// No description provided for @printModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Print automatically'**
  String get printModeAuto;

  /// No description provided for @printModeAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask first'**
  String get printModeAsk;

  /// No description provided for @printModeOff.
  ///
  /// In en, this message translates to:
  /// **'Don\'t print'**
  String get printModeOff;

  /// No description provided for @printAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Print the receipt?'**
  String get printAskTitle;

  /// No description provided for @printAction.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printAction;

  /// No description provided for @printSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get printSkip;

  /// No description provided for @printFailed.
  ///
  /// In en, this message translates to:
  /// **'The sale is saved, but printing failed: {reason}'**
  String printFailed(String reason);

  /// No description provided for @printRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get printRetry;

  /// No description provided for @printNoPrinter.
  ///
  /// In en, this message translates to:
  /// **'No printer is set up (Settings › Printer).'**
  String get printNoPrinter;

  /// No description provided for @branchCurrent.
  ///
  /// In en, this message translates to:
  /// **'Branch you\'re working in'**
  String get branchCurrent;

  /// No description provided for @tilePickerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the accounts. Check the connection and try again.'**
  String get tilePickerLoadFailed;

  /// No description provided for @loyaltySpendPerPointHelp.
  ///
  /// In en, this message translates to:
  /// **'Earning: the customer gets 1 point for every this much spent'**
  String get loyaltySpendPerPointHelp;

  /// No description provided for @loyaltyPointValueHelp.
  ///
  /// In en, this message translates to:
  /// **'Spending: the discount one point gives at the till'**
  String get loyaltyPointValueHelp;

  /// No description provided for @navInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get navInvoices;

  /// No description provided for @invoiceStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get invoiceStatusCompleted;

  /// No description provided for @invoiceStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get invoiceStatusCancelled;

  /// No description provided for @invoiceStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get invoiceStatusUnpaid;

  /// No description provided for @invoiceStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get invoiceStatusPartiallyPaid;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Invoice number or customer name'**
  String get invoiceSearchHint;

  /// No description provided for @invoiceAnyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get invoiceAnyDate;

  /// No description provided for @invoiceAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get invoiceAllBranches;

  /// No description provided for @invoiceAnyPayment.
  ///
  /// In en, this message translates to:
  /// **'Any payment'**
  String get invoiceAnyPayment;

  /// No description provided for @invoiceAnyCashier.
  ///
  /// In en, this message translates to:
  /// **'Any cashier'**
  String get invoiceAnyCashier;

  /// No description provided for @invoiceAnyStatus.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get invoiceAnyStatus;

  /// No description provided for @invoiceNone.
  ///
  /// In en, this message translates to:
  /// **'No invoices match'**
  String get invoiceNone;

  /// No description provided for @invoiceSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get invoiceSortNewest;

  /// No description provided for @invoiceSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get invoiceSortOldest;

  /// No description provided for @invoiceSortNumberDesc.
  ///
  /// In en, this message translates to:
  /// **'Number (high → low)'**
  String get invoiceSortNumberDesc;

  /// No description provided for @invoiceSortNumberAsc.
  ///
  /// In en, this message translates to:
  /// **'Number (low → high)'**
  String get invoiceSortNumberAsc;

  /// No description provided for @invoiceSortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount (high → low)'**
  String get invoiceSortAmountDesc;

  /// No description provided for @invoiceSortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount (low → high)'**
  String get invoiceSortAmountAsc;

  /// No description provided for @invoiceCreditCustomer.
  ///
  /// In en, this message translates to:
  /// **'Credit customer'**
  String get invoiceCreditCustomer;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTitle;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get invoiceDate;

  /// No description provided for @invoiceBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get invoiceBranch;

  /// No description provided for @invoiceNetTotal.
  ///
  /// In en, this message translates to:
  /// **'Net after returns'**
  String get invoiceNetTotal;

  /// No description provided for @invoicePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaid;

  /// No description provided for @invoicePaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get invoicePaymentHistory;

  /// No description provided for @invoiceNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get invoiceNoPayments;

  /// No description provided for @invoiceReprint.
  ///
  /// In en, this message translates to:
  /// **'Reprint'**
  String get invoiceReprint;

  /// No description provided for @printPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get printPreview;

  /// No description provided for @printSample.
  ///
  /// In en, this message translates to:
  /// **'SAMPLE'**
  String get printSample;

  /// No description provided for @receiptItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get receiptItem;

  /// No description provided for @invoiceTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice template'**
  String get invoiceTemplateTitle;

  /// No description provided for @invoicePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get invoicePaper;

  /// No description provided for @invoicePaperThermal.
  ///
  /// In en, this message translates to:
  /// **'Receipt roll'**
  String get invoicePaperThermal;

  /// No description provided for @invoiceStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get invoiceStyle;

  /// No description provided for @invoiceStyleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get invoiceStyleClassic;

  /// No description provided for @invoiceStyleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get invoiceStyleModern;

  /// No description provided for @invoiceStyleCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get invoiceStyleCompact;

  /// No description provided for @invoiceBranding.
  ///
  /// In en, this message translates to:
  /// **'Store details on the invoice'**
  String get invoiceBranding;

  /// No description provided for @invoiceLogoChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose logo'**
  String get invoiceLogoChoose;

  /// No description provided for @invoiceLogoChange.
  ///
  /// In en, this message translates to:
  /// **'Change logo'**
  String get invoiceLogoChange;

  /// No description provided for @invoiceLogoShow.
  ///
  /// In en, this message translates to:
  /// **'Print the logo'**
  String get invoiceLogoShow;

  /// No description provided for @invoiceBrandName.
  ///
  /// In en, this message translates to:
  /// **'Store name on the invoice'**
  String get invoiceBrandName;

  /// No description provided for @invoiceBrandDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the store\'s name, and the branch\'s phone and address'**
  String get invoiceBrandDefaultHint;

  /// No description provided for @invoiceFooter.
  ///
  /// In en, this message translates to:
  /// **'Footer / thank-you message'**
  String get invoiceFooter;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSaved;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image is too large (5 MB at most).'**
  String get imageTooLarge;

  /// No description provided for @imageWrongType.
  ///
  /// In en, this message translates to:
  /// **'Choose a PNG, JPG or WebP image.'**
  String get imageWrongType;

  /// No description provided for @printerAskEachTime.
  ///
  /// In en, this message translates to:
  /// **'Ask which printer each time'**
  String get printerAskEachTime;

  /// No description provided for @printerSystemHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a printer to print straight to it without a dialog.'**
  String get printerSystemHelp;

  /// No description provided for @printerChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose printer'**
  String get printerChoose;

  /// No description provided for @productCodeInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Use letters, digits and - _ . only'**
  String get productCodeInvalidChars;

  /// No description provided for @productCodeTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long (64 characters at most)'**
  String get productCodeTooLong;

  /// No description provided for @productCodeBadCheckDigit.
  ///
  /// In en, this message translates to:
  /// **'This barcode\'s check digit is wrong — check it was typed correctly'**
  String get productCodeBadCheckDigit;

  /// No description provided for @productCodeTaken.
  ///
  /// In en, this message translates to:
  /// **'Already used by \"{name}\"'**
  String productCodeTaken(String name);

  /// No description provided for @productCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Scan the product\'s barcode, type it, or tap ✨ to generate one'**
  String get productCodeHelp;

  /// No description provided for @productCodeGeneratedInfo.
  ///
  /// In en, this message translates to:
  /// **'This barcode is saved with the product. You\'ll find it in Inventory › Products (label button) to print and stick on the product; scanning it at the till adds this product.'**
  String get productCodeGeneratedInfo;

  /// No description provided for @productSkuOptional.
  ///
  /// In en, this message translates to:
  /// **'Internal code (SKU) — optional'**
  String get productSkuOptional;

  /// No description provided for @productSkuHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the barcode. Searching or scanning either code finds the product.'**
  String get productSkuHelp;

  /// No description provided for @productPhotoChoose.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get productPhotoChoose;

  /// No description provided for @productPhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get productPhotoChange;

  /// No description provided for @productOpeningStock.
  ///
  /// In en, this message translates to:
  /// **'Starting quantity in stock'**
  String get productOpeningStock;

  /// No description provided for @productStockInBranch.
  ///
  /// In en, this message translates to:
  /// **'In branch: {branch}'**
  String productStockInBranch(String branch);

  /// No description provided for @errorQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get errorQuantityInvalid;

  /// No description provided for @customerLoyaltyValue.
  ///
  /// In en, this message translates to:
  /// **'Points worth'**
  String get customerLoyaltyValue;

  /// No description provided for @customerLoyaltyMember.
  ///
  /// In en, this message translates to:
  /// **'Loyalty member — earns points on every purchase'**
  String get customerLoyaltyMember;

  /// No description provided for @customerDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get customerDebts;

  /// No description provided for @customerNoDebts.
  ///
  /// In en, this message translates to:
  /// **'No debts'**
  String get customerNoDebts;

  /// No description provided for @customerInvoices.
  ///
  /// In en, this message translates to:
  /// **'Latest invoices'**
  String get customerInvoices;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Your PIN'**
  String get confirmYourPin;

  /// No description provided for @accountOwnerProtected.
  ///
  /// In en, this message translates to:
  /// **'The owner\'s account can\'t be deactivated or given another role. Ownership is transferred through a separate, authorised process.'**
  String get accountOwnerProtected;

  /// No description provided for @accountOnlyOwnerForManager.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can deactivate a manager or change who is a manager.'**
  String get accountOnlyOwnerForManager;

  /// No description provided for @accountNotYourself.
  ///
  /// In en, this message translates to:
  /// **'You can\'t deactivate your own account.'**
  String get accountNotYourself;

  /// No description provided for @accountNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t allowed to do this.'**
  String get accountNotAllowed;

  /// No description provided for @accountDeactivateConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name} won\'t be able to sign in any more. Their sales and history are kept. Enter your PIN to confirm.'**
  String accountDeactivateConfirm(String name);

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'{name} was deactivated'**
  String accountDeactivated(String name);

  /// No description provided for @accountRoleChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Changing {name}\'s manager role needs the owner. Enter your PIN to confirm.'**
  String accountRoleChangeConfirm(String name);

  /// No description provided for @activationRevoked.
  ///
  /// In en, this message translates to:
  /// **'This code was cancelled by the developer. Ask for a new code.'**
  String get activationRevoked;

  /// No description provided for @codeRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get codeRevoke;

  /// No description provided for @codeRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get codeRevoked;

  /// No description provided for @codeRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this code?'**
  String get codeRevokeTitle;

  /// No description provided for @codeRevokeMessage.
  ///
  /// In en, this message translates to:
  /// **'The code for \"{store}\" can no longer be used to activate a store.'**
  String codeRevokeMessage(String store);

  /// No description provided for @codeRevokeEndStore.
  ///
  /// In en, this message translates to:
  /// **'Also end the activation of \"{store}\"'**
  String codeRevokeEndStore(String store);

  /// No description provided for @codeRevokeEndStoreHelp.
  ///
  /// In en, this message translates to:
  /// **'Only that store is locked until it enters a new code. Leave unticked to let it keep its current activation.'**
  String get codeRevokeEndStoreHelp;

  /// No description provided for @codeRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this code?'**
  String get codeRemoveTitle;

  /// No description provided for @codeRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'The unused code for \"{store}\" will be removed for good.'**
  String codeRemoveMessage(String store);

  /// No description provided for @codeRemoveUsed.
  ///
  /// In en, this message translates to:
  /// **'A store used this code — revoke it instead.'**
  String get codeRemoveUsed;

  /// No description provided for @breakStart.
  ///
  /// In en, this message translates to:
  /// **'Take a break'**
  String get breakStart;

  /// No description provided for @breakStartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Breaks are up to {minutes} minutes, {perDay} a day. The till locks until you come back and enter your PIN; your shift stays open.'**
  String breakStartConfirm(int minutes, int perDay);

  /// No description provided for @breakOff.
  ///
  /// In en, this message translates to:
  /// **'Breaks are switched off.'**
  String get breakOff;

  /// No description provided for @breakRoleNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Your role can\'t take breaks.'**
  String get breakRoleNotAllowed;

  /// No description provided for @breakAlreadyOn.
  ///
  /// In en, this message translates to:
  /// **'You\'re already on a break.'**
  String get breakAlreadyOn;

  /// No description provided for @breakNoneLeft.
  ///
  /// In en, this message translates to:
  /// **'No breaks left today ({max} a day).'**
  String breakNoneLeft(int max);

  /// No description provided for @breakOnBreak.
  ///
  /// In en, this message translates to:
  /// **'{name} is on a break'**
  String breakOnBreak(String name);

  /// No description provided for @breakTillLocked.
  ///
  /// In en, this message translates to:
  /// **'The till is locked until they come back.'**
  String get breakTillLocked;

  /// No description provided for @breakTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get breakTimeLeft;

  /// No description provided for @breakOverTime.
  ///
  /// In en, this message translates to:
  /// **'over the allowed time'**
  String get breakOverTime;

  /// No description provided for @breakEnterPinToReturn.
  ///
  /// In en, this message translates to:
  /// **'Back? Enter your PIN'**
  String get breakEnterPinToReturn;

  /// No description provided for @breakWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Only the employee on the break can end it, with their own PIN.'**
  String get breakWrongPin;

  /// No description provided for @breakExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Break ran over'**
  String get breakExceededTitle;

  /// No description provided for @breakExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'This break went {minutes} min over the limit. It\'s recorded in today\'s report for the manager.'**
  String breakExceededMessage(int minutes);

  /// No description provided for @breakSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Breaks'**
  String get breakSettingsTitle;

  /// No description provided for @breakEnable.
  ///
  /// In en, this message translates to:
  /// **'Allow breaks'**
  String get breakEnable;

  /// No description provided for @breakEnableHelp.
  ///
  /// In en, this message translates to:
  /// **'Employees can step away without closing their shift; the till locks until they return with their PIN.'**
  String get breakEnableHelp;

  /// No description provided for @breakMaxMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes per break'**
  String get breakMaxMinutes;

  /// No description provided for @breakMaxPerDay.
  ///
  /// In en, this message translates to:
  /// **'Breaks per day'**
  String get breakMaxPerDay;

  /// No description provided for @breakMinutesRange.
  ///
  /// In en, this message translates to:
  /// **'1 to 240'**
  String get breakMinutesRange;

  /// No description provided for @breakPerDayRange.
  ///
  /// In en, this message translates to:
  /// **'1 to 10'**
  String get breakPerDayRange;

  /// No description provided for @breakRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Who may take breaks'**
  String get breakRolesTitle;

  /// No description provided for @breakReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Breaks today'**
  String get breakReportTitle;

  /// No description provided for @breakNoneToday.
  ///
  /// In en, this message translates to:
  /// **'No breaks today'**
  String get breakNoneToday;

  /// No description provided for @breakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String breakCount(int count);

  /// No description provided for @breakStillAway.
  ///
  /// In en, this message translates to:
  /// **'still away'**
  String get breakStillAway;

  /// No description provided for @breakMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String breakMinutes(int minutes);

  /// No description provided for @breakEndedEarly.
  ///
  /// In en, this message translates to:
  /// **'ended early'**
  String get breakEndedEarly;

  /// No description provided for @breakReconciled.
  ///
  /// In en, this message translates to:
  /// **'closed at next sign-in'**
  String get breakReconciled;

  /// No description provided for @breakOverBy.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min over'**
  String breakOverBy(int minutes);

  /// No description provided for @gateLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Try again in a few minutes.'**
  String get gateLocked;

  /// No description provided for @supportSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Support staff sign-in'**
  String get supportSignInTitle;

  /// No description provided for @supportPhoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Number copied'**
  String get supportPhoneCopied;

  /// No description provided for @supportPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Support phone'**
  String get supportPhoneLabel;

  /// No description provided for @supportNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get supportNoMessages;

  /// No description provided for @supportStartHint.
  ///
  /// In en, this message translates to:
  /// **'Write your question below — the support team will answer here, and the whole conversation stays saved.'**
  String get supportStartHint;

  /// No description provided for @supportYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get supportYou;

  /// No description provided for @supportTeam.
  ///
  /// In en, this message translates to:
  /// **'Support team'**
  String get supportTeam;

  /// No description provided for @supportNotSent.
  ///
  /// In en, this message translates to:
  /// **'not sent'**
  String get supportNotSent;

  /// No description provided for @supportSending.
  ///
  /// In en, this message translates to:
  /// **'sending…'**
  String get supportSending;

  /// No description provided for @supportInternalNote.
  ///
  /// In en, this message translates to:
  /// **'Internal note'**
  String get supportInternalNote;

  /// No description provided for @supportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note for the support team only — the store won\'t see it'**
  String get supportNoteHint;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get supportMessageHint;

  /// No description provided for @supportSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supportSend;

  /// No description provided for @supportTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'tap to retry'**
  String get supportTapToRetry;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @contactUsHelp.
  ///
  /// In en, this message translates to:
  /// **'Chat with the support team'**
  String get contactUsHelp;

  /// No description provided for @contactUsSignInToChat.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your store to chat with support, or call us.'**
  String get contactUsSignInToChat;

  /// No description provided for @supportOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach support. Check the connection, or call the number above.'**
  String get supportOffline;

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get supportStatusPending;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @supportPickConversation.
  ///
  /// In en, this message translates to:
  /// **'Choose a conversation'**
  String get supportPickConversation;

  /// No description provided for @supportPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportPortalTitle;

  /// No description provided for @supportPresenceOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get supportPresenceOnline;

  /// No description provided for @supportPresenceBreak.
  ///
  /// In en, this message translates to:
  /// **'On a break'**
  String get supportPresenceBreak;

  /// No description provided for @supportPresenceSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get supportPresenceSignedOut;

  /// No description provided for @supportPresenceDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get supportPresenceDisconnected;

  /// No description provided for @supportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Store name, ID or phone'**
  String get supportSearchHint;

  /// No description provided for @supportNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get supportNoConversations;

  /// No description provided for @supportStoreId.
  ///
  /// In en, this message translates to:
  /// **'Store ID'**
  String get supportStoreId;

  /// No description provided for @supportActivation.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get supportActivation;

  /// No description provided for @supportOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get supportOpened;

  /// No description provided for @supportLastMessage.
  ///
  /// In en, this message translates to:
  /// **'Last message'**
  String get supportLastMessage;

  /// No description provided for @supportAssigned.
  ///
  /// In en, this message translates to:
  /// **'Handled by'**
  String get supportAssigned;

  /// No description provided for @supportTake.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get supportTake;

  /// No description provided for @supportTakeOver.
  ///
  /// In en, this message translates to:
  /// **'Take over'**
  String get supportTakeOver;

  /// No description provided for @supportEmploymentActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get supportEmploymentActive;

  /// No description provided for @supportEmploymentSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get supportEmploymentSuspended;

  /// No description provided for @supportEmploymentTerminated.
  ///
  /// In en, this message translates to:
  /// **'Employment ended'**
  String get supportEmploymentTerminated;

  /// No description provided for @supportAgentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Support employee accounts'**
  String get supportAgentsTitle;

  /// No description provided for @supportCheckedAt.
  ///
  /// In en, this message translates to:
  /// **'Checked {time}'**
  String supportCheckedAt(String time);

  /// No description provided for @supportNoAgents.
  ///
  /// In en, this message translates to:
  /// **'No support employees yet'**
  String get supportNoAgents;

  /// No description provided for @supportLastSeen.
  ///
  /// In en, this message translates to:
  /// **'last seen {time}'**
  String supportLastSeen(String time);

  /// No description provided for @supportAddAgent.
  ///
  /// In en, this message translates to:
  /// **'Add support employee'**
  String get supportAddAgent;

  /// No description provided for @supportAgentCredentialsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and a password of at least 8 characters.'**
  String get supportAgentCredentialsHint;

  /// No description provided for @supportResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get supportResetPassword;

  /// No description provided for @supportPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get supportPasswordRule;

  /// No description provided for @supportEmploymentConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name}: {status}? A suspended or ended account can\'t sign in; its messages and records stay.'**
  String supportEmploymentConfirm(String name, String status);

  /// No description provided for @supportSalaryAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Salary adjustment'**
  String get supportSalaryAdjustment;

  /// No description provided for @supportSalaryAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Deductions and bonuses'**
  String get supportSalaryAdjustments;

  /// No description provided for @supportDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get supportDeduction;

  /// No description provided for @supportBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get supportBonus;

  /// No description provided for @supportReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get supportReason;

  /// No description provided for @supportAdjustmentRule.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount and a reason.'**
  String get supportAdjustmentRule;

  /// No description provided for @supportCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String supportCreatedOn(String date);

  /// No description provided for @supportFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get supportFullName;

  /// No description provided for @supportJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get supportJobTitle;

  /// No description provided for @supportNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get supportNotes;

  /// No description provided for @supportReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get supportReactivate;

  /// No description provided for @supportSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get supportSuspend;

  /// No description provided for @supportTerminate.
  ///
  /// In en, this message translates to:
  /// **'End employment'**
  String get supportTerminate;

  /// No description provided for @breakOffHowTo.
  ///
  /// In en, this message translates to:
  /// **'Breaks are off. The owner or a manager can switch them on in Settings › Breaks.'**
  String get breakOffHowTo;

  /// No description provided for @productDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get productDelete;

  /// No description provided for @productDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String productDeleteTitle(String name);

  /// No description provided for @productDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'It disappears from the products list and the till. Past invoices, returns and stock history keep showing it.'**
  String get productDeleteMessage;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String productDeleted(String name);

  /// No description provided for @stockReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive stock'**
  String get stockReceiveTitle;

  /// No description provided for @stockReceiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Scan or search each product you received, enter the quantity, and a new cost or selling price only if it changed — leave them empty to keep the current prices.'**
  String get stockReceiveHelp;

  /// No description provided for @stockReceiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products added yet'**
  String get stockReceiveEmpty;

  /// No description provided for @stockReceiveNewCost.
  ///
  /// In en, this message translates to:
  /// **'New cost'**
  String get stockReceiveNewCost;

  /// No description provided for @stockReceiveNewPrice.
  ///
  /// In en, this message translates to:
  /// **'New selling price'**
  String get stockReceiveNewPrice;

  /// No description provided for @stockReceiveKeepIfEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty = no change'**
  String get stockReceiveKeepIfEmpty;

  /// No description provided for @stockReceiveSave.
  ///
  /// In en, this message translates to:
  /// **'Add to stock ({count})'**
  String stockReceiveSave(int count);

  /// No description provided for @stockReceiveDone.
  ///
  /// In en, this message translates to:
  /// **'Stock added for {count} products'**
  String stockReceiveDone(int count);

  /// No description provided for @stockReceiveInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the quantity and prices of \"{name}\"'**
  String stockReceiveInvalid(String name);

  /// No description provided for @stockReceivePartial.
  ///
  /// In en, this message translates to:
  /// **'Saved {done} of {total}. Check the connection and save the rest again.'**
  String stockReceivePartial(int done, int total);

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @offlineWithPending.
  ///
  /// In en, this message translates to:
  /// **'Offline · {count} waiting'**
  String offlineWithPending(int count);

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing {count}…'**
  String syncInProgress(int count);

  /// No description provided for @statusOnlineHelp.
  ///
  /// In en, this message translates to:
  /// **'Connected — everything is saved to the server as you work.'**
  String get statusOnlineHelp;

  /// No description provided for @statusOfflineHelp.
  ///
  /// In en, this message translates to:
  /// **'No internet — keep selling. Sales are kept on this device and sent automatically when the connection is back. Tap to check now.'**
  String get statusOfflineHelp;

  /// No description provided for @posStockLeft.
  ///
  /// In en, this message translates to:
  /// **'{name}: {count} left in stock'**
  String posStockLeft(String name, int count);

  /// No description provided for @posStockOut.
  ///
  /// In en, this message translates to:
  /// **'{name} is out of stock — not added'**
  String posStockOut(String name);

  /// No description provided for @posStockMaxReached.
  ///
  /// In en, this message translates to:
  /// **'{name}: only {count} in stock'**
  String posStockMaxReached(String name, int count);

  /// No description provided for @posStockCartAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Stock changed, quantities lowered: {items}. Check the cart and try again.'**
  String posStockCartAdjusted(String items);

  /// No description provided for @posStockBadge.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count}'**
  String posStockBadge(int count);

  /// No description provided for @posStockOutBadge.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get posStockOutBadge;

  /// No description provided for @posSetQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get posSetQuantity;

  /// No description provided for @pinDeviceInUse.
  ///
  /// In en, this message translates to:
  /// **'This account is already open on another device ({device}). Sign out there first, or ask the owner or a manager to release it.'**
  String pinDeviceInUse(String device);

  /// No description provided for @hrOpenOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Open on: {device}'**
  String hrOpenOnDevice(String device);

  /// No description provided for @hrReleaseDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out from device'**
  String get hrReleaseDevice;

  /// No description provided for @hrReleaseDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign {name} out of the device holding the account, so they can sign in on another one?'**
  String hrReleaseDeviceConfirm(String name);

  /// No description provided for @hrDeviceReleased.
  ///
  /// In en, this message translates to:
  /// **'{name} can now sign in on another device'**
  String hrDeviceReleased(String name);

  /// No description provided for @syncFailedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} not saved'**
  String syncFailedCount(int count);

  /// No description provided for @syncFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes the server refused'**
  String get syncFailedTitle;

  /// No description provided for @syncFailedHelp.
  ///
  /// In en, this message translates to:
  /// **'These were made on this device but the server didn\'t accept them (for example the item was changed or removed on another device). They are kept here. Retry once the cause is fixed.'**
  String get syncFailedHelp;

  /// No description provided for @needsConnection.
  ///
  /// In en, this message translates to:
  /// **'This needs an internet connection. Try again when you\'re back online.'**
  String get needsConnection;

  /// No description provided for @returnWaitSync.
  ///
  /// In en, this message translates to:
  /// **'This sale was made offline and hasn\'t reached the server yet. Return it once it has synced.'**
  String get returnWaitSync;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @posCartSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} items · {total}'**
  String posCartSummary(int count, String total);

  /// No description provided for @posMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get posMoreActions;

  /// No description provided for @posScanCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with the camera'**
  String get posScanCamera;

  /// No description provided for @shiftCashDebtPayments.
  ///
  /// In en, this message translates to:
  /// **'Debt payments in cash'**
  String get shiftCashDebtPayments;

  /// No description provided for @shiftCashRefunds.
  ///
  /// In en, this message translates to:
  /// **'Cash refunds'**
  String get shiftCashRefunds;

  /// No description provided for @shiftCashForeign.
  ///
  /// In en, this message translates to:
  /// **'Also in the drawer: {amount}'**
  String shiftCashForeign(String amount);

  /// No description provided for @shiftCashOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'No connection: worked out from what this device knows. The server works it out again when the shift\'s close reaches it.'**
  String get shiftCashOfflineNote;

  /// No description provided for @shiftDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference: {amount}'**
  String shiftDifference(String amount);

  /// No description provided for @debtsPayMoreThanOwed.
  ///
  /// In en, this message translates to:
  /// **'That\'s more than what is owed ({amount})'**
  String debtsPayMoreThanOwed(String amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ckb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
