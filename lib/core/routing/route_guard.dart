import '../../features/auth/domain/session_controller.dart';
import '../constants/roles.dart';
import '../supabase/supabase_config.dart';
import 'route_paths.dart';

/// Central RBAC + first-run/subsequent-run flow guard. Returns the path to
/// redirect to, or null if the requested location is allowed as-is.
class RouteGuard {
  const RouteGuard._();

  static const Map<String, Set<SessionRole>> _allowedRoles = {
    RoutePaths.pos: {SessionRole.owner, SessionRole.manager, SessionRole.cashier},
    RoutePaths.debts: {SessionRole.owner, SessionRole.manager, SessionRole.cashier},
    RoutePaths.inventory: {SessionRole.owner, SessionRole.manager, SessionRole.warehouseManager},
    RoutePaths.suppliers: {SessionRole.owner, SessionRole.manager},
    RoutePaths.accounting: {SessionRole.owner, SessionRole.manager},
    RoutePaths.hr: {SessionRole.owner, SessionRole.manager, SessionRole.developer},
    RoutePaths.reports: {SessionRole.owner, SessionRole.manager},
    RoutePaths.settings: {SessionRole.owner, SessionRole.manager},
  };

  static bool isRoleAllowed(String location, SessionRole? role) {
    final matchingKey = _allowedRoles.keys.firstWhere(
      (k) => location.startsWith(k),
      orElse: () => '',
    );
    if (matchingKey.isEmpty) return true; // no restriction declared
    if (role == null) return false;
    return _allowedRoles[matchingKey]!.contains(role);
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
  }) {
    final isOnboardingRoute = location == RoutePaths.activation ||
        location == RoutePaths.onboardingStore ||
        location == RoutePaths.onboardingManager;

    // The hidden developer gate (passcode 1313) must win over every other
    // check — that's the whole point of it being reachable before any
    // license/store exists yet (bootstrapping the very first activation
    // code). This has to run before the hasValidLicense check below, or
    // entering 1313 on a fresh install just bounces straight back to the
    // activation screen.
    if (session.developerMode) {
      return location == RoutePaths.developerHome ? null : RoutePaths.developerHome;
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

    if (!isRoleAllowed(location, session.role)) {
      return RoutePaths.home;
    }

    return null;
  }
}
