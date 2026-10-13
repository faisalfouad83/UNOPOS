import 'package:drift/drift.dart';

import 'connection.dart';
import '../../features/auth/data/tables/store_tables.dart';
import '../../features/licensing/data/tables/activation_tables.dart';
import '../../features/inventory/data/tables/inventory_tables.dart';
import '../../features/debts/data/tables/debt_tables.dart';
import '../../features/suppliers/data/tables/supplier_tables.dart';
import '../../features/accounting/data/tables/accounting_tables.dart';
import '../../features/pos/data/tables/pos_tables.dart';
import '../../features/shifts/data/tables/shift_tables.dart';
import '../../features/settings/data/tables/settings_tables.dart';
import '../../features/backup/data/tables/backup_tables.dart';
import '../../features/audit/data/tables/audit_tables.dart';
import '../../features/breaks/data/tables/break_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Stores,
    Branches,
    Users,
    ActivationCodes,
    Categories,
    TaxRates,
    Products,
    StockItems,
    StockMovements,
    StockTransfers,
    StockTransferLines,
    PurchaseOrders,
    PurchaseOrderLines,
    Discounts,
    Customers,
    DebtLedgerEntries,
    DebtPayments,
    Suppliers,
    SupplierTransactions,
    ChartOfAccounts,
    JournalEntries,
    JournalLines,
    ExpenseDetails,
    Sales,
    SaleLines,
    SaleReturns,
    SaleReturnLines,
    Shifts,
    AppSettingsTable,
    BackupLogs,
    AuditLogs,
    EmployeeBreaks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Used only by unit tests, so repositories can be exercised against a
  /// fast in-memory database instead of the real file.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(appSettingsTable, appSettingsTable.usdExchangeRate);
          }
          if (from < 3) {
            await m.addColumn(products, products.wholesalePriceMinorUnits);
            await m.addColumn(products, products.expiryDate);
          }
          if (from < 4) {
            await m.addColumn(customers, customers.loyaltyPoints);
            await m.addColumn(appSettingsTable, appSettingsTable.loyaltySpendPerPointMinor);
            await m.addColumn(appSettingsTable, appSettingsTable.loyaltyPointValueMinor);
          }
          if (from < 5) {
            await m.addColumn(appSettingsTable, appSettingsTable.loyaltyEnabled);
            await m.addColumn(appSettingsTable, appSettingsTable.fullDiscountKeepsMargin);
            await m.addColumn(users, users.permissions);
            await m.createTable(expenseDetails);
            // Loyalty used to be "on" whenever an earn rate was set.
            await customStatement(
              'UPDATE app_settings_table SET loyalty_enabled = 1 WHERE loyalty_spend_per_point_minor > 0',
            );
          }
          if (from < 6) {
            await m.addColumn(saleLines, saleLines.quantityReturned);
            await customStatement(
              'UPDATE sale_lines SET quantity_returned = (SELECT COALESCE(SUM(r.quantity_returned), 0) '
              'FROM sale_return_lines r WHERE r.sale_line_id = sale_lines.id)',
            );
          }
          if (from < 7) {
            await m.addColumn(appSettingsTable, appSettingsTable.breakEnabled);
            await m.addColumn(appSettingsTable, appSettingsTable.breakMaxMinutes);
            await m.addColumn(appSettingsTable, appSettingsTable.breakMaxPerDay);
            await m.addColumn(appSettingsTable, appSettingsTable.breakRoles);
            await m.createTable(employeeBreaks);
          }
        },
      );
}
