import 'package:drift/drift.dart';

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A running record of everything owed to / paid to a supplier. The
/// supplier's current balance is a live query (sum of purchases minus
/// payments) rather than a value trusted to stay in sync on its own.
class SupplierTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get supplierId => text()();
  TextColumn get type => text()(); // purchase/payment/adjustment
  IntColumn get amountMinorUnits => integer()();
  TextColumn get relatedPurchaseOrderId => text().nullable()();
  DateTimeColumn get deliveryDate => dateTime().nullable()();
  TextColumn get journalEntryId => text().nullable()();
  TextColumn get createdByUserId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
