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
  Future<NotificationPageEntity> getNotifications({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final pageModel = await _remoteDataSource.getNotifications(
        page: page,
        perPage: perPage,
      );
      return NotificationPageEntity(
        notifications: pageModel.notifications
            .map((m) => m.toEntity())
            .toList(),
        currentPage: pageModel.currentPage,
        lastPage: pageModel.lastPage,
        total: pageModel.total,
      );
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
