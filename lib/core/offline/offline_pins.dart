import 'package:shared_preferences/shared_preferences.dart';

import '../security/passcode_hasher.dart';

/// Lets an account sign in on this device without internet: when its PIN
/// is accepted by the server, a salted hash of it (never the PIN itself)
/// is kept here, and offline sign-in checks against that. An account that
/// never signed in on this device can't sign in offline.
class OfflinePins {
  const OfflinePins._();

  static String _key(String employeeId) => 'offline_pin.$employeeId';

  static Future<void> remember(String employeeId, String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_key(employeeId));
      if (existing != null && PasscodeHasher.verify(pin, existing)) return;
      await prefs.setString(_key(employeeId), PasscodeHasher.hash(pin));
    } catch (_) {}
  }

  static Future<bool> matches(String employeeId, String pin) async {
    try {
      final hash = (await SharedPreferences.getInstance()).getString(_key(employeeId));
      return hash != null && PasscodeHasher.verify(pin, hash);
    } catch (_) {
      return false;
    }
  }
}
