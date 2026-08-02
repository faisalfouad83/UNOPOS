import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/supabase/supabase_config.dart';
import '../domain/notification_models.dart';

final _myNotificationsProvider = StreamProvider.autoDispose<List<StoreNotificationRecord>>((ref) {
  return ref.watch(notificationsRepositoryProvider)!.watchMyNotifications();
});

/// A bell icon with an unread-count badge, opening the notification inbox.
/// Renders nothing on the local Drift build — there's no platform sending
/// notifications to a single local install.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kUseSupabaseBackend) return const SizedBox.shrink();

    final notificationsAsync = ref.watch(_myNotificationsProvider);
    final unread = notificationsAsync.value?.where((n) => !n.isRead).length ?? 0;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => _showInbox(context, ref),
      icon: Badge(
        label: Text('$unread'),
        isLabelVisible: unread > 0,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }

  void _showInbox(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) {
          final notificationsAsync = ref.watch(_myNotificationsProvider);
          return notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications'));
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Card(
                    color: n.isRead ? null : Theme.of(context).colorScheme.primaryContainer,
                    child: ListTile(
                      title: Text(n.title),
                      subtitle: Text(n.body),
                      onTap: () {
                        if (!n.isRead) ref.read(notificationsRepositoryProvider)!.markRead(n.recipientId);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
