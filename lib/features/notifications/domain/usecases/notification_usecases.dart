import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// Use case: fetch paginated notifications.
class GetNotificationsUseCase {
  final NotificationRepository _repository;
  const GetNotificationsUseCase(this._repository);

  Future<NotificationPageEntity> call({int page = 1, int perPage = 15}) =>
      _repository.getNotifications(page: page, perPage: perPage);
}

/// Use case: get unread notification count.
class GetNotificationCountUseCase {
  final NotificationRepository _repository;
  const GetNotificationCountUseCase(this._repository);

  Future<NotificationCountEntity> call() => _repository.getNotificationCount();
}

/// Use case: mark a notification as read.
class MarkNotificationReadUseCase {
  final NotificationRepository _repository;
  const MarkNotificationReadUseCase(this._repository);

  Future<void> call(String notificationId) =>
      _repository.markAsRead(notificationId);
}

/// Use case: delete a notification.
class DeleteNotificationUseCase {
  final NotificationRepository _repository;
  const DeleteNotificationUseCase(this._repository);

  Future<void> call(String notificationId) =>
      _repository.deleteNotification(notificationId);
}
