/// Domain entity for an in-app notification.
class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? readAt;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;
  bool get isUnread => readAt == null;
}

/// Notification count summary.
class NotificationCountEntity {
  final int total;
  final int unread;

  const NotificationCountEntity({required this.total, required this.unread});
}
