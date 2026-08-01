import 'package:shared_preferences/shared_preferences.dart';

import 'licensing_models.dart';
import 'licensing_repository.dart';

/// Resolves whether this install currently has a valid license, bridging
/// the gap between "activation code entered" (before any store exists) and
/// "activation code redeemed by a store" (after onboarding finishes).
class LicenseGateService {
  LicenseGateService(this._repo);

  final LicensingRepository _repo;
  static const _prefsKey = 'unopos_pending_activation_code_id';

  Future<void> savePendingActivation(String activationCodeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, activationCodeId);
  }

  Future<String?> getPendingActivationCodeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  Future<void> clearPendingActivation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<bool> hasValidLicense({String? storeId}) async {
    ActivationCodeRecord? code;
    if (storeId != null) {
      code = await _repo.getActiveCodeForStore(storeId);
    } else {
      final pendingId = await getPendingActivationCodeId();
      if (pendingId == null) return false;
      final recent = await _repo.listRecentCodes(limit: 500);
      final matches = recent.where((c) => c.id == pendingId);
      code = matches.isEmpty ? null : matches.first;
    }
    if (code == null) return false;
    return !code.isExpired();
  }
}
