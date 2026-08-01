import 'package:bcrypt/bcrypt.dart';

/// Hashes and verifies store passwords and employee PINs. Nothing sensitive
/// is ever persisted in plain text, even though the database is local-only
/// for now — this is the baseline every "will sell to customers later"
/// system needs from day one.
class PasscodeHasher {
  const PasscodeHasher._();

  /// Cost 10 keeps PIN verification fast enough (well under 100ms) for a
  /// quick tile-switch UX on a shared terminal, while still being far more
  /// resistant to offline brute force than a naive hash.
  static const int _cost = 10;

  static String hash(String plainText) {
    return BCrypt.hashpw(plainText, BCrypt.gensalt(logRounds: _cost));
  }

  static bool verify(String plainText, String hashed) {
    try {
      return BCrypt.checkpw(plainText, hashed);
    } catch (_) {
      // Malformed hash (e.g. corrupted row) must never crash the login flow.
      return false;
    }
  }
}
