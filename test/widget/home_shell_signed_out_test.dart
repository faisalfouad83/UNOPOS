import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/l10n/gen/app_localizations.dart';
import 'package:unopos/features/home/presentation/home_shell.dart';

void main() {
  testWidgets('the shell draws without an employee (the moment after signing out)', (tester) async {
    tester.view.physicalSize = const Size(1280, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The account strip's cloud widgets need Supabase, which isn't set up in
    // tests; only the layout itself is under test here.
    final errors = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.exceptionAsString());
    addTearDown(() => FlutterError.onError = old);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeShell(currentPath: '/home', child: Text('content'))),
      ),
    ));
    FlutterError.onError = old;
    expect(errors.where((e) => e.contains('navigation_rail') || e.contains('destinations')), isEmpty);
    expect(find.text('content'), findsOneWidget);
  });
}
