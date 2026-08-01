import 'package:drift/drift.dart';

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get userId => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get beforeValueJson => text().nullable()();
  TextColumn get afterValueJson => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
