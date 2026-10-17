import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/entitlement.dart';
import '../domain/licensing_models.dart';
import '../domain/licensing_repository.dart';

class DriftLicensingRepository implements LicensingRepository {
  DriftLicensingRepository(this._db);

  final AppDatabase _db;

  ActivationCodeRecord _mapRow(ActivationCode row) => ActivationCodeRecord(
        id: row.id,
        code: row.code,
        storeNameRef: row.storeNameRef,
        tier: LicenseTier.values.firstWhere((t) => t.name == row.tier),
        issuedAt: row.issuedAt,
        expiresAt: row.expiresAt,
        status: ActivationCodeStatus.values.firstWhere((s) => s.name == row.status),
        redeemedByStoreId: row.redeemedByStoreId,
        redeemedAt: row.redeemedAt,
      );

  @override
  Future<ActivationCodeRecord> generateCode({
    required LicenseTier tier,
    required String storeNameRef,
  }) async {
    final code = ActivationCodeCodec.generate(tier: tier, storeNameRef: storeNameRef);
    final payload = ActivationCodeCodec.verifyAndDecode(code);
    final id = IdGenerator.newId();

    await _db.into(_db.activationCodes).insert(
          ActivationCodesCompanion.insert(
            id: id,
            code: code,
            storeNameRef: storeNameRef,
            tier: tier.name,
            issuedAt: payload.issuedAt,
            expiresAt: Value(payload.expiresAt),
          ),
        );

    return ActivationCodeRecord(
      id: id,
      code: code,
      storeNameRef: storeNameRef,
      tier: tier,
      issuedAt: payload.issuedAt,
      expiresAt: payload.expiresAt,
      status: ActivationCodeStatus.unused,
    );
  }

  @override
  Future<List<ActivationCodeRecord>> listRecentCodes({int limit = 50}) async {
    final rows = await (_db.select(_db.activationCodes)
          ..orderBy([(t) => OrderingTerm.desc(t.issuedAt)])
          ..limit(limit))
        .get();
    final stores = await _db.select(_db.stores).get();
    final names = {for (final s in stores) s.id: s.displayName};
    return [for (final r in rows) _mapRow(r).withStoreName(names[r.redeemedByStoreId])];
  }

  @override
  Future<void> revokeCode(String codeId, {bool endStoreActivation = false}) async {
    await (_db.update(_db.activationCodes)..where((t) => t.id.equals(codeId))).write(
      ActivationCodesCompanion(
        status: const Value('revoked'),
        // Ends the activation of the store using it (this install's store).
        expiresAt: endStoreActivation ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> removeCode(String codeId) async {
    final row = await (_db.select(_db.activationCodes)..where((t) => t.id.equals(codeId))).getSingleOrNull();
    if (row == null) return;
    if (row.redeemedByStoreId != null) throw StateError('this code was used by a store: revoke it instead');
    await (_db.delete(_db.activationCodes)..where((t) => t.id.equals(codeId))).go();
  }

  @override
  Future<String> codeStatus(String rawCode) async {
    final ActivationPayload payload;
    try {
      payload = ActivationCodeCodec.verifyAndDecode(rawCode);
    } on ActivationCodeException {
      return 'invalid';
    }
    if (payload.expiresAt != null && payload.expiresAt!.isBefore(DateTime.now())) return 'expired';
    final existing = await (_db.select(_db.activationCodes)..where((t) => t.code.equals(rawCode.trim().toUpperCase())))
        .getSingleOrNull();
    if (existing != null && existing.status == 'revoked') return 'revoked';
    if (existing != null && existing.status != 'unused') return 'used';
    return 'unused';
  }

  @override
  Future<ActivationCodeRecord> validateCode(String rawCode) async {
    // Throws ActivationCodeException if the signature doesn't match —
    // callers should catch this and show a localized error.
    ActivationCodeCodec.verifyAndDecode(rawCode);

    final normalized = rawCode.trim().toUpperCase();
    final existing = await (_db.select(_db.activationCodes)..where((t) => t.code.equals(normalized))).getSingleOrNull();

    if (existing != null) {
      return _mapRow(existing);
    }

    // Signature is valid but this exact code was never generated through
    // this install's local ledger (e.g. freshly issued on another device by
    // the developer and handed to this store). Register it locally so its
    // redemption state can be tracked from here on.
    final payload = ActivationCodeCodec.verifyAndDecode(rawCode);
    final id = IdGenerator.newId();
    await _db.into(_db.activationCodes).insert(
          ActivationCodesCompanion.insert(
            id: id,
            code: normalized,
            storeNameRef: payload.storeNameRef,
            tier: payload.tier.name,
            issuedAt: payload.issuedAt,
            expiresAt: Value(payload.expiresAt),
          ),
        );
    return ActivationCodeRecord(
      id: id,
      code: normalized,
      storeNameRef: payload.storeNameRef,
      tier: payload.tier,
      issuedAt: payload.issuedAt,
      expiresAt: payload.expiresAt,
      status: ActivationCodeStatus.unused,
    );
  }

  @override
  Future<void> redeemCode(String activationCodeId, String storeId) async {
    final row = await (_db.select(_db.activationCodes)..where((t) => t.id.equals(activationCodeId))).getSingleOrNull();
    if (row?.status == 'revoked') throw StateError('activation code revoked');
    await (_db.update(_db.activationCodes)..where((t) => t.id.equals(activationCodeId))).write(
      ActivationCodesCompanion(
        status: const Value('active'),
        redeemedByStoreId: Value(storeId),
        redeemedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<({bool licensed, DateTime? expiresAt})> licenseFor(String storeId) async {
    final code = await getActiveCodeForStore(storeId);
    if (code == null) return (licensed: false, expiresAt: null);
    return (licensed: !code.isExpired(), expiresAt: code.expiresAt);
  }

  @override
  Future<ActivationCodeRecord?> getActiveCodeForStore(String storeId) async {
    final row = await (_db.select(_db.activationCodes)
          ..where((t) => t.redeemedByStoreId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.redeemedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  /// The local build has no plans: every section is included.
  @override
  Future<Entitlement?> entitlementFor(String storeId) async => null;
}
