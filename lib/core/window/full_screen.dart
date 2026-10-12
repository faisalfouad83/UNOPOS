import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// Full-screen mode for desktop tills: toggled with F11 or the button in the
/// top bar, and remembered so the app reopens the way it was left.
class AppFullScreen {
  AppFullScreen._();

  static const _prefKey = 'window.fullScreen';

  /// Whether the window is full screen right now (drives the button icon).
  static final ValueNotifier<bool> isOn = ValueNotifier(false);

  static bool get supported => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Restores the last choice. Never throws — a window problem must not
  /// stop the till from opening.
  static Future<void> init() async {
    if (!supported) return;
    try {
      await windowManager.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_prefKey) ?? false) {
        await windowManager.setFullScreen(true);
        isOn.value = true;
      }
    } catch (_) {}
  }

  static Future<void> toggle() async {
    if (!supported) return;
    try {
      final next = !await windowManager.isFullScreen();
      await windowManager.setFullScreen(next);
      isOn.value = next;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, next);
    } catch (_) {}
  }
}
