import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/roles.dart';
import '../../../core/supabase/supabase_config.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

/// Supabase-backed implementation of [AuthRepository]. The STORE is the
/// authenticated Supabase Auth principal (Store ID + Password mapped to a
/// synthetic email); employees never get their own Supabase Auth account —
/// they authenticate at the app layer via PIN, checked server-side by the
/// `verify_employee_pin` function (see supabase/migrations/0001_...sql),
/// which trusts only the caller's own already-authenticated store session.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  StoreRecord _mapStore(Map<String, dynamic> row) => StoreRecord(
        id: row['id'] as String,
        storeLoginId: row['store_login_id'] as String,
        passwordHash: '', // never exposed by Supabase Auth
        displayName: row['display_name'] as String,
        activationCodeId: row['activation_code_id'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        isActive: !(row['is_disabled'] as bool),
        ownerName: (row['owner_name'] as String?) ?? '',
        phone: (row['phone'] as String?) ?? '',
      );

  BranchRecord _mapBranch(Map<String, dynamic> row) => BranchRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        address: (row['address'] as String?) ?? '',
        phone: (row['phone'] as String?) ?? '',
        isMainBranch: row['is_main_branch'] as bool? ?? false,
        isActive: row['is_active'] as bool? ?? true,
      );

  EmployeeRecord _mapEmployee(Map<String, dynamic> row) => EmployeeRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String?,
        name: row['name'] as String,
        role: StoreRole.fromName(row['role'] as String),
        pinHash: '', // never exposed — lives in employee_credentials, locked by RLS
        phone: (row['phone'] as String?) ?? '',
        address: (row['address'] as String?) ?? '',
        salaryMinorUnits: (row['salary_minor_units'] as num?)?.toInt() ?? 0,
        allowancesMinorUnits: (row['allowances_minor_units'] as num?)?.toInt() ?? 0,
        avatarColorHex: (row['avatar_color_hex'] as String?) ?? '#0F6E5C',
        isActive: row['is_active'] as bool? ?? true,
      );

  @override
  Future<StoreRecord?> getCurrentStore() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client.from('stores').select().eq('auth_user_id', userId).maybeSingle();
    if (row == null) return null;
    return _mapStore(row);
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
    final email = SupabaseConfig.syntheticEmailFor(storeLoginId);
    await _client.auth.signUp(email: email, password: password);
    // register_store reads auth.uid() from the session signUp() just
    // established — the store row, default branch, settings and chart of
    // accounts are all created atomically inside that one function.
    final row = await _client.rpc('register_store', params: {
      'p_store_login_id': storeLoginId,
      'p_display_name': displayName,
      'p_owner_name': ownerName,
      'p_phone': phone,
    }).single();
    return _mapStore(row);
  }

  @override
  Future<bool> verifyStorePassword(String storeLoginId, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: SupabaseConfig.syntheticEmailFor(storeLoginId),
        password: password,
      );
    } on AuthException {
      return false;
    }

    // Supabase Auth itself has no concept of a developer-disabled store —
    // a correct password always succeeds there. The kill switch (Developer
    // Console "deactivate") is enforced here, one level up: reject and sign
    // back out rather than leave a disabled store's session live.
    final userId = _client.auth.currentUser?.id;
    final row = userId == null ? null : await _client.from('stores').select('is_disabled').eq('auth_user_id', userId).maybeSingle();
    if (row != null && row['is_disabled'] == true) {
      await _client.auth.signOut();
      return false;
    }
    return true;
  }

  @override
  Future<BranchRecord> createBranch({
    required String storeId,
    required String name,
    String address = '',
    String phone = '',
    bool isMainBranch = false,
  }) async {
    final row = await _client.from('branches').insert({
      'store_id': storeId,
      'name': name,
      'address': address,
      'phone': phone,
      'is_main_branch': isMainBranch,
    }).select().single();
    return _mapBranch(row);
  }

  @override
  Future<List<BranchRecord>> listBranches(String storeId) async {
    final rows = await _client.from('branches').select().eq('store_id', storeId);
    return (rows as List).cast<Map<String, dynamic>>().map(_mapBranch).toList();
  }

  @override
  Future<void> updateBranch(BranchRecord branch) async {
    await _client.from('branches').update({
      'name': branch.name,
      'address': branch.address,
      'phone': branch.phone,
      'is_main_branch': branch.isMainBranch,
      'is_active': branch.isActive,
    }).eq('id', branch.id);
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
    final row = await _client.rpc('create_employee', params: {
      'p_branch_id': branchId,
      'p_name': name,
      'p_role': role,
      'p_pin': pin,
      'p_phone': phone,
      'p_address': address,
      'p_salary_minor_units': salaryMinorUnits,
      'p_allowances_minor_units': allowancesMinorUnits,
      'p_avatar_color_hex': avatarColorHex,
    }).single();
    return _mapEmployee(row);
  }

  @override
  Future<void> updateEmployee(EmployeeRecord employee, {String? newPin}) async {
    await _client.from('users').update({
      'name': employee.name,
      'role': employee.role.name,
      'branch_id': employee.branchId,
      'phone': employee.phone,
      'address': employee.address,
      'salary_minor_units': employee.salaryMinorUnits,
      'allowances_minor_units': employee.allowancesMinorUnits,
      'avatar_color_hex': employee.avatarColorHex,
      'is_active': employee.isActive,
    }).eq('id', employee.id);

    if (newPin != null) {
      await _client.rpc('update_employee_pin', params: {'p_user_id': employee.id, 'p_new_pin': newPin});
    }
  }

  @override
  Future<void> setEmployeeActive(String employeeId, bool isActive) async {
    await _client.from('users').update({'is_active': isActive}).eq('id', employeeId);
  }

  @override
  Stream<List<EmployeeRecord>> watchEmployees(String storeId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .order('name')
        .map((rows) => rows.where((r) => r['is_active'] == true).map(_mapEmployee).toList());
  }

  @override
  Future<EmployeeRecord?> findEmployeeByPin(String storeId, String pin) async {
    // storeId is accepted for interface parity with DriftAuthRepository, but
    // deliberately unused here: verify_employee_pin derives the store from
    // the caller's own authenticated session (auth.uid()), never from a
    // client-supplied id — that's what stops one store from probing another
    // store's PINs by passing an arbitrary storeId.
    final row = await _client.rpc('verify_employee_pin', params: {'p_pin': pin});
    if (row == null) return null;
    return _mapEmployee(row as Map<String, dynamic>);
  }
}
