import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/features/auth/data/auth_repository_drift.dart';

void main() {
  late AppDatabase db;
  late DriftAuthRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftAuthRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('employees are scoped to their own store even with matching PINs', () async {
    final storeA = await repository.createStore(
      storeLoginId: 'store-a',
      password: 'passwordA',
      displayName: 'Store A',
      activationCodeId: 'code-a',
    );
    final storeB = await repository.createStore(
      storeLoginId: 'store-b',
      password: 'passwordB',
      displayName: 'Store B',
      activationCodeId: 'code-b',
    );

    await repository.createEmployee(storeId: storeA.id, name: 'Alice', role: 'cashier', pin: '1111');
    await repository.createEmployee(storeId: storeB.id, name: 'Bob', role: 'cashier', pin: '1111');

    final employeesA = await repository.watchEmployees(storeA.id).first;
    final employeesB = await repository.watchEmployees(storeB.id).first;

    expect(employeesA.map((e) => e.name), ['Alice']);
    expect(employeesB.map((e) => e.name), ['Bob']);

    // Same PIN, different stores: looking it up under the wrong store must
    // not leak the other store's employee.
    final foundInA = await repository.findEmployeeByPin(storeA.id, '1111');
    expect(foundInA?.name, 'Alice');
    final foundInB = await repository.findEmployeeByPin(storeB.id, '1111');
    expect(foundInB?.name, 'Bob');
  });

  test('store password verification does not cross stores', () async {
    await repository.createStore(
      storeLoginId: 'store-a',
      password: 'correct-horse',
      displayName: 'Store A',
      activationCodeId: 'code-a',
    );

    expect(await repository.verifyStorePassword('store-a', 'correct-horse'), isTrue);
    expect(await repository.verifyStorePassword('store-a', 'wrong-password'), isFalse);
    expect(await repository.verifyStorePassword('nonexistent-store', 'correct-horse'), isFalse);
  });

  test('branches are scoped to their store', () async {
    final storeA = await repository.createStore(
      storeLoginId: 'store-a',
      password: 'pw',
      displayName: 'Store A',
      activationCodeId: 'code-a',
    );
    final storeB = await repository.createStore(
      storeLoginId: 'store-b',
      password: 'pw',
      displayName: 'Store B',
      activationCodeId: 'code-b',
    );

    await repository.createBranch(storeId: storeA.id, name: 'A Main', isMainBranch: true);
    await repository.createBranch(storeId: storeB.id, name: 'B Main', isMainBranch: true);
    await repository.createBranch(storeId: storeB.id, name: 'B Second');

    expect((await repository.listBranches(storeA.id)).length, 1);
    expect((await repository.listBranches(storeB.id)).length, 2);
  });
}
