import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/diagnostics/error_log.dart';
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

  if (kUseSupabaseBackend) {
    try {
      await initSupabase();
      ErrorLog.write('supabase ready');
    } catch (e, s) {
      ErrorLog.write('supabase init failed: $e', s);
      rethrow;
    }
  }
  runApp(const ProviderScope(child: UnoposApp()));
  WidgetsBinding.instance.addPostFrameCallback((_) => ErrorLog.write('first frame drawn'));
}
