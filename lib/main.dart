import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/diagnostics/error_log.dart';
import 'core/theming/app_theme.dart';
import 'core/window/full_screen.dart';
import 'core/theming/glass_background.dart';
import 'core/theming/theme_controller.dart';
import 'core/widgets/unopos_logo.dart';
import 'core/supabase/supabase_client_provider.dart';
import 'core/supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ErrorLog.init();
  ErrorLog.write('app start');

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorLog.write('Flutter error: ${details.exceptionAsString()}', details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLog.write('Uncaught error: $error', stack);
    return true;
  };
  // In a release build a widget that fails to build is a plain grey box;
  // show what went wrong instead so it can be reported.
  ErrorWidget.builder = (details) => ColoredBox(
        color: const Color(0xFFFFF4F4),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'UNOPOS error:\n${details.exceptionAsString()}',
              style: const TextStyle(color: Color(0xFF8A1C1C), fontSize: 13),
            ),
          ),
        ),
      );

  await AppFullScreen.init();
  // The theme last in effect, so the app opens in it even offline.
  await ThemeLocalStore.preload();

  // Something on screen straight away, instead of a blank window while the
  // cloud connection starts.
  runApp(const _StartupSplash());
  WidgetsBinding.instance.addPostFrameCallback((_) => ErrorLog.write('first frame drawn'));

  if (kUseSupabaseBackend) {
    try {
      // The client is usable as soon as initialize() starts; restoring the
      // saved sign-in can wait on the network, so don't let a slow or
      // unreachable connection keep the till from opening.
      await initSupabase().timeout(const Duration(seconds: 12));
      ErrorLog.write('supabase ready');
    } on TimeoutException {
      ErrorLog.write('supabase init slow (>12s), continuing');
    } catch (e, s) {
      ErrorLog.write('supabase init failed: $e', s);
    }
  }
  runApp(const ProviderScope(child: UnoposApp()));
  ErrorLog.write('app running');
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      builder: (context, child) => GlassBackground(child: child ?? const SizedBox.shrink()),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UnoposLogo(size: 72),
              SizedBox(height: 20),
              SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
            ],
          ),
        ),
      ),
    );
  }
}
