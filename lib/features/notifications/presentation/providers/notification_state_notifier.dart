import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_entity.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// Flat state class for UI consumption.
class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() => const NotificationState();

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifications = await ref
          .read(getNotificationsUseCaseProvider)
          .call();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      AppLogger.error(
        'NotificationNotifier.loadNotifications failed',
        error: e,
      );
      try {
        final cached = await ref
            .read(notificationRepositoryProvider)
            .getCachedNotifications();
        state = state.copyWith(notifications: cached, isLoading: false);
      } catch (_) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> markRead(String id) async {
    try {
      await ref.read(markNotificationReadUseCaseProvider).call(id);
      final updated = state.notifications.map((n) {
        if (n.id == id) {
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
      }).toList();
      state = state.copyWith(notifications: updated);
    } catch (e) {
      AppLogger.error('NotificationNotifier.markRead failed', error: e);
    }
  }

  Future<void> markAllRead() async {
    final unread = state.notifications.where((n) => n.isUnread).toList();
    for (final n in unread) {
      await markRead(n.id);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await ref.read(deleteNotificationUseCaseProvider).call(id);
      state = state.copyWith(
        notifications: state.notifications.where((n) => n.id != id).toList(),
      );
    } catch (e) {
      AppLogger.error(
        'NotificationNotifier.deleteNotification failed',
        error: e,
      );
    }
  }
}

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
      NotificationNotifier.new,
    );
