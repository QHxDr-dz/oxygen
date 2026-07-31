import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import './authentication/data/datasources/auth_remote_datasource.dart';
import './authentication/data/repositories/auth_repository_impl.dart';
import './authentication/domain/repositories/auth_repository.dart';
import './authentication/domain/usecases/auth_usecases.dart';
import './dashboard/data/datasources/dashboard_remote_datasource.dart';
import './dashboard/data/repositories/dashboard_repository_impl.dart';
import './dashboard/domain/repositories/dashboard_repository.dart';
import './dashboard/domain/usecases/dashboard_usecases.dart';
import './notifications/data/datasources/notification_remote_datasource.dart';
import './notifications/data/repositories/notification_repository_impl.dart';
import './notifications/domain/repositories/notification_repository.dart';
import './notifications/domain/usecases/notification_usecases.dart';
import './subscription/data/datasources/subscription_remote_datasource.dart';
import './subscription/data/repositories/subscription_repository_impl.dart';
import './subscription/domain/repositories/subscription_repository.dart';
import './subscription/domain/usecases/subscription_usecases.dart';
import './workouts/data/datasources/workout_remote_datasource.dart';
import './workouts/data/repositories/workout_repository_impl.dart';
import './workouts/domain/repositories/workout_repository.dart';
import './workouts/domain/usecases/workout_usecases.dart';
import './workouts/presentation/providers/workout_session_notifier.dart';

// ─── Authentication ──────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(dioClientProvider),
    ref.watch(secureStorageProvider),
    ref.watch(localStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  return GetMeUseCase(ref.watch(authRepositoryProvider));
});

final isAuthenticatedUseCaseProvider = Provider<IsAuthenticatedUseCase>((ref) {
  return IsAuthenticatedUseCase(ref.watch(authRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(authRepositoryProvider));
});

// ─── Dashboard ───────────────────────────────────────────────────────────────

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource(
    ref.watch(dioClientProvider),
    ref.watch(localStorageProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>((ref) {
  return GetDashboardUseCase(ref.watch(dashboardRepositoryProvider));
});

final getCachedDashboardUseCaseProvider = Provider<GetCachedDashboardUseCase>((
  ref,
) {
  return GetCachedDashboardUseCase(ref.watch(dashboardRepositoryProvider));
});

// ─── Workouts ────────────────────────────────────────────────────────────────

final workoutRemoteDataSourceProvider = Provider<WorkoutRemoteDataSource>((
  ref,
) {
  return WorkoutRemoteDataSource(
    ref.watch(dioClientProvider),
    ref.watch(localStorageProvider),
  );
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(ref.watch(workoutRemoteDataSourceProvider));
});

final getWorkoutsUseCaseProvider = Provider<GetWorkoutsUseCase>((ref) {
  return GetWorkoutsUseCase(ref.watch(workoutRepositoryProvider));
});

final getWorkoutDetailUseCaseProvider = Provider<GetWorkoutDetailUseCase>((
  ref,
) {
  return GetWorkoutDetailUseCase(ref.watch(workoutRepositoryProvider));
});

final startWorkoutUseCaseProvider = Provider<StartWorkoutUseCase>((ref) {
  return StartWorkoutUseCase(ref.watch(workoutRepositoryProvider));
});

final getCurrentSessionUseCaseProvider = Provider<GetCurrentSessionUseCase>((
  ref,
) {
  return GetCurrentSessionUseCase(ref.watch(workoutRepositoryProvider));
});

final completeSetUseCaseProvider = Provider<CompleteSetUseCase>((ref) {
  return CompleteSetUseCase(ref.watch(workoutRepositoryProvider));
});

final finishWorkoutUseCaseProvider = Provider<FinishWorkoutUseCase>((ref) {
  return FinishWorkoutUseCase(ref.watch(workoutRepositoryProvider));
});

final getWorkoutHistoryUseCaseProvider = Provider<GetWorkoutHistoryUseCase>((
  ref,
) {
  return GetWorkoutHistoryUseCase(ref.watch(workoutRepositoryProvider));
});

// ─── Workout Session ─────────────────────────────────────────────────────────

final workoutSessionProvider =
    NotifierProvider.family<WorkoutSessionNotifier, WorkoutSessionState, int?>(
      (arg) => WorkoutSessionNotifier(),
    );

// ─── Notifications ───────────────────────────────────────────────────────────

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(
        ref.watch(dioClientProvider),
        ref.watch(localStorageProvider),
      );
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final getNotificationCountUseCaseProvider =
    Provider<GetNotificationCountUseCase>((ref) {
      return GetNotificationCountUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
      return MarkNotificationReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>((
  ref,
) {
  return DeleteNotificationUseCase(ref.watch(notificationRepositoryProvider));
});

// ─── Subscription ────────────────────────────────────────────────────────────

final subscriptionRemoteDataSourceProvider =
    Provider<SubscriptionRemoteDataSource>((ref) {
      return SubscriptionRemoteDataSource(
        ref.watch(dioClientProvider),
        ref.watch(localStorageProvider),
      );
    });

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRemoteDataSourceProvider),
  );
});

final getSubscriptionUseCaseProvider = Provider<GetSubscriptionUseCase>((ref) {
  return GetSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});
