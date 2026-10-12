import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/features/auth/data/auth_repository_drift.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/auth/presentation/tile_picker_screen.dart';

void main() {
  testWidgets('a store with several branches asks for the branch, then shows its staff', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = DriftAuthRepository(db);
    late ProviderContainer container;

    await tester.runAsync(() async {
      final store = await auth.createStore(storeLoginId: 'shop', password: 'pw123456', displayName: 'Shop');
      final main = await auth.createBranch(storeId: store.id, name: 'Karrada', isMainBranch: true);
      final second = await auth.createBranch(storeId: store.id, name: 'Mansour');
      await auth.createEmployee(storeId: store.id, name: 'Sara', role: 'owner', pin: '1111');
      await auth.createEmployee(storeId: store.id, branchId: main.id, name: 'Karrada Cashier', role: 'cashier', pin: '2222');
      await auth.createEmployee(storeId: store.id, branchId: second.id, name: 'Mansour Cashier', role: 'cashier', pin: '3333');
      container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(auth)]);
      container.read(sessionControllerProvider.notifier).setStore(store);
    });
    addTearDown(() => container.dispose());

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TilePickerScreen(),
      ),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    expect(find.text('Choose a branch'), findsOneWidget);
    expect(find.text('Karrada'), findsOneWidget);
    expect(find.text('Mansour'), findsOneWidget);

    await tester.tap(find.text('Mansour'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Mansour Cashier'), findsOneWidget);
    expect(find.text('Karrada Cashier'), findsNothing);
    expect(find.text('Change branch'), findsOneWidget);
  });
}
