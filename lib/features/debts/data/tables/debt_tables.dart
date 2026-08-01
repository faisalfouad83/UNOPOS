import 'package:drift/drift.dart';

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DebtLedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text()();
  TextColumn get customerId => text()();
  TextColumn get saleId => text().nullable()();
  TextColumn get journalEntryId => text().nullable()();
  IntColumn get originalAmountMinorUnits => integer()();
  IntColumn get amountPaidMinorUnits => integer().withDefault(const Constant(0))();
  TextColumn get receiptRef => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))(); // open/partiallyPaid/paid
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DebtPayments extends Table {
  TextColumn get id => text()();
  TextColumn get debtLedgerEntryId => text()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get paymentMethod => text()(); // cash/card
  TextColumn get receivedByUserId => text()();
  TextColumn get journalEntryId => text().nullable()();
  DateTimeColumn get paidAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
