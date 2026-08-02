import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/routing/route_guard.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';

void main() {
  group('RouteGuard.redirect — developer gate', () {
    test('reaches the developer console from a totally fresh install (no license, no store)', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.developerHome,
        hasValidLicense: false,
        hasStoreOnDisk: false,
        session: const SessionState(developerMode: true),
      );
      expect(redirect, isNull, reason: 'developer mode must not be bounced back to /activation');
    });

    test('navigating anywhere while in developer mode redirects to the developer console', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.activation,
        hasValidLicense: false,
        hasStoreOnDisk: false,
        session: const SessionState(developerMode: true),
      );
      expect(redirect, RoutePaths.developerHome);
    });

    test('developer mode still wins even once a valid license and store exist', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: true,
        hasStoreOnDisk: true,
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
        session: const SessionState(),
      );
      expect(redirect, RoutePaths.activation);
    });

    test('valid license but no store sends to onboarding', () {
      final redirect = RouteGuard.redirect(
        location: RoutePaths.home,
        hasValidLicense: true,
        hasStoreOnDisk: false,
        session: const SessionState(),
      );
      expect(redirect, RoutePaths.onboardingStore);
    });
  });
}
