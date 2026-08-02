import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/notification_models.dart';
import '../domain/notifications_repository.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<StoreNotificationRecord>> watchMyNotifications() {
    // .stream() can't embed a join, so each emission does one batched
    // follow-up fetch of the referenced platform_notifications rows — same
    // pattern used for journal entries / sale lines elsewhere.
    return _client.from('notification_recipients').stream(primaryKey: ['id']).asyncMap((rows) async {
      if (rows.isEmpty) return const <StoreNotificationRecord>[];

      final notificationIds = rows.map((r) => r['notification_id'] as String).toSet().toList();
      final notifRows = await _client.from('platform_notifications').select().inFilter('id', notificationIds);
      final byId = {for (final n in (notifRows as List).cast<Map<String, dynamic>>()) n['id'] as String: n};

      final result = rows
          .map((r) {
            final notif = byId[r['notification_id']];
            if (notif == null) return null;
            return StoreNotificationRecord(
              recipientId: r['id'] as String,
              notificationId: r['notification_id'] as String,
              title: notif['title'] as String,
              body: notif['body'] as String,
              createdAt: DateTime.parse(notif['created_at'] as String),
              readAt: r['read_at'] == null ? null : DateTime.parse(r['read_at'] as String),
            );
          })
          .whereType<StoreNotificationRecord>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return result;
    });
  }

  @override
  Future<void> markRead(String recipientId) async {
    await _client.from('notification_recipients').update({'read_at': DateTime.now().toIso8601String()}).eq('id', recipientId);
  }
}
