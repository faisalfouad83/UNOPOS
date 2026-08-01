enum AccountType { asset, liability, equity, revenue, cogs, expense }

class DefaultAccountSeed {
  const DefaultAccountSeed({
    required this.code,
    required this.name,
    required this.type,
    this.isSystemAccount = true,
  });

  final String code;
  final String name;
  final AccountType type;
  final bool isSystemAccount;
}

/// Well-known account codes referenced directly by the posting rules in
/// AccountingPostingService — keep these in sync if the seed list changes.
class SystemAccountCodes {
  const SystemAccountCodes._();
  static const String cash = '1000';
  static const String bank = '1010';
  static const String accountsReceivable = '1100';
  static const String inventory = '1200';
  static const String accountsPayable = '2000';
  static const String vatPayable = '2100';
  static const String ownersEquity = '3000';
  static const String retainedEarnings = '3100';
  static const String salesRevenue = '4000';
  static const String salesReturns = '4100';
  static const String discountsGiven = '4200';
  static const String costOfGoodsSold = '5000';
  static const String rentExpense = '6000';
  static const String utilitiesExpense = '6010';
  static const String salariesExpense = '6020';
  static const String suppliesExpense = '6030';
  static const String miscExpense = '6040';
  static const String cardFeesExpense = '6050';
  static const String shrinkageExpense = '6060';
}

/// Seeded into every new store's Chart of Accounts at onboarding time.
const List<DefaultAccountSeed> kDefaultChartOfAccounts = [
  DefaultAccountSeed(code: SystemAccountCodes.cash, name: 'Cash on Hand', type: AccountType.asset),
  DefaultAccountSeed(code: SystemAccountCodes.bank, name: 'Bank Account', type: AccountType.asset),
  DefaultAccountSeed(code: SystemAccountCodes.accountsReceivable, name: 'Accounts Receivable', type: AccountType.asset),
  DefaultAccountSeed(code: SystemAccountCodes.inventory, name: 'Inventory', type: AccountType.asset),
  DefaultAccountSeed(code: SystemAccountCodes.accountsPayable, name: 'Accounts Payable', type: AccountType.liability),
  DefaultAccountSeed(code: SystemAccountCodes.vatPayable, name: 'VAT / Sales Tax Payable', type: AccountType.liability),
  DefaultAccountSeed(code: SystemAccountCodes.ownersEquity, name: "Owner's Equity", type: AccountType.equity),
  DefaultAccountSeed(code: SystemAccountCodes.retainedEarnings, name: 'Retained Earnings', type: AccountType.equity),
  DefaultAccountSeed(code: SystemAccountCodes.salesRevenue, name: 'Sales Revenue', type: AccountType.revenue),
  DefaultAccountSeed(code: SystemAccountCodes.salesReturns, name: 'Sales Returns & Allowances', type: AccountType.revenue),
  DefaultAccountSeed(code: SystemAccountCodes.discountsGiven, name: 'Discounts Given', type: AccountType.revenue),
  DefaultAccountSeed(code: SystemAccountCodes.costOfGoodsSold, name: 'Cost of Goods Sold', type: AccountType.cogs),
  DefaultAccountSeed(code: SystemAccountCodes.rentExpense, name: 'Rent Expense', type: AccountType.expense),
  DefaultAccountSeed(code: SystemAccountCodes.utilitiesExpense, name: 'Utilities Expense', type: AccountType.expense),
  DefaultAccountSeed(code: SystemAccountCodes.salariesExpense, name: 'Salaries & Wages Expense', type: AccountType.expense),
  DefaultAccountSeed(code: SystemAccountCodes.suppliesExpense, name: 'Supplies Expense', type: AccountType.expense),
  DefaultAccountSeed(code: SystemAccountCodes.miscExpense, name: 'General / Miscellaneous Expense', type: AccountType.expense),
  DefaultAccountSeed(code: SystemAccountCodes.cardFeesExpense, name: 'Card Processing Fees', type: AccountType.expense),
  DefaultAccountSeed(code: SystemAccountCodes.shrinkageExpense, name: 'Inventory Shrinkage Expense', type: AccountType.expense),
];
