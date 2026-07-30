import '../entities/notification_entity.dart';

/// Contract for notification operations.
abstract class NotificationRepository {
  /// Fetch all notifications for the current member.
  Future<List<NotificationEntity>> getNotifications();

  /// Fetch unread notification count.
  Future<NotificationCountEntity> getNotificationCount();

  /// Mark a notification as read.
  Future<void> markAsRead(String notificationId);

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId);

  /// Return cached notifications without network call.
  Future<List<NotificationEntity>> getCachedNotifications();
}
