import '../../../core/routing/route_paths.dart';

/// The app sections a plan can include or leave out. The keys are what the
/// Developer Console stores in `subscription_plans.features`.
class PlanModules {
  const PlanModules._();

  static const String pos = 'pos';
  static const String invoices = 'invoices';
  static const String inventory = 'inventory';
  static const String debts = 'debts';
  static const String customers = 'customers';
  static const String suppliers = 'suppliers';
  static const String accounting = 'accounting';
  static const String expenses = 'expenses';
  static const String hr = 'hr';
  static const String reports = 'reports';

  static const List<String> all = [
    pos,
    invoices,
    inventory,
    debts,
    customers,
    suppliers,
    accounting,
    expenses,
    hr,
    reports
  ];

  /// The section a screen path belongs to, or null for screens every plan
  /// has (home, settings).
  static String? forPath(String path) {
    const byPath = {
      RoutePaths.pos: pos,
      RoutePaths.invoices: invoices,
      RoutePaths.inventory: inventory,
      RoutePaths.debts: debts,
      RoutePaths.customers: customers,
      RoutePaths.suppliers: suppliers,
      RoutePaths.accounting: accounting,
      RoutePaths.expensesCash: expenses,
      RoutePaths.hr: hr,
      RoutePaths.reports: reports,
    };
    for (final e in byPath.entries) {
      if (path == e.key || path.startsWith('${e.key}/')) return e.value;
    }
    return null;
  }
}

/// What the store's plan gives it, as the server last said: the plan, its
/// limits, the sections it includes and until when. Kept on the device so
/// it holds offline.
class Entitlement {
  const Entitlement({
    required this.planId,
    required this.planName,
    this.features = const {},
    this.limits = const {},
    this.usage = const {},
    this.expiresAt,
    this.activationStatus = 'active',
    this.subscriptionStatus = 'active',
    this.isDisabled = false,
    this.isSuspended = false,
    required this.verifiedAt,
    this.fromCache = false,
  });

  final String planId;
  final String planName;

  /// Section key → included. A section not named is included.
  final Map<String, bool> features;

  /// employees / branches / products / devices / daily_transactions; null
  /// = no limit.
  final Map<String, int?> limits;

  /// How much of each limit is used.
  final Map<String, int> usage;

  /// When the code / trial ends (null = no end date).
  final DateTime? expiresAt;
  final String activationStatus;
  final String subscriptionStatus;
  final bool isDisabled;
  final bool isSuspended;

  /// When the server last confirmed this.
  final DateTime verifiedAt;

  /// Read from the copy on this device (no connection).
  final bool fromCache;

  /// Whether the plan includes [module] (see [PlanModules]).
  bool includes(String module) => features[module] ?? true;

  /// Whether the screen at [path] is in the plan.
  bool allowsPath(String path) {
    final module = PlanModules.forPath(path);
    return module == null || includes(module);
  }

  bool isExpired([DateTime? now]) => expiresAt != null && !(now ?? DateTime.now()).isBefore(expiresAt!);

  /// "active", "expired", "suspended" or "disabled" — for showing.
  String status([DateTime? now]) {
    if (isDisabled) return 'disabled';
    if (isSuspended) return 'suspended';
    if (isExpired(now)) return 'expired';
    return subscriptionStatus == 'trial' ? 'trial' : 'active';
  }

  /// Reads the server's `store_entitlement()` answer (or [toJson]).
  factory Entitlement.fromJson(Map<String, dynamic> json, {bool fromCache = false}) {
    Map<String, dynamic> map(Object? v) => v is Map ? v.cast<String, dynamic>() : const {};
    DateTime? date(Object? v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();
    int? number(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');
    return Entitlement(
      planId: (json['plan_id'] as String?) ?? '',
      planName: (json['plan_name'] as String?) ?? (json['plan_id'] as String?) ?? '',
      features: {
        for (final e in map(json['features']).entries)
          if (e.value is bool) e.key: e.value as bool,
      },
      limits: {for (final e in map(json['limits']).entries) e.key: number(e.value)},
      usage: {for (final e in map(json['usage']).entries) e.key: number(e.value) ?? 0},
      expiresAt: date(json['expires_at']),
      activationStatus: (json['activation_status'] as String?) ?? 'active',
      subscriptionStatus: (json['subscription_status'] as String?) ?? 'active',
      isDisabled: json['is_disabled'] == true,
      isSuspended: json['is_suspended'] == true,
      verifiedAt: date(json['verified_at']) ?? DateTime.now(),
      fromCache: fromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'plan_name': planName,
        'features': features,
        'limits': limits,
        'usage': usage,
        'expires_at': expiresAt?.toUtc().toIso8601String(),
        'activation_status': activationStatus,
        'subscription_status': subscriptionStatus,
        'is_disabled': isDisabled,
        'is_suspended': isSuspended,
        'verified_at': verifiedAt.toUtc().toIso8601String(),
      };
}
