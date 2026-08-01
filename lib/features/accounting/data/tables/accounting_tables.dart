import 'package:drift/drift.dart';

class ChartOfAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // asset/liability/equity/revenue/cogs/expense
  TextColumn get parentAccountId => text().nullable()();
  BoolColumn get isSystemAccount => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One header per business transaction. Never edited or deleted after
/// creation — corrections are reversing entries pointing back via
/// [reversalOfEntryId], so the ledger stays a true immutable audit trail.
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get referenceType => text()(); // SALE/PURCHASE/SUPPLIER_PAYMENT/DEBT_PAYMENT/EXPENSE/RETURN/ADJUSTMENT/MANUAL/OPENING_BALANCE
  TextColumn get referenceId => text().nullable()();
  TextColumn get memo => text().withDefault(const Constant(''))();
  TextColumn get createdByUserId => text()();
  BoolColumn get isReversal => boolean().withDefault(const Constant(false))();
  TextColumn get reversalOfEntryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalLines extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get journalEntryId => text()();
  TextColumn get accountId => text()();
  IntColumn get debitMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get creditMinorUnits => integer().withDefault(const Constant(0))();
  TextColumn get description => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
