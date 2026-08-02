import 'notification_models.dart';

/// Only meaningful on the shared Supabase backend — the local build has no
/// concept of a platform sending notifications to it.
abstract class NotificationsRepository {
  Stream<List<StoreNotificationRecord>> watchMyNotifications();

  Future<void> markRead(String recipientId);
}
