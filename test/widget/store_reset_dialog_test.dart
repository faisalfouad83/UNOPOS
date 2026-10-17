import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/features/auth/data/auth_repository_drift.dart';
import 'package:unopos/features/backup/domain/store_reset/store_reset_service.dart';
import 'package:unopos/features/settings/presentation/store_reset_dialog.dart';

class _Sink implements BackupSink {
  Uint8List? bytes;

  @override
  Future<SavedBackup?> save(String fileName, Uint8List bytes) async {
    this.bytes = bytes;
    return SavedBackup(location: 'C:\\Backups\\$fileName');
  }

  @override
  Future<Uint8List> readBack(SavedBackup saved) async => bytes!;
}

void main() {
  testWidgets('choose, confirm twice, and see each stage and the summary', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = DriftAuthRepository(db);
    late String storeId;
    late String ownerId;
    await tester.runAsync(() async {
      final store = await auth.createStore(storeLoginId: 'shop', password: 'pw123456', displayName: 'Shop');
      final branch = await auth.createBranch(storeId: store.id, name: 'Main', isMainBranch: true);
      final owner = await auth.createEmployee(storeId: store.id, name: 'Owner', role: 'owner', pin: '4821');
      storeId = store.id;
      ownerId = owner.id;
      await db.customStatement(
        "insert into shifts (id, store_id, branch_id, cashier_id, opened_at, opening_cash_float_minor_units, status) "
        "values ('sh1', ?, ?, ?, 0, 0, 'closed')",
        [store.id, branch.id, owner.id],
      );
    });
    final sink = _Sink();
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => StoreResetDialog.show(context, storeId: storeId, actorId: ownerId, sink: sink),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await tester.tap(find.text('open'));
    await settle();
    expect(find.text('What do you want to reset?'), findsOneWidget);
    // One option for invoices and sales: they are the same records.
    expect(find.text('Sales and invoices'), findsOneWidget);

    // Customers bring their debts along.
    Future<void> tapOption(String name) async {
      final option = find.byKey(ValueKey('store-reset-$name'));
      await tester.ensureVisible(option);
      await tester.pump();
      await tester.tap(option);
    }

    await tapOption('customers');
    await settle();
    expect(find.textContaining('Included:'), findsOneWidget);
    await tapOption('customers');
    await tapOption('shifts');
    await settle();
    await tester.tap(find.text('Next'));
    await settle();

    // First confirmation: what it removes.
    expect(find.text('Before you continue'), findsOneWidget);
    expect(find.text('Shifts'), findsWidgets);
    await tester.tap(find.text('Continue'));
    await settle();

    // Second confirmation names the part.
    expect(find.text('Erase Shifts?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('store-reset-confirm')));
    await settle();
    await settle();

    expect(find.text('Reset complete'), findsOneWidget);
    expect(find.byKey(const ValueKey('store-reset-stage-backup-done')), findsOneWidget);
    expect(find.byKey(const ValueKey('store-reset-stage-verify-done')), findsOneWidget);
    expect(find.byKey(const ValueKey('store-reset-stage-reset-done')), findsOneWidget);
    expect(find.textContaining('Backup saved to: C:\\Backups\\unopos_reset_backup_'), findsOneWidget);
    expect(sink.bytes, isNotNull);
    final left = await tester.runAsync(() => db.customSelect('select count(*) n from shifts').getSingle());
    expect(left!.data['n'], 0);
    expect(tester.takeException(), isNull);
  });
}
