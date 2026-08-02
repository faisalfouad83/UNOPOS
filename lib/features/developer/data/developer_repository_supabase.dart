import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/security/activation_code_codec.dart';
import '../../licensing/domain/licensing_models.dart';
import '../domain/developer_models.dart';
import '../domain/developer_repository.dart';

class SupabaseDeveloperRepository implements DeveloperRepository {
  SupabaseDeveloperRepository(this._client);

  final SupabaseClient _client;

  DeveloperStoreRecord _mapStore(Map<String, dynamic> row) => DeveloperStoreRecord(
        id: row['id'] as String,
        storeLoginId: row['store_login_id'] as String,
        displayName: row['display_name'] as String,
        ownerName: (row['owner_name'] as String?) ?? '',
        phone: (row['phone'] as String?) ?? '',
        address: (row['address'] as String?) ?? '',
        currencyCode: (row['currency_code'] as String?) ?? 'IQD',
        planId: row['plan_id'] as String,
        subscriptionStatus: row['subscription_status'] as String,
        activationStatus: row['activation_status'] as String,
        licenseKey: row['license_key'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        expiresAt: row['expires_at'] == null ? null : DateTime.parse(row['expires_at'] as String),
        lastLoginAt: row['last_login_at'] == null ? null : DateTime.parse(row['last_login_at'] as String),
        isDisabled: row['is_disabled'] as bool? ?? false,
        isSuspended: row['is_suspended'] as bool? ?? false,
      );

  ActivationCodeRecord _mapActivationCode(Map<String, dynamic> row) => ActivationCodeRecord(
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
  Stream<List<DeveloperStoreRecord>> watchStores() {
    // No filter needed — RLS already grants a developer_admin full
    // visibility into every store's row.
    return _client.from('stores').stream(primaryKey: ['id']).order('created_at', ascending: false).map((rows) => rows.map(_mapStore).toList());
  }

  @override
  Future<void> updateStoreInfo({
    required String storeId,
    required String displayName,
    required String ownerName,
    required String phone,
    required String address,
    required String currencyCode,
  }) async {
    await _client.from('stores').update({
      'display_name': displayName,
      'owner_name': ownerName,
      'phone': phone,
      'address': address,
      'currency_code': currencyCode,
    }).eq('id', storeId);
  }

  @override
  Future<void> setStoreDisabled(String storeId, bool disabled) async {
    await _client.from('stores').update({'is_disabled': disabled}).eq('id', storeId);
  }

  @override
  Future<void> setStoreSuspended(String storeId, bool suspended) async {
    await _client.from('stores').update({'is_suspended': suspended}).eq('id', storeId);
  }

  @override
  Future<void> deleteStore(String storeId) async {
    // Cascades to every tenant table via ON DELETE CASCADE — irreversible,
    // the UI must confirm before calling this.
    await _client.from('stores').delete().eq('id', storeId);
  }

  @override
  Future<void> resetStorePassword(String storeId, String newPassword) async {
    await _client.rpc('developer_reset_store_password', params: {
      'p_store_id': storeId,
      'p_new_password': newPassword,
    });
  }

  @override
  Future<void> extendSubscription(String storeId, DateTime newExpiresAt) async {
    await _client.from('stores').update({
      'expires_at': newExpiresAt.toIso8601String(),
      'subscription_status': 'active',
      'activation_status': 'active',
    }).eq('id', storeId);
  }

  @override
  Future<ActivationCodeRecord> generateAndAssignLicense({
    required String storeId,
    required LicenseTier tier,
  }) async {
    final storeRow = await _client.from('stores').select('display_name').eq('id', storeId).single();
    final storeName = storeRow['display_name'] as String;

    final code = ActivationCodeCodec.generate(tier: tier, storeNameRef: storeName);
    final payload = ActivationCodeCodec.verifyAndDecode(code);

    final row = await _client.rpc('record_activation_code', params: {
      'p_code': code,
      'p_store_name_ref': storeName,
      'p_tier': tier.name,
      'p_expires_at': payload.expiresAt?.toIso8601String(),
    }).single();

    await _client.rpc('developer_assign_license', params: {'p_store_id': storeId, 'p_code': code});

    return _mapActivationCode(row);
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    List<String>? targetStoreIds,
  }) async {
    final notif = await _client.from('platform_notifications').insert({
      'title': title,
      'body': body,
      'target_scope': targetStoreIds == null ? 'all' : 'specific',
    }).select('id').single();
    final notificationId = notif['id'] as String;

    var recipientIds = targetStoreIds;
    if (recipientIds == null) {
      final allStores = await _client.from('stores').select('id');
      recipientIds = (allStores as List).map((r) => r['id'] as String).toList();
    }
    if (recipientIds.isNotEmpty) {
      await _client.from('notification_recipients').insert(
        recipientIds.map((id) => {'notification_id': notificationId, 'store_id': id}).toList(),
      );
    }
  }
}
