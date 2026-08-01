/// Secret embedded in the compiled app binary, used to HMAC-sign activation
/// codes so they can be validated fully offline.
///
/// DISCLOSED LIMITATION: a secret embedded in a compiled Flutter/Dart app
/// can, in principle, be extracted by a sufficiently determined attacker via
/// reverse engineering. This scheme stops casual tampering (a non-technical
/// employee guessing/incrementing codes) — it is not bulletproof against a
/// motivated attacker. True tamper-resistance requires server-side
/// validation, planned for the future Supabase/Firebase phase. Rotate this
/// value before your first real commercial release.
class AppSecrets {
  const AppSecrets._();

  static const String activationHmacKey =
      'UNOPOS-v1-8f3a2c91e6d4477e9b0a1c5d7e6f2b8a-CHANGE-BEFORE-RELEASE';
}
