import '../../../core/constants/roles.dart';

class StoreRecord {
  const StoreRecord({
    required this.id,
    required this.storeLoginId,
    required this.passwordHash,
    required this.displayName,
    this.activationCodeId,
    required this.createdAt,
    this.isActive = true,
  });

  final String id;
  final String storeLoginId;
  final String passwordHash;
  final String displayName;
  final String? activationCodeId;
  final DateTime createdAt;
  final bool isActive;
}

class BranchRecord {
  const BranchRecord({
    required this.id,
    required this.storeId,
    required this.name,
    this.address = '',
    this.phone = '',
    this.isMainBranch = false,
    this.isActive = true,
  });

  final String id;
  final String storeId;
  final String name;
  final String address;
  final String phone;
  final bool isMainBranch;
  final bool isActive;
}

class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.storeId,
    this.branchId,
    required this.name,
    required this.role,
    required this.pinHash,
    this.phone = '',
    this.address = '',
    this.salaryMinorUnits = 0,
    this.allowancesMinorUnits = 0,
    this.avatarColorHex = '#0F6E5C',
    this.isActive = true,
  });

  final String id;
  final String storeId;
  final String? branchId;
  final String name;
  final StoreRole role;
  final String pinHash;
  final String phone;
  final String address;
  final int salaryMinorUnits;
  final int allowancesMinorUnits;
  final String avatarColorHex;
  final bool isActive;
}
