import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/supabase/supabase_config.dart';
import 'package:unopos/core/constants/permissions.dart';
import 'package:unopos/core/constants/roles.dart';
import 'package:unopos/core/routing/route_guard.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/features/auth/domain/auth_models.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';

const _fakeOwner = EmployeeRecord(
  id: 'employee-1',
  storeId: 'store-1',
  name: 'Owner',
  role: StoreRole.owner,
  pinHash: '',
);

void main() {
  group('RouteGuard.redirect — developer gate', () {
    test('reaches the developer console from a totally fresh install (no license, no store)', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.developerHome,
        hasValidLicense: false,
        hasStoreOnDisk: false,
        hasEmployees: false,
        session: const SessionState(developerMode: true),
      );
      expect(redirect, isNull, reason: 'developer mode must not be bounced back to /activation');
    });

    test('navigating anywhere while in developer mode redirects to the developer console', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.activation,
        hasValidLicense: false,
        hasStoreOnDisk: false,
        hasEmployees: false,
        session: const SessionState(developerMode: true),
      );
      expect(redirect, RoutePaths.developerHome);
    });

    test('developer mode still wins even once a valid license and store exist', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: true,
        hasStoreOnDisk: true,
        hasEmployees: true,
        session: const SessionState(developerMode: true),
      );
      expect(redirect, RoutePaths.developerHome);
    });
  });

  group('RouteGuard.redirect — first-run flow', () {
    test('no valid license sends every route to /activation', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: false,
        hasStoreOnDisk: false,
        hasEmployees: false,
        session: const SessionState(),
      );
      expect(redirect, RoutePaths.activation);
    });

    test('valid license but no store sends to onboarding', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: true,
        hasStoreOnDisk: false,
        hasEmployees: false,
        session: const SessionState(),
      );
      // On the shared backend this device may just need to log into an
      // existing store, so it lands on the welcome/login screen instead.
      expect(redirect, kUseSupabaseBackend ? RoutePaths.activation : RoutePaths.onboardingStore);
    });
  });

  group('RouteGuard.redirect — incomplete onboarding (store exists, no employees yet)', () {
    test('store with zero employees is sent back to create-manager instead of the tile picker', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.tilePicker,
        hasValidLicense: true,
        hasStoreOnDisk: true,
        hasEmployees: false,
        session: const SessionState(),
      );
      expect(redirect, RoutePaths.onboardingManager);
    });

    test('create-manager itself is reachable without a redirect loop', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.onboardingManager,
        hasValidLicense: true,
        hasStoreOnDisk: true,
        hasEmployees: false,
        session: const SessionState(),
      );
      expect(redirect, isNull);
    });

    test('once an employee is signed in this session, the redirect stops applying even before hasEmployees catches up', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: true,
        hasStoreOnDisk: true,
        hasEmployees: false, // stale — not yet re-checked
        session: SessionState(employee: _fakeOwner),
      );
      expect(redirect, isNull);
    });

    test('a store with employees is unaffected — normal unauthenticated flow goes to the tile picker', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: true,
        hasStoreOnDisk: true,
        hasEmployees: true,
        session: const SessionState(),
      );
      expect(redirect, RoutePaths.tilePicker);
    });
  });

  group('RouteGuard.redirect — expired license', () {
    test('a signed-in store with an expired license is locked on the renewal screen', () {
      for (final location in [RoutePaths.home, RoutePaths.pos, RoutePaths.settings, RoutePaths.tilePicker]) {
        final redirect = RouteGuard.redirect(
          location: location,
          hasValidLicense: true,
          hasStoreOnDisk: true,
          hasEmployees: true,
          session: SessionState(employee: _fakeOwner),
          licenseExpired: true,
        );
        expect(redirect, RoutePaths.licenseExpired, reason: location);
      }
    });

    test('the renewal screen itself is reachable, and the developer gate still wins', () {
      expect(
        RouteGuard.redirect(
          location: RoutePaths.licenseExpired,
          hasValidLicense: true,
          hasStoreOnDisk: true,
          hasEmployees: true,
          session: const SessionState(),
          licenseExpired: true,
        ),
        isNull,
      );
      expect(
        RouteGuard.redirect(
          location: RoutePaths.licenseExpired,
          hasValidLicense: true,
          hasStoreOnDisk: true,
          hasEmployees: true,
          session: const SessionState(developerMode: true),
          licenseExpired: true,
        ),
        RoutePaths.developerHome,
      );
    });

    test('once renewed the app opens normally', () {
      expect(
        RouteGuard.redirect(
          location: RoutePaths.home,
          hasValidLicense: true,
          hasStoreOnDisk: true,
          hasEmployees: true,
          session: SessionState(employee: _fakeOwner),
        ),
        isNull,
      );
    });
  });

  group('RouteGuard.isAllowed — employee permissions', () {
    test('a cashier sees selling but not settings, unless granted', () {
      const cashier = EmployeeRecord(id: 'c', storeId: 's', name: 'C', role: StoreRole.cashier, pinHash: '');
      expect(RouteGuard.isAllowed(RoutePaths.pos, const SessionState(employee: cashier)), isTrue);
      expect(RouteGuard.isAllowed(RoutePaths.settings, const SessionState(employee: cashier)), isFalse);
      final granted = cashier.copyWith(customPermissions: {AppPermission.sell, AppPermission.settings});
      expect(RouteGuard.isAllowed(RoutePaths.settings, SessionState(employee: granted)), isTrue);
      expect(RouteGuard.isAllowed(RoutePaths.debts, SessionState(employee: granted)), isFalse);
    });

    test('the owner keeps everything even with a restricted list saved', () {
      final owner = _fakeOwner.copyWith(customPermissions: {AppPermission.sell});
      expect(RouteGuard.isAllowed(RoutePaths.settings, SessionState(employee: owner)), isTrue);
    });
  });
}
