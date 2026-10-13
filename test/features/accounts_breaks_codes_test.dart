import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/constants/roles.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/routing/route_guard.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/core/security/activation_code_codec.dart';
import 'package:unopos/features/auth/data/auth_repository_drift.dart';
import 'package:unopos/features/auth/domain/account_rules.dart';
import 'package:unopos/features/auth/domain/auth_models.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/breaks/data/breaks_repository_drift.dart';
import 'package:unopos/features/breaks/domain/break_models.dart';
import 'package:unopos/features/licensing/data/licensing_repository_drift.dart';
import 'package:unopos/features/settings/data/settings_repository_drift.dart';

EmployeeRecord _e(String id, StoreRole role) => EmployeeRecord(id: id, storeId: 's', name: id, role: role, pinHash: '');

void main() {
  group('who may deactivate or re-role whom', () {
    final owner = _e('o', StoreRole.owner);
    final manager = _e('m', StoreRole.manager);
    final manager2 = _e('m2', StoreRole.manager);
    final cashier = _e('c', StoreRole.cashier);

    test("the owner's account is never deactivated", () {
      expect(canDeactivate(manager, owner), AccountChangeRefusal.ownerProtected);
      expect(canDeactivate(owner, owner), AccountChangeRefusal.ownerProtected);
    });

    test('a manager only by the owner, never by themselves', () {
      expect(canDeactivate(owner, manager), isNull);
      expect(canDeactivate(manager2, manager), AccountChangeRefusal.onlyOwnerForManager);
      expect(canDeactivate(manager, manager), AccountChangeRefusal.notYourself);
      expect(canDeactivate(cashier, manager), AccountChangeRefusal.onlyOwnerForManager);
    });

    test('other staff by the owner or a manager, not by a cashier', () {
      expect(canDeactivate(manager, cashier), isNull);
      expect(canDeactivate(_e('c2', StoreRole.cashier), cashier), AccountChangeRefusal.notAllowed);
    });

    test('nobody becomes owner; making a manager needs the owner', () {
      expect(canChangeRole(owner, cashier, StoreRole.owner), AccountChangeRefusal.ownerProtected);
      expect(canChangeRole(manager, cashier, StoreRole.manager), AccountChangeRefusal.onlyOwnerForManager);
      expect(canChangeRole(owner, cashier, StoreRole.manager), isNull);
      expect(canChangeRole(manager, cashier, StoreRole.warehouseManager), isNull);
    });
  });

  group('local build enforces the same rules with the actor PIN', () {
    late AppDatabase db;
    late DriftAuthRepository auth;
    late String ownerId, managerId, cashierId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      auth = DriftAuthRepository(db);
      ownerId = (await auth.createEmployee(storeId: 's', name: 'Owner', role: 'owner', pin: '1111')).id;
      managerId = (await auth.createEmployee(storeId: 's', name: 'Mgr', role: 'manager', pin: '2222')).id;
      cashierId = (await auth.createEmployee(storeId: 's', name: 'Cash', role: 'cashier', pin: '3333')).id;
    });
    tearDown(() => db.close());

    test('a manager cannot deactivate the owner, nor with a wrong PIN', () async {
      await expectLater(
        auth.deactivateEmployee(employeeId: ownerId, actorId: managerId, actorPin: '2222'),
        throwsA(isA<AccountChangeException>().having((e) => e.refusal, 'refusal', AccountChangeRefusal.ownerProtected)),
      );
      await expectLater(
        auth.deactivateEmployee(employeeId: cashierId, actorId: managerId, actorPin: '9999'),
        throwsA(isA<AccountChangeException>().having((e) => e.wrongPin, 'wrongPin', isTrue)),
      );
      expect(await auth.watchEmployees('s').first, hasLength(3));
    });

    test('the owner deactivates a manager; history stays (soft)', () async {
      await auth.deactivateEmployee(employeeId: managerId, actorId: ownerId, actorPin: '1111');
      final active = await auth.watchEmployees('s').first;
      expect(active.map((e) => e.id), isNot(contains(managerId)));
    });
  });

  group('breaks', () {
    late AppDatabase db;
    late DateTime now;
    late DriftBreaksRepository breaks;
    late String cashierId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      now = DateTime(2026, 10, 13, 10);
      breaks = DriftBreaksRepository(db, clock: () => now);
      final settings = DriftSettingsRepository(db);
      final s = await settings.ensureSettings('s');
      await settings.updateSettings(s.copyWith(breakEnabled: true, breakMaxMinutes: 15, breakMaxPerDay: 2));
      cashierId =
          (await DriftAuthRepository(db).createEmployee(storeId: 's', name: 'C', role: 'cashier', pin: '3333')).id;
    });
    tearDown(() => db.close());

    test('only the same employee ends it, early or over time, and the daily limit holds', () async {
      final b1 = await breaks.startBreak(storeId: 's', userId: cashierId, branchId: 'b');
      await expectLater(
        breaks.startBreak(storeId: 's', userId: cashierId),
        throwsA(isA<BreakException>().having((e) => e.refusal, 'refusal', BreakRefusal.alreadyOnBreak)),
      );
      now = now.add(const Duration(minutes: 10));
      await expectLater(
        breaks.endBreak(breakId: b1.id, pin: '0000'),
        throwsA(isA<BreakException>().having((e) => e.wrongPin, 'wrongPin', isTrue)),
      );
      final ended1 = await breaks.endBreak(breakId: b1.id, pin: '3333');
      expect(ended1.endKind, BreakEndKind.early);
      expect(ended1.exceededMinutes, 0);

      final b2 = await breaks.startBreak(storeId: 's', userId: cashierId);
      now = now.add(const Duration(minutes: 20));
      final ended2 = await breaks.endBreak(breakId: b2.id, pin: '3333');
      expect(ended2.endKind, BreakEndKind.returned);
      expect(ended2.exceededMinutes, 5);

      await expectLater(
        breaks.startBreak(storeId: 's', userId: cashierId),
        throwsA(isA<BreakException>().having((e) => e.refusal, 'refusal', BreakRefusal.noneLeftToday)),
      );
      final day = DateTime(2026, 10, 13);
      expect(await breaks.breaksBetween('s', day, day.add(const Duration(days: 1))), hasLength(2));
    });

    test('a break left open when the app closed is reconciled at the next sign-in', () async {
      final b = await breaks.startBreak(storeId: 's', userId: cashierId);
      now = now.add(const Duration(minutes: 40));
      expect((await breaks.openBreakFor('s', cashierId))?.id, b.id);
      final ended = await breaks.endBreak(breakId: b.id, pin: '3333', reconciled: true);
      expect(ended.endKind, BreakEndKind.reconciled);
      expect(ended.exceededMinutes, 25);
      expect(await breaks.openBreakFor('s', cashierId), isNull);
    });

    test('while on a break every screen leads to the break lock', () {
      final session = SessionState(
          store: StoreRecord(id: 's', storeLoginId: 's', passwordHash: '', displayName: 's', createdAt: DateTime(2026)),
          employee: _e('c', StoreRole.cashier),
          currentBranchId: 'b');
      String? go(String loc, {required bool onBreak}) => RouteGuard.redirect(
            location: loc,
            hasValidLicense: true,
            hasStoreOnDisk: true,
            hasEmployees: true,
            session: session,
            onBreak: onBreak,
          );
      expect(go(RoutePaths.pos, onBreak: true), RoutePaths.breakLock);
      expect(go(RoutePaths.settings, onBreak: true), RoutePaths.breakLock);
      expect(go(RoutePaths.breakLock, onBreak: true), isNull);
      expect(go(RoutePaths.breakLock, onBreak: false), RoutePaths.home);
    });
  });

  group('activation codes', () {
    test('a revoked code is refused; an unused one can be removed, a used one cannot', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftLicensingRepository(db);
      final a = await repo.generateCode(tier: LicenseTier.months3, storeNameRef: 'A');
      final b = await repo.generateCode(tier: LicenseTier.months3, storeNameRef: 'B');

      await repo.revokeCode(a.id);
      expect(await repo.codeStatus(a.code), 'revoked');
      await expectLater(repo.redeemCode(a.id, 'store-a'), throwsA(isA<StateError>()));

      await repo.redeemCode(b.id, 'store-b');
      await expectLater(repo.removeCode(b.id), throwsA(isA<StateError>()));

      final c = await repo.generateCode(tier: LicenseTier.months3, storeNameRef: 'C');
      await repo.removeCode(c.id);
      expect((await repo.listRecentCodes()).map((x) => x.id), isNot(contains(c.id)));
    });
  });
}
