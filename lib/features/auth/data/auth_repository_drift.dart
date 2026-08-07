import 'package:drift/drift.dart';

import '../../../core/constants/roles.dart';
import '../../../core/database/app_database.dart';
import '../../../core/security/passcode_hasher.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class DriftAuthRepository implements AuthRepository {
  DriftAuthRepository(this._db);

  final AppDatabase _db;

  StoreRecord _mapStore(Store row) => StoreRecord(
        id: row.id,
        storeLoginId: row.storeLoginId,
        passwordHash: row.passwordHash,
        displayName: row.displayName,
        activationCodeId: row.activationCodeId,
        createdAt: row.createdAt,
        isActive: row.isActive,
      );

  BranchRecord _mapBranch(Branch row) => BranchRecord(
        id: row.id,
        storeId: row.storeId,
        name: row.name,
        address: row.address,
        phone: row.phone,
        isMainBranch: row.isMainBranch,
        isActive: row.isActive,
      );

  EmployeeRecord _mapEmployee(User row) => EmployeeRecord(
        id: row.id,
        storeId: row.storeId,
        branchId: row.branchId,
        name: row.name,
        role: StoreRole.fromName(row.role),
        pinHash: row.pinHash,
        phone: row.phone,
        address: row.address,
        salaryMinorUnits: row.salaryMinorUnits,
        allowancesMinorUnits: row.allowancesMinorUnits,
        avatarColorHex: row.avatarColorHex,
        isActive: row.isActive,
      );

  @override
  Future<StoreRecord?> getCurrentStore() async {
    final rows = await _db.select(_db.stores).get();
    if (rows.isEmpty) return null;
    return _mapStore(rows.first);
  }

  @override
  Future<StoreRecord> createStore({
    required String storeLoginId,
    required String password,
    required String displayName,
    String? activationCodeId,
    String ownerName = '',
    String phone = '',
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _db.into(_db.stores).insert(
          StoresCompanion.insert(
            id: id,
            storeLoginId: storeLoginId,
            passwordHash: PasscodeHasher.hash(password),
            displayName: displayName,
            activationCodeId: Value(activationCodeId),
            createdAt: now,
          ),
        );
    // ownerName/phone aren't columns in the local schema (see
    // core/database/app_database.dart) — Drift mode stays untouched as the
    // foundation for a future offline-sync mode, so these are accepted for
    // interface parity but not persisted here. The Supabase implementation
    // does persist them.
    return StoreRecord(
      id: id,
      storeLoginId: storeLoginId,
      passwordHash: '',
      displayName: displayName,
      activationCodeId: activationCodeId,
      createdAt: now,
      ownerName: ownerName,
      phone: phone,
    );
  }

  @override
  Future<bool> verifyStorePassword(String storeLoginId, String password) async {
    final row = await (_db.select(_db.stores)
          ..where((t) => t.storeLoginId.equals(storeLoginId)))
        .getSingleOrNull();
    if (row == null) return false;
    return PasscodeHasher.verify(password, row.passwordHash);
  }

  @override
  Future<BranchRecord> createBranch({
    required String storeId,
    required String name,
    String address = '',
    String phone = '',
    bool isMainBranch = false,
  }) async {
    final id = IdGenerator.newId();
    await _db.into(_db.branches).insert(
          BranchesCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            address: Value(address),
            phone: Value(phone),
            isMainBranch: Value(isMainBranch),
            createdAt: DateTime.now(),
          ),
        );
    return BranchRecord(
      id: id,
      storeId: storeId,
      name: name,
      address: address,
      phone: phone,
      isMainBranch: isMainBranch,
    );
  }

  @override
  Future<List<BranchRecord>> listBranches(String storeId) async {
    final rows = await (_db.select(_db.branches)..where((t) => t.storeId.equals(storeId))).get();
    return rows.map(_mapBranch).toList();
  }

  @override
  Future<void> updateBranch(BranchRecord branch) async {
    await (_db.update(_db.branches)..where((t) => t.id.equals(branch.id))).write(
      BranchesCompanion(
        name: Value(branch.name),
        address: Value(branch.address),
        phone: Value(branch.phone),
        isMainBranch: Value(branch.isMainBranch),
        isActive: Value(branch.isActive),
      ),
    );
  }

  @override
  Future<EmployeeRecord> createEmployee({
    required String storeId,
    String? branchId,
    required String name,
    required String role,
    required String pin,
    String phone = '',
    String address = '',
    int salaryMinorUnits = 0,
    int allowancesMinorUnits = 0,
    String avatarColorHex = '#0F6E5C',
  }) async {
    final id = IdGenerator.newId();
    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            id: id,
            storeId: storeId,
            branchId: Value(branchId),
            name: name,
            role: role,
            pinHash: PasscodeHasher.hash(pin),
            phone: Value(phone),
            address: Value(address),
            salaryMinorUnits: Value(salaryMinorUnits),
            allowancesMinorUnits: Value(allowancesMinorUnits),
            avatarColorHex: Value(avatarColorHex),
            createdAt: DateTime.now(),
          ),
        );
    return EmployeeRecord(
      id: id,
      storeId: storeId,
      branchId: branchId,
      name: name,
      role: StoreRole.fromName(role),
      pinHash: '',
      phone: phone,
      address: address,
      salaryMinorUnits: salaryMinorUnits,
      allowancesMinorUnits: allowancesMinorUnits,
      avatarColorHex: avatarColorHex,
    );
  }

  @override
  Future<void> updateEmployee(EmployeeRecord employee, {String? newPin}) async {
    await (_db.update(_db.users)..where((t) => t.id.equals(employee.id))).write(
      UsersCompanion(
        name: Value(employee.name),
        role: Value(employee.role.name),
        branchId: Value(employee.branchId),
        phone: Value(employee.phone),
        address: Value(employee.address),
        salaryMinorUnits: Value(employee.salaryMinorUnits),
        allowancesMinorUnits: Value(employee.allowancesMinorUnits),
        avatarColorHex: Value(employee.avatarColorHex),
        isActive: Value(employee.isActive),
        pinHash: newPin != null ? Value(PasscodeHasher.hash(newPin)) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> setEmployeeActive(String employeeId, bool isActive) async {
    await (_db.update(_db.users)..where((t) => t.id.equals(employeeId)))
        .write(UsersCompanion(isActive: Value(isActive)));
  }

  @override
  Stream<List<EmployeeRecord>> watchEmployees(String storeId) {
    return (_db.select(_db.users)
          ..where((t) => t.storeId.equals(storeId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_mapEmployee).toList());
  }

  @override
  Future<EmployeeRecord?> findEmployeeByPin(String storeId, String pin) async {
    final rows = await (_db.select(_db.users)
          ..where((t) => t.storeId.equals(storeId) & t.isActive.equals(true)))
        .get();
    for (final row in rows) {
      if (PasscodeHasher.verify(pin, row.pinHash)) {
        return _mapEmployee(row);
      }
    }
    return null;
  }
}
