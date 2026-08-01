import 'package:drift/drift.dart';

class BackupLogs extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get filePath => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get type => text()(); // manual/automatic
  TextColumn get status => text()(); // success/failed
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
