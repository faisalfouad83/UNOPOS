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

  /// Developer only (enforced by the server): the code can no longer be
  /// redeemed. A store already using it keeps its activation unless
  /// [endStoreActivation], which locks that store until a new code.
  Future<void> revokeCode(String codeId, {bool endStoreActivation = false});

  /// Developer only: removes a code that no store ever used. Refused
  /// (by the server) for a code a store used — revoke that instead.
  Future<void> removeCode(String codeId);

  /// Validates the signature + looks up local redemption state. Does not
  /// mark it redeemed — call [redeemCode] once store creation succeeds.
  Future<ActivationCodeRecord> validateCode(String rawCode);

  Future<void> redeemCode(String activationCodeId, String storeId);

  /// Checks a code before a store is created: 'unused' (good to go),
  /// 'used', 'expired' or 'invalid'. Never marks it redeemed.
  Future<String> codeStatus(String rawCode);

  /// The code currently bound to this install's store, if any (used by
  /// Settings to show days-remaining and by the app-launch expiry gate).
  Future<ActivationCodeRecord?> getActiveCodeForStore(String storeId);

  /// Whether [storeId] may use the app right now, and until when (null
  /// expiry = no end date).
  Future<({bool licensed, DateTime? expiresAt})> licenseFor(String storeId);
}
