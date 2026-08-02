class StoreNotificationRecord {
  const StoreNotificationRecord({
    required this.recipientId,
    required this.notificationId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String recipientId;
  final String notificationId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;
}
