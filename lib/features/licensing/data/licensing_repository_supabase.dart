import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/security/activation_code_codec.dart';
import '../domain/licensing_models.dart';
import '../domain/licensing_repository.dart';

/// Supabase-backed implementation of [LicensingRepository].
///
/// The `activation_codes` table is developer-only under RLS (see the
/// migration) — a store session can never `select` from it directly. So for
/// a store, "validating" a code is purely the client-side signature check
/// ([ActivationCodeCodec.verifyAndDecode], unchanged from the local build)
/// and "redeeming" one calls the `redeem_activation_code` RPC by the raw
/// code string. Because of that, [ActivationCodeRecord.id] for a
/// store-originated record is the normalized code string itself, not a
/// database id the store was never allowed to see — [redeemCode] passes it
/// straight through as the code to redeem.
class SupabaseLicensingRepository implements LicensingRepository {
  SupabaseLicensingRepository(this._client);

  final SupabaseClient _client;

  ActivationCodeRecord _mapRow(Map<String, dynamic> row) => ActivationCodeRecord(
        id: row['id'] as String,
        code: row['code'] as String,
        storeNameRef: row['store_name_ref'] as String,
        tier: LicenseTier.values.firstWhere((t) => t.name == row['tier']),
        issuedAt: DateTime.parse(row['issued_at'] as String),
        expiresAt: row['expires_at'] == null ? null : DateTime.parse(row['expires_at'] as String),
        status: ActivationCodeStatus.values.firstWhere((s) => s.name == row['status']),
        redeemedByStoreId: row['redeemed_by_store_id'] as String?,
        redeemedAt: row['redeemed_at'] == null ? null : DateTime.parse(row['redeemed_at'] as String),
      );

  @override
  Future<ActivationCodeRecord> generateCode({
    required LicenseTier tier,
    required String storeNameRef,
  }) async {
    final code = ActivationCodeCodec.generate(tier: tier, storeNameRef: storeNameRef);
    final payload = ActivationCodeCodec.verifyAndDecode(code);

    final row = await _client.rpc('record_activation_code', params: {
      'p_code': code,
      'p_store_name_ref': storeNameRef,
      'p_tier': tier.name,
      'p_expires_at': payload.expiresAt?.toIso8601String(),
    }).single();

    return _mapRow(row);
  }

  @override
  Future<List<ActivationCodeRecord>> listRecentCodes({int limit = 50}) async {
    final rows = await _client.from('activation_codes').select().order('issued_at', ascending: false).limit(limit);
    return (rows as List).cast<Map<String, dynamic>>().map(_mapRow).toList();
  }

  @override
  Future<ActivationCodeRecord> validateCode(String rawCode) async {
    // Throws ActivationCodeException if the signature doesn't match —
    // callers should catch this and show a localized error. Deliberately no
    // DB round-trip: a store isn't allowed to read activation_codes, and
    // doesn't need to — the signature alone proves the code is genuine.
    final payload = ActivationCodeCodec.verifyAndDecode(rawCode);
    final normalized = rawCode.trim().toUpperCase();
    return ActivationCodeRecord(
      id: normalized,
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
    // storeId is accepted for interface parity but unused: the RPC derives
    // the store from the caller's own authenticated session, never from a
    // client-supplied id. activationCodeId here is the raw code string (see
    // class doc) produced by validateCode above.
    await _client.rpc('redeem_activation_code', params: {'p_code': activationCodeId});
  }

  @override
  Future<ActivationCodeRecord?> getActiveCodeForStore(String storeId) async {
    final row = await _client
        .from('stores')
        .select('activation_status, license_key, expires_at, display_name, created_at')
        .eq('id', storeId)
        .maybeSingle();
    if (row == null || row['activation_status'] != 'active') return null;

    // Tier isn't stored on `stores` (only on the now-inaccessible
    // activation_codes row) — this display-only reconstruction is used just
    // for "days remaining" in Settings, which only reads expiresAt, so the
    // tier value itself is cosmetic here.
    return ActivationCodeRecord(
      id: row['license_key'] as String? ?? storeId,
      code: row['license_key'] as String? ?? '',
      storeNameRef: row['display_name'] as String,
      tier: LicenseTier.lifetime,
      issuedAt: DateTime.parse(row['created_at'] as String),
      expiresAt: row['expires_at'] == null ? null : DateTime.parse(row['expires_at'] as String),
      status: ActivationCodeStatus.active,
      redeemedByStoreId: storeId,
    );
  }
}
