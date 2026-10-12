import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/app/app.dart';
import 'package:unopos/core/database/app_database.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/core/providers.dart';
import 'package:unopos/features/auth/data/auth_repository_drift.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/backup/data/backup_repository_drift.dart';
import 'package:unopos/features/backup/domain/backup_service.dart';
import 'package:unopos/features/licensing/data/licensing_repository_drift.dart';
import 'package:unopos/features/settings/data/settings_repository_drift.dart';
import 'package:unopos/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('the settings screen lays out cleanly and scrolls to its last section', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = DriftAuthRepository(db);
    final settings = DriftSettingsRepository(db);
    final backups = DriftBackupRepository(db);
    late ProviderContainer container;

    await tester.runAsync(() async {
      final store = await auth.createStore(storeLoginId: 'shop', password: 'pw123456', displayName: 'Shop');
      await auth.createBranch(storeId: store.id, name: 'Main', isMainBranch: true);
      await settings.ensureSettings(store.id);
      container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(auth),
        settingsRepositoryProvider.overrideWithValue(settings),
        licensingRepositoryProvider.overrideWithValue(DriftLicensingRepository(db)),
        backupRepositoryProvider.overrideWithValue(backups),
        backupServiceProvider.overrideWithValue(BackupService(backups)),
      ]);
      container.read(sessionControllerProvider.notifier).setStore(store);
    });
    addTearDown(() => container.dispose());

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        scrollBehavior: AppScrollBehavior(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ));
    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await settle();
    expect(tester.takeException(), isNull);

    // Drag the page up with the mouse, the way a touchpad on Windows does.
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 12; i++) {
      await tester.drag(list, const Offset(0, -400), kind: PointerDeviceKind.mouse);
      await settle();
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Factory Reset'), findsWidgets);
  });
}
