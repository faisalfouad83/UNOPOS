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
