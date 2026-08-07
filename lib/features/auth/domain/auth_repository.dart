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

  Future<void> updateEmployee(EmployeeRecord employee, {String? newPin});

  Future<void> setEmployeeActive(String employeeId, bool isActive);

  Stream<List<EmployeeRecord>> watchEmployees(String storeId);

  Future<EmployeeRecord?> findEmployeeByPin(String storeId, String pin);
}
