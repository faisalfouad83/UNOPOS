import '../../../core/security/activation_code_codec.dart';

enum ActivationCodeStatus { unused, active, expired, revoked }

class ActivationCodeRecord {
  const ActivationCodeRecord({
    required this.id,
    required this.code,
    required this.storeNameRef,
    required this.tier,
    required this.issuedAt,
    this.expiresAt,
    required this.status,
    this.redeemedByStoreId,
    this.redeemedAt,
    this.redeemedByStoreName,
    this.planId,
  });

  final String id;
  final String code;
  final String storeNameRef;
  final LicenseTier tier;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final ActivationCodeStatus status;
  final String? redeemedByStoreId;
  final DateTime? redeemedAt;

  /// Name of the store that activated it, when known.
  final String? redeemedByStoreName;

  /// The plan the code switches the store to (null = the store keeps its
  /// plan). Shared backend only.
  final String? planId;

  bool get isActivated => redeemedByStoreId != null || redeemedAt != null;

  ActivationCodeRecord withStoreName(String? name) => ActivationCodeRecord(
        id: id,
        code: code,
        storeNameRef: storeNameRef,
        tier: tier,
        issuedAt: issuedAt,
        expiresAt: expiresAt,
        status: status,
        redeemedByStoreId: redeemedByStoreId,
        redeemedAt: redeemedAt,
        redeemedByStoreName: name,
        planId: planId,
      );

  int? daysRemaining([DateTime? now]) {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(now ?? DateTime.now()).inHours;
    return (diff / 24).ceil();
  }

  bool isExpired([DateTime? now]) {
    if (expiresAt == null) return false;
    return !(now ?? DateTime.now()).isBefore(expiresAt!);
  }
}
