import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_entity.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// Flat state class for paginated notifications UI.
class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int lastPage;
  final bool hasReachedEnd;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.lastPage = 1,
    this.hasReachedEnd = false,
  });

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? lastPage,
    bool? hasReachedEnd,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

/// Manages paginated notifications with infinite scroll.
class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() => const NotificationState();

  /// Load first page (refresh).
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await ref
          .read(getNotificationsUseCaseProvider)
          .call(page: 1);
      state = state.copyWith(
        notifications: page.notifications,
        isLoading: false,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        hasReachedEnd: !page.hasNextPage,
      );
    } catch (e) {
      AppLogger.error(
        'NotificationNotifier.loadNotifications failed',
        error: e,
      );
      // Try cache on failure
      try {
        final cached = await ref
            .read(notificationRepositoryProvider)
            .getCachedNotifications();
        state = state.copyWith(
          notifications: cached,
          isLoading: false,
          hasReachedEnd: true,
        );
      } catch (_) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Load next page for infinite scroll.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final page = await ref
          .read(getNotificationsUseCaseProvider)
          .call(page: nextPage);
      state = state.copyWith(
        notifications: [...state.notifications, ...page.notifications],
        isLoadingMore: false,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        hasReachedEnd: !page.hasNextPage,
      );
    } catch (e) {
      AppLogger.error('NotificationNotifier.loadMore failed', error: e);
      state = state.copyWith(isLoadingMore: false);
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
