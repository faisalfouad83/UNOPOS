import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/sync_service.dart';

import '../domain/notification_models.dart';
import '../domain/notifications_repository.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

  @override
  Stream<List<StoreNotificationRecord>> watchMyNotifications() {
    // .stream() can't embed a join, so each emission does one batched
    // follow-up fetch of the referenced platform_notifications rows — same
    // pattern used for journal entries / sale lines elsewhere.
    return resilientRows(
      'notification_recipients',
      () => _client.from('notification_recipients').stream(primaryKey: ['id']),
      table: 'notification_recipients',
    ).asyncMap((rows) async {
      if (rows.isEmpty) return const <StoreNotificationRecord>[];

      final notificationIds = rows.map((r) => r['notification_id'] as String).toSet().toList();
      final notifRows = await fetchRowsOrCached(
            'platform_notifications',
            () async => (await _client.from('platform_notifications').select().inFilter('id', notificationIds))
                .cast<Map<String, dynamic>>(),
          ) ??
          const [];
      final byId = {for (final n in notifRows) n['id'] as String: n};

      final result = rows
          .map((r) {
            final notif = byId[r['notification_id']];
            if (notif == null) return null;
            return StoreNotificationRecord(
              recipientId: r['id'] as String,
              notificationId: r['notification_id'] as String,
              title: notif['title'] as String,
              body: notif['body'] as String,
              createdAt: DateTime.parse(notif['created_at'] as String).toLocal(),
              readAt: r['read_at'] == null ? null : DateTime.parse(r['read_at'] as String).toLocal(),
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
    await _writer.update(
      'notification_recipients',
      {'read_at': DateTime.now().toUtc().toIso8601String()},
      value: recipientId,
    );
  }
}
