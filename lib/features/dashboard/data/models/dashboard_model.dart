import '../../domain/entities/dashboard_entity.dart';
import '../../../authentication/data/models/auth_models.dart';
import '../../../workouts/data/models/workout_models.dart';
import '../../../subscription/data/models/subscription_model.dart';

/// Data model for the dashboard API response.
class DashboardModel {
  final MemberModel member;
  final SubscriptionModel? subscription;
  final DashboardWorkoutModel? workout;
  final DashboardStatisticsModel statistics;
  final DashboardAchievementsModel achievements;

  const DashboardModel({
    required this.member,
    this.subscription,
    this.workout,
    required this.statistics,
    required this.achievements,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      member: MemberModel.fromJson(json['member'] as Map<String, dynamic>),
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(
              json['subscription'] as Map<String, dynamic>,
            )
          : null,
      workout: json['workout'] != null
          ? DashboardWorkoutModel.fromJson(
              json['workout'] as Map<String, dynamic>,
            )
          : null,
      statistics: DashboardStatisticsModel.fromJson(
        json['statistics'] as Map<String, dynamic>? ?? {},
      ),
      achievements: DashboardAchievementsModel.fromJson(
        json['achievements'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  DashboardEntity toEntity() => DashboardEntity(
    member: member.toEntity(),
    subscription: subscription?.toEntity(),
    workout: workout?.toEntity(),
    statistics: statistics.toEntity(),
    achievements: achievements.toEntity(),
  );
}

/// Dashboard workout summary model.
class DashboardWorkoutModel {
  final WorkoutProgramModel program;
  final int progress;
  final int currentWeek;
  final WorkoutSessionSummaryModel? today;

  const DashboardWorkoutModel({
    required this.program,
    required this.progress,
    required this.currentWeek,
    this.today,
  });

  factory DashboardWorkoutModel.fromJson(Map<String, dynamic> json) {
    return DashboardWorkoutModel(
      program: WorkoutProgramModel.fromJson(
        json['program'] as Map<String, dynamic>,
      ),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      currentWeek: (json['current_week'] as num?)?.toInt() ?? 1,
      today: json['today'] != null
          ? WorkoutSessionSummaryModel.fromJson(
              json['today'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  DashboardWorkoutEntity toEntity() => DashboardWorkoutEntity(
    program: program.toEntity(),
    progress: progress,
    currentWeek: currentWeek,
    today: today?.toEntity(),
  );
}

/// Dashboard statistics model.
class DashboardStatisticsModel {
  final int workoutsCompleted;
  final int totalSessions;
  final int personalRecords;

  const DashboardStatisticsModel({
    required this.workoutsCompleted,
    required this.totalSessions,
    required this.personalRecords,
  });

  factory DashboardStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatisticsModel(
      workoutsCompleted: (json['workouts_completed'] as num?)?.toInt() ?? 0,
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      personalRecords: (json['personal_records'] as num?)?.toInt() ?? 0,
    );
  }

  DashboardStatisticsEntity toEntity() => DashboardStatisticsEntity(
    workoutsCompleted: workoutsCompleted,
    totalSessions: totalSessions,
    personalRecords: personalRecords,
  );
}

/// Dashboard achievements model.
class DashboardAchievementsModel {
  final int total;
  final List<AchievementModel> recent;

  const DashboardAchievementsModel({
    required this.total,
    this.recent = const [],
  });

  factory DashboardAchievementsModel.fromJson(Map<String, dynamic> json) {
    final recentList = json['recent'] as List<dynamic>? ?? [];
    return DashboardAchievementsModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      recent: recentList
          .map((a) => AchievementModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  DashboardAchievementsEntity toEntity() => DashboardAchievementsEntity(
    total: total,
    recent: recent.map((a) => a.toEntity()).toList(),
  );
}

/// Achievement model.
class AchievementModel {
  final int id;
  final String title;
  final String? description;
  final String? icon;
  final String? completedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.completedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  AchievementEntity toEntity() => AchievementEntity(
    id: id,
    title: title,
    description: description,
    icon: icon,
    completedAt: completedAt,
  );
}
