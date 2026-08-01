import 'package:drift/drift.dart';

/// A single tenant. Today exactly one row exists per local install; the
/// `id` doubles as the natural sharding key once this moves to a shared
/// cloud backend.
class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get storeLoginId => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get displayName => text()();
  TextColumn get activationCodeId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Branch')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  BoolColumn get isMainBranch => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Employees, including owners/managers. The hidden Developer identity is
/// NEVER a row here — see core/constants/roles.dart.
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get role => text()(); // StoreRole.name
  TextColumn get pinHash => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();

  /// Salary/allowances live here (not a separate HR table) since an
  /// employee IS the HR record; the HR feature is just a role-gated view
  /// over this same table with extra fields visible.
  IntColumn get salaryMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get allowancesMinorUnits => integer().withDefault(const Constant(0))();

  TextColumn get avatarColorHex => text().withDefault(const Constant('#0F6E5C'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
