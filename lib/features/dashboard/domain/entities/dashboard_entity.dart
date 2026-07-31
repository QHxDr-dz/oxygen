import '../../../authentication/domain/entities/auth_entities.dart';
import '../../../workouts/domain/entities/workout_entities.dart';
import '../../../subscription/domain/entities/subscription_entity.dart';

/// Aggregated dashboard data entity.
class DashboardEntity {
  final MemberEntity member;
  final SubscriptionEntity? subscription;
  final DashboardWorkoutEntity? workout;
  final DashboardStatisticsEntity statistics;
  final DashboardAchievementsEntity achievements;

  const DashboardEntity({
    required this.member,
    this.subscription,
    this.workout,
    required this.statistics,
    required this.achievements,
  });
}

/// Workout summary shown on the dashboard.
class DashboardWorkoutEntity {
  final WorkoutProgramEntity program;
  final int progress;
  final int currentWeek;
  final WorkoutSessionSummaryEntity? today;

  const DashboardWorkoutEntity({
    required this.program,
    required this.progress,
    required this.currentWeek,
    this.today,
  });
}

/// Statistics shown on the dashboard.
class DashboardStatisticsEntity {
  final int workoutsCompleted;
  final int totalSessions;
  final int personalRecords;

  const DashboardStatisticsEntity({
    required this.workoutsCompleted,
    required this.totalSessions,
    required this.personalRecords,
  });

  double get completionRate {
    if (totalSessions == 0) return 0;
    return (workoutsCompleted / totalSessions * 100).clamp(0, 100);
  }
}

/// Achievements summary shown on the dashboard.
class DashboardAchievementsEntity {
  final int total;
  final List<AchievementEntity> recent;

  const DashboardAchievementsEntity({
    required this.total,
    this.recent = const [],
  });
}

/// A single achievement.
class AchievementEntity {
  final int id;
  final String title;
  final String? description;
  final String? icon;
  final String? completedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.completedAt,
  });
}
