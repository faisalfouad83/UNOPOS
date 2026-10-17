import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/magic_passcodes.dart';

/// Whether this device is a dedicated price checker, and for which store.
/// State is the id of the store the mode was turned on for (null: off).
///
/// Saved on the device so that a restart reopens the price checker, not
/// the till. It only applies while that same store is signed in: another
/// store signing in on this device works normally (and never sees the
/// first store's snapshot). Turned on from the price checker icon on the account picker, with its
/// code, and off only by entering the same code again.
class PriceCheckerModeController extends Notifier<String?> {
  static const String prefsKey = 'price_checker.mode_store';

  @override
  String? build() => null;

  /// Reads the saved mode (at start-up, before the first screen opens).
  Future<void> load() async {
    try {
      state = (await SharedPreferences.getInstance()).getString(prefsKey);
    } catch (_) {
      // No preferences: the mode simply starts off.
    }
  }

  /// Whether the mode is on for [storeId].
  bool isOnFor(String? storeId) => storeId != null && state == storeId;

  Future<void> enter(String storeId) async {
    state = storeId;
    try {
      await (await SharedPreferences.getInstance()).setString(prefsKey, storeId);
    } catch (_) {}
  }

  /// Whether [code] is the price-checker code (nothing changes).
  bool isCode(String code) => code == MagicPasscodes.priceChecker;

  /// Leaves the mode. Callers check the code first ([isCode]) and close any
  /// dialog of theirs before calling this: leaving moves the app off the
  /// price checker straight away.
  Future<void> exit() async {
    state = null;
    try {
      await (await SharedPreferences.getInstance()).remove(prefsKey);
    } catch (_) {}
  }

  /// Leaves the mode when [code] is the price-checker code; false (and the
  /// mode stays on) otherwise.
  Future<bool> tryExit(String code) async {
    if (!isCode(code)) return false;
    await exit();
    return true;
  }
}

final priceCheckerModeProvider = NotifierProvider<PriceCheckerModeController, String?>(PriceCheckerModeController.new);
