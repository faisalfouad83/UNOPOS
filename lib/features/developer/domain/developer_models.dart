/// A store as seen by the Developer Console — deliberately a separate model
/// from auth's StoreRecord (what a store knows about its own session).
/// Every field here is something only a developer_admin is ever allowed to
/// read (enforced server-side by RLS, not just by this model existing).
class DeveloperStoreRecord {
  const DeveloperStoreRecord({
    required this.id,
    required this.storeLoginId,
    required this.displayName,
    this.ownerName = '',
    this.phone = '',
    this.address = '',
    this.currencyCode = 'IQD',
    required this.planId,
    required this.subscriptionStatus,
    required this.activationStatus,
    this.licenseKey,
    required this.createdAt,
    this.expiresAt,
    this.lastLoginAt,
    this.isDisabled = false,
    this.isSuspended = false,
  });

  final String id;
  final String storeLoginId;
  final String displayName;
  final String ownerName;
  final String phone;
  final String address;
  final String currencyCode;
  final String planId;

  /// trial/active/pastDue/cancelled
  final String subscriptionStatus;

  /// pending/active/expired/revoked
  final String activationStatus;
  final String? licenseKey;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? lastLoginAt;
  final bool isDisabled;
  final bool isSuspended;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// A developer action logged to platform_audit_logs — separate from the
/// per-store audit_logs table (features/audit), which records what
/// employees do inside their own store.
class PlatformAuditLogRecord {
  const PlatformAuditLogRecord({
    required this.id,
    this.adminId,
    required this.action,
    this.targetStoreId,
    this.detailsJson,
    required this.createdAt,
  });

  final String id;
  final String? adminId;
  final String action;
  final String? targetStoreId;
  final String? detailsJson;
  final DateTime createdAt;
}

class SubscriptionPlanRecord {
  const SubscriptionPlanRecord({
    required this.id,
    required this.name,
    required this.maxEmployees,
    required this.maxBranches,
    required this.maxProducts,
    required this.maxUsers,
    required this.maxWarehouses,
    required this.maxStorageMb,
    required this.maxDailyTransactions,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int maxEmployees;
  final int maxBranches;
  final int maxProducts;
  final int maxUsers;
  final int maxWarehouses;
  final int maxStorageMb;
  final int maxDailyTransactions;
  final bool isActive;
}

class DashboardStats {
  const DashboardStats({
    required this.totalStores,
    required this.trialStores,
    required this.activeStores,
    required this.expiredStores,
    required this.disabledStores,
  });

  final int totalStores;
  final int trialStores;
  final int activeStores;
  final int expiredStores;
  final int disabledStores;

  factory DashboardStats.fromStores(List<DeveloperStoreRecord> stores) {
    return DashboardStats(
      totalStores: stores.length,
      trialStores: stores.where((s) => s.subscriptionStatus == 'trial').length,
      activeStores: stores.where((s) => s.subscriptionStatus == 'active' && !s.isExpired).length,
      expiredStores: stores.where((s) => s.isExpired || s.activationStatus == 'expired').length,
      disabledStores: stores.where((s) => s.isDisabled).length,
    );
  }
}
