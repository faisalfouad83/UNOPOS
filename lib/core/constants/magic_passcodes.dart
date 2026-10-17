/// Special passcodes handled outside the normal per-employee PIN lookup.
///
/// KNOWN LIMITATION (disclosed to client): these are static 4-digit codes
/// baked into every deployed install. That is acceptable for this local-only
/// MVP but is a real weakness once this app is sold to multiple customers —
/// any curious staff member at any site could try them. A future cloud phase
/// should replace this with per-store configurable or server-issued codes.
class MagicPasscodes {
  const MagicPasscodes._();

  /// Typed on the account-switch PIN pad from ANY employee tile (or via the
  /// hidden long-press on the very first activation screen, before any store
  /// exists yet) to reach the Developer's activation-code generator.
  static const String developerGate = '1313';

  /// Entered after holding the sign-in screen's logo: opens the support
  /// staff sign-in form. It only reveals the form — access needs the
  /// support employee's own account, checked by the server.
  static const String supportGate = '1414';

  /// How long the logo must be held before the entry-code prompt opens
  /// (an ordinary tap or short press never does).
  static const Duration gateHold = Duration(seconds: 3);

  /// Typed on the account-switch PIN pad (from any account tile, once the
  /// store is signed in) to turn this device into a dedicated price
  /// checker; typed again on the price checker's exit pad to leave it.
  static const String priceChecker = '1515';

  /// Employees may not choose a magic sequence as their personal PIN, to
  /// avoid any ambiguity with these flows.
  static bool isReserved(String pin) => pin == developerGate || pin == supportGate || pin == priceChecker;
}
