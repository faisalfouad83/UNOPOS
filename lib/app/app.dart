import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../core/providers.dart';
import '../core/routing/app_bootstrap.dart';
import '../core/routing/app_router.dart';
import '../core/theming/app_theme.dart';
import '../features/backup/domain/auto_backup_checker.dart';
import '../features/settings/domain/settings_models.dart';

/// Language selection, independent of MaterialApp's own locale resolution —
/// UNOPOS defaults to English until a store's Settings choose otherwise, and
/// the switch is instant (no restart) since it's just a watched provider.
final appLocaleProvider = StateProvider<Locale>((ref) => const Locale('en'));

final appThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class UnoposApp extends ConsumerStatefulWidget {
  const UnoposApp({super.key});

  @override
  ConsumerState<UnoposApp> createState() => _UnoposAppState();
}

class _UnoposAppState extends ConsumerState<UnoposApp> with WidgetsBindingObserver {
  bool _settingsSynced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runAutoBackupCheck();
    }
  }

  Future<void> _syncSettingsOnce(String storeId) async {
    if (_settingsSynced) return;
    _settingsSynced = true;
    final settings = await ref.read(settingsRepositoryProvider).ensureSettings(storeId);
    if (!mounted) return;
    ref.read(appLocaleProvider.notifier).state = Locale(settings.defaultLanguage);
    ref.read(appThemeModeProvider.notifier).state = switch (settings.themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
    await _runAutoBackupCheck();
  }

  Future<void> _runAutoBackupCheck() async {
    final storeId = ref.read(appBootstrapProvider).value?.store?.id;
    if (storeId == null) return;
    await AutoBackupChecker(ref).checkAndRunIfDue(storeId);
  }

  @override
  Widget build(BuildContext context) {
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

    final storeId = bootstrap.value?.store?.id;
    if (storeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncSettingsOnce(storeId));
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
