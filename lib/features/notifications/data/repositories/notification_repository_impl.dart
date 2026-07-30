import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  const NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final models = await _remoteDataSource.getNotifications();
      return models.map((m) => m.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'NotificationRepository.getNotifications failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<NotificationCountEntity> getNotificationCount() async {
    try {
      final model = await _remoteDataSource.getNotificationCount();
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'NotificationRepository.getNotificationCount failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'NotificationRepository.markAsRead failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'NotificationRepository.deleteNotification failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<List<NotificationEntity>> getCachedNotifications() async {
    try {
      final models = _remoteDataSource.getCachedNotifications();
      return models?.map((m) => m.toEntity()).toList() ?? [];
    } catch (e) {
      AppLogger.warning(
        'NotificationRepository.getCachedNotifications failed',
        error: e,
      );
      return [];
    }
  }
}
