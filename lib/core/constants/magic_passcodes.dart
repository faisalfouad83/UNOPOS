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

  /// Confirmation code required inside Settings to perform a full factory
  /// reset (wipes the local database and all preferences).
  static const String factoryReset = '9090';

  /// Employees may not choose either magic sequence as their personal PIN,
  /// to avoid any ambiguity with these two flows.
  static bool isReserved(String pin) => pin == developerGate || pin == factoryReset;
}
