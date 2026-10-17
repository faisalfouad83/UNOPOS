import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/features/licensing/domain/entitlement.dart';
import 'package:unopos/features/licensing/domain/license_watch.dart';
import 'package:unopos/features/licensing/presentation/plan_gate.dart';

Map<String, dynamic> _serverAnswer({Map<String, Object?> features = const {}}) => {
      'plan_id': 'starter',
      'plan_name': 'Starter',
      'features': features,
      'limits': {'employees': 5, 'branches': 1, 'products': 200, 'devices': 2, 'daily_transactions': 100},
      'usage': {'employees': 3, 'branches': 1, 'products': 40, 'devices': 1, 'daily_transactions': 12},
      'expires_at': '2027-01-01T00:00:00Z',
      'activation_status': 'active',
      'subscription_status': 'active',
      'is_disabled': false,
      'is_suspended': false,
    };

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OfflineCache.resetMemory();
  });

  group('entitlement', () {
    test('reads the server answer; sections not named are included', () {
      final e = Entitlement.fromJson(_serverAnswer(features: {'accounting': false, 'hr': true}));
      expect(e.planName, 'Starter');
      expect(e.limits['devices'], 2);
      expect(e.usage['employees'], 3);
      expect(e.includes(PlanModules.accounting), isFalse);
      expect(e.includes(PlanModules.hr), isTrue);
      expect(e.includes(PlanModules.pos), isTrue);
      expect(e.allowsPath(RoutePaths.accounting), isFalse);
      expect(e.allowsPath(RoutePaths.home), isTrue);
      expect(e.allowsPath(RoutePaths.settings), isTrue);
      expect(e.status(DateTime.utc(2026, 10, 1)), 'active');
      expect(e.status(DateTime.utc(2027, 2, 1)), 'expired');
    });

    test('screens map to sections', () {
      expect(PlanModules.forPath(RoutePaths.expensesCash), PlanModules.expenses);
      expect(PlanModules.forPath(RoutePaths.pos), PlanModules.pos);
      expect(PlanModules.forPath('/posx'), isNull);
      expect(PlanModules.forPath(RoutePaths.home), isNull);
    });

    test('a disabled or suspended store shows that status', () {
      expect(Entitlement.fromJson({..._serverAnswer(), 'is_suspended': true}).status(), 'suspended');
      expect(Entitlement.fromJson({..._serverAnswer(), 'is_disabled': true}).status(), 'disabled');
    });

    test('kept on the device and used when the server cannot be asked', () async {
      final fresh = await loadEntitlement(
        's1',
        () async => Entitlement.fromJson(_serverAnswer(features: {'reports': false})),
      );
      expect(fresh!.fromCache, isFalse);

      final offline = await loadEntitlement('s1', () async => throw const SocketException('offline'));
      expect(offline!.fromCache, isTrue);
      expect(offline.includes(PlanModules.reports), isFalse);
      expect(offline.planId, 'starter');
      expect(offline.expiresAt, fresh.expiresAt);

      // A server without plans yet (function missing) also falls back.
      final missing = await loadEntitlement('s1', () async => throw StateError('function not found'));
      expect(missing!.fromCache, isTrue);
    });

    test('nothing kept and no answer: nothing is shut', () async {
      expect(await loadEntitlement('s2', () async => throw const SocketException('offline')), isNull);
      // The local build has no plans.
      expect(await loadEntitlement('s3', () async => null), isNull);
    });
  });

  group('plan gate', () {
    Future<void> pump(WidgetTester tester, Entitlement? e, String path) async {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [entitlementProvider.overrideWith((ref) => e)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(body: PlanGate(path: path, child: const Text('SECTION'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a section left out of the plan says so', (tester) async {
      final e = Entitlement.fromJson(_serverAnswer(features: {'accounting': false}));
      await pump(tester, e, RoutePaths.accounting);
      expect(find.text('SECTION'), findsNothing);
      expect(find.text('Not in your plan'), findsOneWidget);
      expect(find.textContaining('Starter'), findsOneWidget);
    });

    testWidgets('included sections, and an unknown plan, open as usual', (tester) async {
      final e = Entitlement.fromJson(_serverAnswer(features: {'accounting': false}));
      await pump(tester, e, RoutePaths.pos);
      expect(find.text('SECTION'), findsOneWidget);
      await pump(tester, null, RoutePaths.accounting);
      expect(find.text('SECTION'), findsOneWidget);
    });
  });
}
