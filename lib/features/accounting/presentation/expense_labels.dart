import '../../../core/l10n/gen/app_localizations.dart';
import '../domain/expense_categories.dart';

String expenseGroupLabel(AppLocalizations l10n, ExpenseGroup group) => switch (group) {
      ExpenseGroup.fixed => l10n.expenseGroupFixed,
      ExpenseGroup.variable => l10n.expenseGroupVariable,
      ExpenseGroup.negligible => l10n.expenseGroupNegligible,
      ExpenseGroup.custom => l10n.expenseGroupCustom,
    };

/// A built-in category's name in the app language; a custom one as typed.
String expenseCategoryLabel(AppLocalizations l10n, ExpenseGroup group, String key) {
  final category = group == ExpenseGroup.custom ? null : ExpenseCategory.fromKey(key);
  return switch (category) {
    null => key,
    ExpenseCategory.rent => l10n.expenseRent,
    ExpenseCategory.salaries => l10n.expenseSalaries,
    ExpenseCategory.generatorElectricity => l10n.expenseGeneratorElectricity,
    ExpenseCategory.nationalElectricity => l10n.expenseNationalElectricity,
    ExpenseCategory.water => l10n.expenseWater,
    ExpenseCategory.internet => l10n.expenseInternet,
    ExpenseCategory.solarPower => l10n.expenseSolarPower,
    ExpenseCategory.software => l10n.expenseSoftware,
    ExpenseCategory.materials => l10n.expenseMaterials,
    ExpenseCategory.transport => l10n.expenseTransport,
    ExpenseCategory.cleaningSupplies => l10n.expenseCleaningSupplies,
    ExpenseCategory.packaging => l10n.expensePackaging,
    ExpenseCategory.deliveryAppCommission => l10n.expenseDeliveryAppCommission,
    ExpenseCategory.wasteAndDamage => l10n.expenseWasteAndDamage,
    ExpenseCategory.maintenance => l10n.expenseMaintenance,
    ExpenseCategory.staffMeals => l10n.expenseStaffMeals,
    ExpenseCategory.annualFees => l10n.expenseAnnualFees,
    ExpenseCategory.hospitality => l10n.expenseHospitality,
  };
}
