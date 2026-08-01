import 'package:drift/drift.dart';

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text()();
  TextColumn get cashierId => text()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get openingCashFloatMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get expectedCashAtCloseMinorUnits => integer().nullable()();
  IntColumn get countedCashAtCloseMinorUnits => integer().nullable()();
  IntColumn get discrepancyMinorUnits => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))(); // open/closed

  @override
  Set<Column> get primaryKey => {id};
}
