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
