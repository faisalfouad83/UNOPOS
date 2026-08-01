import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../core/routing/app_bootstrap.dart';
import '../core/routing/app_router.dart';
import '../core/theming/app_theme.dart';

/// Language selection, independent of MaterialApp's own locale resolution —
/// UNOPOS defaults to English until a store's Settings choose otherwise, and
/// the switch is instant (no restart) since it's just a watched provider.
final appLocaleProvider = StateProvider<Locale>((ref) => const Locale('en'));

final appThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class UnoposApp extends ConsumerWidget {
  const UnoposApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    if (bootstrap.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const _SplashScreen(),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'UNOPOS',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        // Kurdish Sorani ('ckb') and Arabic both need RTL even if the
        // framework's own locale table doesn't recognize 'ckb' — builder
        // below forces Directionality explicitly rather than relying on this.
        return supported.firstWhere((l) => l.languageCode == locale?.languageCode, orElse: () => supported.first);
      },
      builder: (context, child) {
        final isRtl = locale.languageCode == 'ar' || locale.languageCode == 'ckb';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
