import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/offline/sync_service.dart';
import '../core/supabase/supabase_config.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../core/l10n/kurdish_locale_fallback.dart';
import '../core/providers.dart';
import '../core/routing/app_bootstrap.dart';
import '../core/routing/app_router.dart';
import '../core/store_settings_provider.dart';
import '../core/theming/app_theme.dart';
import '../core/theming/glass_background.dart';
import '../core/window/full_screen.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/unopos_logo.dart';
import '../features/auth/domain/session_controller.dart';
import '../features/backup/data/store_reset_providers.dart';
import '../features/backup/domain/auto_backup_checker.dart';
import '../features/licensing/domain/license_watch.dart';
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

  /// Re-checks whether the daily automatic backup is due while the app
  /// stays open (a till is often left running all day).
  Timer? _autoBackupTimer;
  bool _autoBackupRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoBackupTimer = Timer.periodic(const Duration(minutes: 15), (_) => _runAutoBackupCheck());
  }

  @override
  void dispose() {
    _autoBackupTimer?.cancel();
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
    // A store reset left half-way, or made on another device, is finished here.
    unawaited(finishStoreResets(ref, storeId));
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
    final storeId = ref.read(sessionControllerProvider).store?.id ?? ref.read(appBootstrapProvider).value?.store?.id;
    if (storeId == null || _autoBackupRunning) return;
    _autoBackupRunning = true;
    try {
      await AutoBackupChecker(ref).checkAndRunIfDue(storeId);
    } catch (_) {
      // A failed automatic backup is logged by the backup service; never
      // let it disturb the till.
    } finally {
      _autoBackupRunning = false;
    }
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
        builder: (context, child) => GlassBackground(child: child ?? const SizedBox.shrink()),
        home: const _SplashScreen(),
      );
    }

    // Start-up failed (not just a missing connection): say so and offer to
    // try again, instead of opening screens whose checks never ran.
    if (bootstrap.hasError) {
      final isRtl = locale.languageCode == 'ar' || locale.languageCode == 'ckb';
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          KurdishFallbackMaterialLocalizationsDelegate(),
          KurdishFallbackWidgetsLocalizationsDelegate(),
          KurdishFallbackCupertinoLocalizationsDelegate(),
        ],
        builder: (context, child) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: GlassBackground(child: child ?? const SizedBox.shrink()),
        ),
        home: _StartupFailedScreen(onRetry: () => ref.invalidate(appBootstrapProvider)),
      );
    }

    final storeId = bootstrap.value?.store?.id;
    if (storeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncSettingsOnce(storeId));
    }

    ref.watch(licenseWatcherProvider);
    // Sends changes made offline as soon as there is a connection, on any
    // screen (not only where the status button is shown).
    if (kUseSupabaseBackend) ref.watch(syncServiceProvider);
    final storeSettings = ref.watch(currentStoreSettingsProvider).valueOrNull;
    if (storeSettings != null) {
      Money.currency = CurrencyInfo(storeSettings.currencyCode, storeSettings.currencySymbol);
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'UNOPOS',
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // Not GlobalMaterialLocalizations.delegate etc. directly — those
        // crash the whole app the instant Kurdish ('ckb') is selected,
        // since Flutter's own bundled translations don't cover it. See
        // kurdish_locale_fallback.dart for why.
        KurdishFallbackMaterialLocalizationsDelegate(),
        KurdishFallbackWidgetsLocalizationsDelegate(),
        KurdishFallbackCupertinoLocalizationsDelegate(),
      ],
      localeResolutionCallback: (locale, supported) {
        // Kurdish Sorani ('ckb') and Arabic both need RTL even if the
        // framework's own locale table doesn't recognize 'ckb' — builder
        // below forces Directionality explicitly rather than relying on this.
        return supported.firstWhere((l) => l.languageCode == locale?.languageCode, orElse: () => supported.first);
      },
      builder: (context, child) {
        final isRtl = locale.languageCode == 'ar' || locale.languageCode == 'ckb';
        return CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.f11): AppFullScreen.toggle},
          child: Focus(
            autofocus: true,
            child: Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: GlassBackground(child: child ?? const SizedBox.shrink()),
            ),
          ),
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
            const UnoposLogo(size: 64),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _StartupFailedScreen extends StatelessWidget {
  const _StartupFailedScreen({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const UnoposLogo(size: 64),
              const SizedBox(height: 16),
              Text(l10n.errorGeneric, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets every list scroll by dragging with any pointer — mouse, touchpad
/// (including Boot Camp trackpads that report as a mouse) or touch screen —
/// not just the wheel.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
