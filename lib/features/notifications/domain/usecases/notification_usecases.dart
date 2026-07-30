import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Use case: Get all notifications.
class GetNotificationsUseCase {
  final NotificationRepository _repository;
  const GetNotificationsUseCase(this._repository);

  Future<List<NotificationEntity>> call() => _repository.getNotifications();
}

/// Use case: Get unread notification count.
class GetNotificationCountUseCase {
  final NotificationRepository _repository;
  const GetNotificationCountUseCase(this._repository);

  Future<NotificationCountEntity> call() => _repository.getNotificationCount();
}

/// Use case: Mark a notification as read.
class MarkNotificationReadUseCase {
  final NotificationRepository _repository;
  const MarkNotificationReadUseCase(this._repository);

  Future<void> call(String notificationId) =>
      _repository.markAsRead(notificationId);
}

/// Use case: Delete a notification.
class DeleteNotificationUseCase {
  final NotificationRepository _repository;
  const DeleteNotificationUseCase(this._repository);

  Future<void> call(String notificationId) =>
      _repository.deleteNotification(notificationId);
}
