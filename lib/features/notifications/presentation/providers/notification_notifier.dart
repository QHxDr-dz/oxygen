import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_entity.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// Manages notifications list state.
class NotificationsNotifier extends AsyncNotifier<List<NotificationEntity>> {
  @override
  Future<List<NotificationEntity>> build() async {
    return _fetchNotifications();
  }

  Future<List<NotificationEntity>> _fetchNotifications() async {
    try {
      final page = await ref.read(getNotificationsUseCaseProvider).call();
      return page.notifications;
    } catch (e) {
      AppLogger.warning(
        'NotificationsNotifier: remote failed, trying cache',
        error: e,
      );
      final cached = await ref
          .read(notificationRepositoryProvider)
          .getCachedNotifications();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchNotifications);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ref.read(markNotificationReadUseCaseProvider).call(notificationId);
      // Update local state optimistically
      state = state.whenData(
        (notifications) => notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationEntity(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              readAt: DateTime.now().toIso8601String(),
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
    } catch (e) {
      AppLogger.error('NotificationsNotifier.markAsRead failed', error: e);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await ref.read(deleteNotificationUseCaseProvider).call(notificationId);
      // Remove from local state optimistically
      state = state.whenData(
        (notifications) =>
            notifications.where((n) => n.id != notificationId).toList(),
      );
    } catch (e) {
      AppLogger.error(
        'NotificationsNotifier.deleteNotification failed',
        error: e,
      );
    }
  }
}

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationEntity>>(
      NotificationsNotifier.new,
    );

/// Manages unread notification count.
class NotificationCountNotifier extends AsyncNotifier<NotificationCountEntity> {
  @override
  Future<NotificationCountEntity> build() async {
    return ref.read(getNotificationCountUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getNotificationCountUseCaseProvider).call(),
    );
  }
}

final notificationCountNotifierProvider =
    AsyncNotifierProvider<NotificationCountNotifier, NotificationCountEntity>(
      NotificationCountNotifier.new,
    );
