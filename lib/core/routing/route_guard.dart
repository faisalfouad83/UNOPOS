import '../../features/auth/domain/session_controller.dart';
import '../constants/permissions.dart';
import '../supabase/supabase_config.dart';
import 'route_paths.dart';

/// Central RBAC + first-run/subsequent-run flow guard. Returns the path to
/// redirect to, or null if the requested location is allowed as-is.
class RouteGuard {
  const RouteGuard._();

  /// The permission each section needs. Sections not listed (the
  /// dashboard) are open to every signed-in employee.
  static const Map<String, AppPermission> requiredPermission = {
    RoutePaths.pos: AppPermission.sell,
    RoutePaths.invoices: AppPermission.sell,
    RoutePaths.debts: AppPermission.debts,
    RoutePaths.customers: AppPermission.customers,
    RoutePaths.inventory: AppPermission.inventory,
    RoutePaths.suppliers: AppPermission.suppliers,
    RoutePaths.accounting: AppPermission.accounting,
    RoutePaths.expensesCash: AppPermission.expenses,
    RoutePaths.hr: AppPermission.hr,
    RoutePaths.reports: AppPermission.reports,
    RoutePaths.settings: AppPermission.settings,
  };

  static bool isAllowed(String location, SessionState session) {
    final matchingKey = requiredPermission.keys.firstWhere((k) => location.startsWith(k), orElse: () => '');
    if (matchingKey.isEmpty) return true; // no restriction declared
    if (session.developerMode) return matchingKey == RoutePaths.hr;
    final employee = session.employee;
    if (employee == null) return false;
    return employee.can(requiredPermission[matchingKey]!);
  }

  /// [hasStoreOnDisk] / [hasValidLicense] are resolved asynchronously before
  /// the router is even built (see AppBootstrap), so by the time redirects
  /// run they're plain booleans.
  static String? redirect({
    required String location,
    required bool hasValidLicense,
    required bool hasStoreOnDisk,
    required bool hasEmployees,
    required SessionState session,
    bool licenseExpired = false,
    bool onBreak = false,
  }) {
    final isOnboardingRoute = location == RoutePaths.activation ||
        location == RoutePaths.onboardingStore ||
        location == RoutePaths.onboardingManager;

    // A support employee only ever sees the support portal.
    if (session.supportAgent != null) {
      return location == RoutePaths.support ? null : RoutePaths.support;
    }
    if (location == RoutePaths.support) return RoutePaths.activation;

    // On a break the till is locked on the break screen until the same
    // employee returns with their PIN; nothing else opens meanwhile.
    if (onBreak && session.employee != null) {
      return location == RoutePaths.breakLock ? null : RoutePaths.breakLock;
    }
    if (location == RoutePaths.breakLock) {
      return session.employee == null ? RoutePaths.tilePicker : RoutePaths.home;
    }

    // The hidden developer gate (passcode 1313) must win over every other
    // check — that's the whole point of it being reachable before any
    // license/store exists yet (bootstrapping the very first activation
    // code). This has to run before the hasValidLicense check below, or
    // entering 1313 on a fresh install just bounces straight back to the
    // activation screen.
    if (session.developerMode) {
      return location == RoutePaths.developerHome ? null : RoutePaths.developerHome;
    }

    // A store whose activation code (or trial) has run out is locked on one
    // screen until a new code is entered — both builds.
    if (hasStoreOnDisk && (licenseExpired || (!hasValidLicense && !kUseSupabaseBackend))) {
      return location == RoutePaths.licenseExpired ? null : RoutePaths.licenseExpired;
    }
    // Unlocked (a code was just entered): move on from the lock screen.
    if (location == RoutePaths.licenseExpired) {
      return session.isAuthenticated ? RoutePaths.home : RoutePaths.tilePicker;
    }

    // The offline activation-code gate only applies to the local/Drift
    // single-tenant build. In SaaS mode a store registers freely on a trial
    // and licensing happens later (activation-code redemption or a
    // Developer Console action) — it never blocks reaching onboarding.
    if (!hasValidLicense && !kUseSupabaseBackend) {
      return location == RoutePaths.activation ? null : RoutePaths.activation;
    }

    if (!hasStoreOnDisk) {
      if (kUseSupabaseBackend) {
        // No persisted Supabase session on this device yet. That does NOT
        // mean no store exists — unlike the local build, many stores share
        // one backend, so this device might just need to log into an
        // existing one. Land on the branded welcome/login surface instead
        // of forcing straight into registration.
        if (location == RoutePaths.activation ||
            location == RoutePaths.storeLogin ||
            location == RoutePaths.onboardingStore ||
            location == RoutePaths.onboardingManager) {
          return null;
        }
        return RoutePaths.activation;
      }
      // Mid-onboarding steps are allowed to proceed; anything else bounces
      // to the start of onboarding.
      if (location == RoutePaths.onboardingStore || location == RoutePaths.onboardingManager) {
        return null;
      }
      return RoutePaths.onboardingStore;
    }

    // Store exists but its first employee (owner) was never created — e.g.
    // the app closed between "create store" and "create manager". Force
    // back to that step rather than stranding the user on a dead-end tile
    // picker with nothing to tap. Once signInEmployeeDirectly() runs at the
    // end of that step, session.isAuthenticated flips true and this stops
    // applying immediately, even before hasEmployees itself is re-checked.
    if (!hasEmployees && !session.isAuthenticated) {
      return location == RoutePaths.onboardingManager ? null : RoutePaths.onboardingManager;
    }

    // Store exists and license is valid: onboarding/activation routes are
    // done, send stragglers to the login flow.
    if (isOnboardingRoute) {
      return session.isAuthenticated ? RoutePaths.home : RoutePaths.tilePicker;
    }

    if (location == RoutePaths.storeLogin) {
      return null; // always reachable to re-auth the store if needed
    }

    if (!session.isAuthenticated) {
      if (location == RoutePaths.tilePicker || location == RoutePaths.pinPad) {
        return null;
      }
      return RoutePaths.tilePicker;
    }

    if (location == RoutePaths.tilePicker || location == RoutePaths.pinPad) {
      return RoutePaths.home;
    }

    if (!isAllowed(location, session)) {
      return RoutePaths.home;
    }

    return null;
  }
}
