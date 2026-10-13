import 'package:drift/drift.dart';

/// An employee's break: started, ended (null while away), and how it ended.
class EmployeeBreaks extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get shiftId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get allowedMinutes => integer()();
  TextColumn get endKind => text().nullable()(); // returned/early/reconciled
  IntColumn get exceededMinutes => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
