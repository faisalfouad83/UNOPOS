import '../../../core/security/activation_code_codec.dart';
import '../../licensing/domain/licensing_models.dart';
import 'developer_models.dart';

/// Only meaningful on the shared Supabase backend — there is no concept of
/// "other stores" to manage from a single local install, so this has no
/// Drift implementation. Every method here is developer_admin-only,
/// enforced server-side by RLS regardless of what the client sends.
abstract class DeveloperRepository {
  Stream<List<DeveloperStoreRecord>> watchStores();

  Future<void> updateStoreInfo({
    required String storeId,
    required String displayName,
    required String ownerName,
    required String phone,
    required String address,
    required String currencyCode,
  });

  Future<void> setStoreDisabled(String storeId, bool disabled);

  Future<void> setStoreSuspended(String storeId, bool suspended);

  Future<void> deleteStore(String storeId);

  Future<void> resetStorePassword(String storeId, String newPassword);

  Future<void> extendSubscription(String storeId, DateTime newExpiresAt);

  Future<void> assignPlan(String storeId, String planId);

  Stream<List<SubscriptionPlanRecord>> watchPlans();

  Future<void> updatePlanLimits(SubscriptionPlanRecord plan);

  Future<ActivationCodeRecord> generateAndAssignLicense({
    required String storeId,
    required LicenseTier tier,
  });

  /// [targetStoreIds] null broadcasts to every store; otherwise only those.
  Future<void> sendNotification({
    required String title,
    required String body,
    List<String>? targetStoreIds,
  });
}
