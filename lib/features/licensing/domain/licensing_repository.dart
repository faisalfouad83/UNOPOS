import '../../../core/security/activation_code_codec.dart';
import 'licensing_models.dart';

abstract class LicensingRepository {
  /// Generates and persists a brand-new signed activation code. Only ever
  /// called from the Developer console.
  Future<ActivationCodeRecord> generateCode({
    required LicenseTier tier,
    required String storeNameRef,
  });

  Future<List<ActivationCodeRecord>> listRecentCodes({int limit = 50});

  /// Validates the signature + looks up local redemption state. Does not
  /// mark it redeemed — call [redeemCode] once store creation succeeds.
  Future<ActivationCodeRecord> validateCode(String rawCode);

  Future<void> redeemCode(String activationCodeId, String storeId);

  /// The code currently bound to this install's store, if any (used by
  /// Settings to show days-remaining and by the app-launch expiry gate).
  Future<ActivationCodeRecord?> getActiveCodeForStore(String storeId);
}
