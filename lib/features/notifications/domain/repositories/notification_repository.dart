import '../entities/notification_entity.dart';

/// Contract for notification data operations.
abstract class NotificationRepository {
  Future<NotificationPageEntity> getNotifications({int page, int perPage});
  Future<NotificationCountEntity> getNotificationCount();
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<List<NotificationEntity>> getCachedNotifications();
}

/// Paginated notification result entity.
class NotificationPageEntity {
  final List<NotificationEntity> notifications;
  final int currentPage;
  final int lastPage;
  final int total;

  const NotificationPageEntity({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
}
