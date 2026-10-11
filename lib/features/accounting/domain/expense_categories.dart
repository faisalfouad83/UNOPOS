import '../../../core/constants/default_chart_of_accounts.dart';

/// How a store classifies its spending: fixed (every month regardless of
/// sales), variable (moves with sales), negligible (small/irregular), or a
/// custom type the cashier names.
enum ExpenseGroup { fixed, variable, negligible, custom }

/// The built-in categories under each group. Stored by [key] (never the
/// translated label); a custom expense stores the typed name instead.
enum ExpenseCategory {
  rent(ExpenseGroup.fixed, SystemAccountCodes.rentExpense),
  salaries(ExpenseGroup.fixed, SystemAccountCodes.salariesExpense),
  generatorElectricity(ExpenseGroup.fixed, SystemAccountCodes.utilitiesExpense),
  nationalElectricity(ExpenseGroup.fixed, SystemAccountCodes.utilitiesExpense),
  water(ExpenseGroup.fixed, SystemAccountCodes.utilitiesExpense),
  internet(ExpenseGroup.fixed, SystemAccountCodes.utilitiesExpense),
  solarPower(ExpenseGroup.fixed, SystemAccountCodes.utilitiesExpense),
  software(ExpenseGroup.fixed, SystemAccountCodes.miscExpense),

  materials(ExpenseGroup.variable, SystemAccountCodes.suppliesExpense),
  transport(ExpenseGroup.variable, SystemAccountCodes.miscExpense),
  cleaningSupplies(ExpenseGroup.variable, SystemAccountCodes.suppliesExpense),
  packaging(ExpenseGroup.variable, SystemAccountCodes.suppliesExpense),
  deliveryAppCommission(ExpenseGroup.variable, SystemAccountCodes.miscExpense),

  wasteAndDamage(ExpenseGroup.negligible, SystemAccountCodes.shrinkageExpense),
  maintenance(ExpenseGroup.negligible, SystemAccountCodes.miscExpense),
  staffMeals(ExpenseGroup.negligible, SystemAccountCodes.miscExpense),
  annualFees(ExpenseGroup.negligible, SystemAccountCodes.miscExpense),
  hospitality(ExpenseGroup.negligible, SystemAccountCodes.miscExpense);

  const ExpenseCategory(this.group, this.accountCode);

  final ExpenseGroup group;

  /// The chart-of-accounts expense account the amount is posted to.
  final String accountCode;

  String get key => name;

  static List<ExpenseCategory> of(ExpenseGroup group) => values.where((c) => c.group == group).toList();

  static ExpenseCategory? fromKey(String key) => values.where((c) => c.key == key).firstOrNull;
}

/// The type recorded for one expense (its journal entry).
class ExpenseDetailRecord {
  const ExpenseDetailRecord({
    required this.journalEntryId,
    required this.storeId,
    required this.group,
    required this.category,
    required this.amountMinorUnits,
    required this.entryDate,
  });

  final String journalEntryId;
  final String storeId;
  final ExpenseGroup group;

  /// An [ExpenseCategory.key], or the typed name for a custom expense.
  final String category;
  final int amountMinorUnits;
  final DateTime entryDate;

  ExpenseCategory? get builtIn => group == ExpenseGroup.custom ? null : ExpenseCategory.fromKey(category);
}

abstract class ExpenseDetailsRepository {
  Future<void> save(ExpenseDetailRecord detail);

  /// Change an existing expense's type later.
  Future<void> updateType(String journalEntryId, ExpenseGroup group, String category);

  Stream<List<ExpenseDetailRecord>> watch(String storeId, {required DateTime from});
}

/// Totals per group and per category over a period.
class ExpenseBreakdown {
  ExpenseBreakdown(Iterable<ExpenseDetailRecord> details) {
    for (final d in details) {
      total += d.amountMinorUnits;
      byGroup[d.group] = (byGroup[d.group] ?? 0) + d.amountMinorUnits;
      final key = (d.group, d.category);
      byCategory[key] = (byCategory[key] ?? 0) + d.amountMinorUnits;
    }
  }

  int total = 0;
  final Map<ExpenseGroup, int> byGroup = {};
  final Map<(ExpenseGroup, String), int> byCategory = {};
}
