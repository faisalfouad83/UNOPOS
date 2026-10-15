import '../../../core/constants/roles.dart';
import 'auth_models.dart';

abstract class AuthRepository {
  /// Null if no store has been created on this install yet (first run).
  Future<StoreRecord?> getCurrentStore();

  /// [activationCodeId] is optional: SaaS registration creates a store on a
  /// free trial with no code up front (licensing happens later, separately,
  /// via [LicensingRepository.redeemCode] or the Developer Console).
  Future<StoreRecord> createStore({
    required String storeLoginId,
    required String password,
    required String displayName,
    String? activationCodeId,
    String ownerName = '',
    String phone = '',
  });

  Future<bool> verifyStorePassword(String storeLoginId, String password);

  Future<BranchRecord> createBranch({
    required String storeId,
    required String name,
    String address = '',
    String phone = '',
    bool isMainBranch = false,
  });

  Future<List<BranchRecord>> listBranches(String storeId);

  /// [isActive] false is a soft delete — branches are referenced by
  /// employees, sales, stock, etc., so removing the row outright risks
  /// foreign-key failures against historical data. Deactivated branches
  /// stay in listBranches() so Settings can still show/reactivate them.
  Future<void> updateBranch(BranchRecord branch);

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
  });

  /// Saves [employee]'s details. A PIN is changed with [setEmployeePin].
  Future<void> updateEmployee(EmployeeRecord employee);

  /// Changes [employeeId]'s PIN on behalf of [actorId], who proves it with
  /// their own PIN (see `canChangePin`). Refused with AccountChangeException.
  Future<void> setEmployeePin({
    required String employeeId,
    required String newPin,
    required String actorId,
    required String actorPin,
  });

  Future<void> setEmployeeActive(String employeeId, bool isActive);

  /// Deactivates [employeeId] on behalf of [actorId], who proves it with
  /// their own PIN. Refused (AccountChangeException) for the owner's
  /// account, for a manager unless the actor is the owner, and for oneself.
  Future<void> deactivateEmployee({required String employeeId, required String actorId, required String actorPin});

  /// Changes [employeeId]'s role on behalf of [actorId] (PIN-checked); the
  /// owner alone makes or unmakes managers, nobody becomes owner.
  Future<void> changeEmployeeRole({
    required String employeeId,
    required StoreRole newRole,
    required String actorId,
    required String actorPin,
  });

  Stream<List<EmployeeRecord>> watchEmployees(String storeId);

  /// The active employee with [pin]; with [employeeId], only that employee
  /// (two employees may share a PIN). Throws [PinLockedException] after too
  /// many wrong PINs in a row.
  Future<EmployeeRecord?> findEmployeeByPin(String storeId, String pin, {String? employeeId});
}
