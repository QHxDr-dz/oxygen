import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/features/authentication/domain/entities/auth_entities.dart';
import 'package:oxygenclub/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:oxygenclub/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:oxygenclub/features/notifications/data/models/notification_model.dart';
import 'package:oxygenclub/features/notifications/domain/entities/notification_entity.dart';
import 'package:oxygenclub/features/notifications/domain/repositories/notification_repository.dart';
import 'package:oxygenclub/features/notifications/presentation/providers/notification_notifier.dart';
import 'package:oxygenclub/features/notifications/presentation/providers/notification_state_notifier.dart';
import 'package:oxygenclub/features/providers.dart';
import 'package:oxygenclub/presentation/dashboard_screen/dashboard_screen.dart';

NotificationEntity _notification(String id) => NotificationEntity(
  id: id,
  title: 'Notice $id',
  message: 'Message',
  type: 'general',
  createdAt: DateTime(2026, 1, 1),
);

DashboardEntity _dashboard() => DashboardEntity(
  member: const MemberEntity(
    id: 1,
    userId: 1,
    code: 'M001',
    name: 'Test Member',
    email: 'member@example.com',
    goal: 'Get fit',
    status: 'active',
    photo: 'https://example.com/photo.jpg',
  ),
  statistics: const DashboardStatisticsEntity(
    workoutsCompleted: 0,
    totalSessions: 0,
    personalRecords: 0,
  ),
  achievements: const DashboardAchievementsEntity(total: 0),
);

class FakeDashboardNotifier extends DashboardNotifier {
  FakeDashboardNotifier(this._dashboard);
  final DashboardEntity _dashboard;

  @override
  Future<DashboardEntity> build() async => _dashboard;
}

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({
    NotificationCountEntity? count,
    this.notifications = const [],
  }) : count = count ?? const NotificationCountEntity(total: 0, unread: 0);

  final NotificationCountEntity count;
  final List<NotificationEntity> notifications;

  int countCallCount = 0;
  int markReadCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<NotificationCountEntity> getNotificationCount() async {
    countCallCount++;
    return count;
  }

  @override
  Future<NotificationPageEntity> getNotifications({
    int page = 1,
    int perPage = 15,
  }) async {
    return NotificationPageEntity(
      notifications: notifications,
      currentPage: page,
      lastPage: 1,
      total: notifications.length,
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    markReadCallCount++;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    deleteCallCount++;
  }

  @override
  Future<List<NotificationEntity>> getCachedNotifications() async =>
      notifications;
}

void main() {
  group('NotificationCountModel parsing', () {
    test('reads Laravel unread total from the count key', () {
      final model = NotificationCountModel.fromJson(const {
        'success': true,
        'count': 7,
      });
      expect(model.unread, 7);
    });

    test('still supports legacy and nested payload shapes', () {
      expect(
        NotificationCountModel.fromJson(const {'unread': 3, 'total': 9}).unread,
        3,
      );
      expect(
        NotificationCountModel.fromJson(const {
          'data': {'unread': 2},
        }).unread,
        2,
      );
    });
  });

  group('Dashboard unread badge', () {
    testWidgets('uses the count endpoint when unread exist beyond page one', (
      tester,
    ) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;

      final repository = FakeNotificationRepository(
        count: const NotificationCountEntity(total: 20, unread: 7),
        // Only one unread notification is present on the first list page.
        notifications: [_notification('n1')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(repository),
            dashboardNotifierProvider.overrideWith(
              () => FakeDashboardNotifier(_dashboard()),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(repository.countCallCount, greaterThan(0));
      expect(find.text('7'), findsOneWidget);
    });
  });

  group('Count refresh after notification mutations', () {
    test('markRead refreshes the unread count', () async {
      final repository = FakeNotificationRepository(
        count: const NotificationCountEntity(total: 5, unread: 5),
        notifications: [_notification('n1')],
      );
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(notificationNotifierProvider.notifier)
          .loadNotifications();
      await container.read(notificationCountNotifierProvider.future);
      final before = repository.countCallCount;

      await container
          .read(notificationNotifierProvider.notifier)
          .markRead('n1');
      await container.read(notificationCountNotifierProvider.future);

      expect(repository.markReadCallCount, 1);
      expect(repository.countCallCount, greaterThan(before));
    });

    test('markAllRead refreshes the count once for the whole batch', () async {
      final repository = FakeNotificationRepository(
        count: const NotificationCountEntity(total: 3, unread: 3),
        notifications: [_notification('n1'), _notification('n2')],
      );
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(notificationNotifierProvider.notifier)
          .loadNotifications();
      await container.read(notificationCountNotifierProvider.future);
      final before = repository.countCallCount;

      await container.read(notificationNotifierProvider.notifier).markAllRead();
      await container.read(notificationCountNotifierProvider.future);

      expect(repository.markReadCallCount, 2);
      expect(repository.countCallCount, before + 1);
    });

    test('deleteNotification refreshes the unread count', () async {
      final repository = FakeNotificationRepository(
        count: const NotificationCountEntity(total: 4, unread: 4),
        notifications: [_notification('n1')],
      );
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(notificationNotifierProvider.notifier)
          .loadNotifications();
      await container.read(notificationCountNotifierProvider.future);
      final before = repository.countCallCount;

      await container
          .read(notificationNotifierProvider.notifier)
          .deleteNotification('n1');
      await container.read(notificationCountNotifierProvider.future);

      expect(repository.deleteCallCount, 1);
      expect(repository.countCallCount, greaterThan(before));
    });
  });
}
