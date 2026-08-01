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
    Sales,
    SaleLines,
    SaleReturns,
    SaleReturnLines,
    Shifts,
    AppSettingsTable,
    BackupLogs,
    AuditLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Used only by unit tests, so repositories can be exercised against a
  /// fast in-memory database instead of the real file.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}
