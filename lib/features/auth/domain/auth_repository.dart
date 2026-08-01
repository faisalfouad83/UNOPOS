import 'auth_models.dart';

abstract class AuthRepository {
  /// Null if no store has been created on this install yet (first run).
  Future<StoreRecord?> getCurrentStore();

  Future<StoreRecord> createStore({
    required String storeLoginId,
    required String password,
    required String displayName,
    required String activationCodeId,
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
