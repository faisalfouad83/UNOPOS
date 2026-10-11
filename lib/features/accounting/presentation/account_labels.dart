import '../../../core/l10n/gen/app_localizations.dart';
import '../../pos/domain/pos_models.dart';
import '../domain/accounting_models.dart';

String journalReferenceLabel(AppLocalizations l10n, JournalReferenceType type) => switch (type) {
      JournalReferenceType.sale => l10n.journalSale,
      JournalReferenceType.purchase => l10n.journalPurchase,
      JournalReferenceType.supplierPayment => l10n.journalSupplierPayment,
      JournalReferenceType.debtPayment => l10n.journalDebtPayment,
      JournalReferenceType.expense => l10n.journalExpense,
      JournalReferenceType.returnEntry => l10n.journalReturn,
      JournalReferenceType.adjustment => l10n.journalAdjustment,
      JournalReferenceType.manual => l10n.journalManual,
      JournalReferenceType.openingBalance => l10n.journalOpeningBalance,
    };

/// Section heading for an account type ('asset', 'liability', ...).
String accountTypeLabel(AppLocalizations l10n, String type) => switch (type) {
      'asset' => l10n.acctAssets,
      'liability' => l10n.acctLiabilities,
      'equity' => l10n.acctEquity,
      'revenue' => l10n.acctRevenueType,
      'cogs' => l10n.acctTypeCogs,
      'expense' => l10n.acctExpenses,
      _ => type,
    };

/// The built-in accounts are named in the app's language; accounts the
/// store added itself keep the name they were given.
String accountLabel(AppLocalizations l10n, String code, String fallback) => switch (code) {
      '1000' => l10n.account1000,
      '1010' => l10n.account1010,
      '1100' => l10n.account1100,
      '1200' => l10n.account1200,
      '2000' => l10n.account2000,
      '2100' => l10n.account2100,
      '3000' => l10n.account3000,
      '3100' => l10n.account3100,
      '4000' => l10n.account4000,
      '4100' => l10n.account4100,
      '4200' => l10n.account4200,
      '5000' => l10n.account5000,
      '6000' => l10n.account6000,
      '6010' => l10n.account6010,
      '6020' => l10n.account6020,
      '6030' => l10n.account6030,
      '6040' => l10n.account6040,
      '6050' => l10n.account6050,
      '6060' => l10n.account6060,
      _ => fallback,
    };

String paymentMethodLabel(AppLocalizations l10n, SalePaymentMethod? method) => switch (method) {
      SalePaymentMethod.cash => l10n.receiptCash,
      SalePaymentMethod.card => l10n.receiptCard,
      SalePaymentMethod.payLater => l10n.posPayLater,
      null => '',
    };

/// Entries the app posts itself carry an English memo; show it in the
/// app's language. Memos typed by people are shown as written.
String journalMemoLabel(AppLocalizations l10n, String memo) => switch (memo) {
      'Cash sale' => l10n.memoCashSale,
      'Card sale' => l10n.memoCardSale,
      'Pay-later sale (on account)' => l10n.memoPayLaterSale,
      'Customer debt payment received' => l10n.memoDebtPayment,
      'Supplier purchase (paid)' => l10n.memoPurchasePaid,
      'Supplier purchase (on credit)' => l10n.memoPurchaseCredit,
      'Payment to supplier' => l10n.memoSupplierPayment,
      'Sale return / refund' => l10n.memoSaleReturn,
      'Stock shrinkage / adjustment' => l10n.memoShrinkage,
      _ => memo,
    };
