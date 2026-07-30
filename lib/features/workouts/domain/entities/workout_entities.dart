/// Domain entity for a workout assignment (program assigned to member).
class WorkoutAssignmentEntity {
  final int id;
  final WorkoutProgramEntity program;
  final int progress;
  final int currentWeek;
  final bool completed;
  final WorkoutSessionSummaryEntity? latestSession;

  const WorkoutAssignmentEntity({
    required this.id,
    required this.program,
    required this.progress,
    required this.currentWeek,
    required this.completed,
    this.latestSession,
  });
}

/// Domain entity for a workout program.
class WorkoutProgramEntity {
  final int id;
  final String name;
  final String? description;
  final String difficulty;
  final int durationWeeks;
  final List<PhaseEntity> phases;

  const WorkoutProgramEntity({
    required this.id,
    required this.name,
    this.description,
    required this.difficulty,
    required this.durationWeeks,
    this.phases = const [],
  });
}

/// Domain entity for a program phase.
class PhaseEntity {
  final int id;
  final String name;
  final int phaseOrder;
  final int startWeek;
  final int endWeek;
  final List<WorkoutDayEntity> workoutDays;

  const PhaseEntity({
    required this.id,
    required this.name,
    required this.phaseOrder,
    required this.startWeek,
    required this.endWeek,
    this.workoutDays = const [],
  });
}

/// Domain entity for a single workout day.
class WorkoutDayEntity {
  final int id;
  final String name;
  final int dayNumber;
  final String focus;
  final bool isRestDay;
  final List<ExerciseDetailEntity> exercises;

  const WorkoutDayEntity({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.focus,
    required this.isRestDay,
    this.exercises = const [],
  });
}

/// Domain entity for an exercise within a workout day.
class ExerciseDetailEntity {
  final int id;
  final int exerciseId;
  final int sets;
  final int reps;
  final int restSeconds;
  final ExerciseEntity exercise;

  const ExerciseDetailEntity({
    required this.id,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.exercise,
  });
}

/// Domain entity for an exercise definition.
class ExerciseEntity {
  final int id;
  final String name;
  final String? description;
  final String bodyPart;
  final String targetMuscle;
  final String equipment;
  final String image;

  const ExerciseEntity({
    required this.id,
    required this.name,
    this.description,
    required this.bodyPart,
    required this.targetMuscle,
    required this.equipment,
    required this.image,
  });
}

/// Summary of a workout session (used in lists).
class WorkoutSessionSummaryEntity {
  final int id;
  final String status;
  final int completionPercentage;

  const WorkoutSessionSummaryEntity({
    required this.id,
    required this.status,
    required this.completionPercentage,
  });

  bool get isScheduled => status == 'scheduled';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
}

/// Full workout session with set-level tracking.
class WorkoutSessionEntity {
  final int id;
  final String status;
  final int completionPercentage;
  final int totalSets;
  final int completedSets;
  final String? startedAt;
  final String? finishedAt;
  final WorkoutDayEntity? workoutDay;
  final List<ExerciseDetailEntity> exercises;

  const WorkoutSessionEntity({
    required this.id,
    required this.status,
    required this.completionPercentage,
    required this.totalSets,
    required this.completedSets,
    this.startedAt,
    this.finishedAt,
    this.workoutDay,
    this.exercises = const [],
  });

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
}

/// Result of completing a set.
class SetCompletionEntity {
  final int setId;
  final int reps;
  final double weight;
  final int? duration;

  const SetCompletionEntity({
    required this.setId,
    required this.reps,
    required this.weight,
    this.duration,
  });
}

/// A history entry for a completed workout session.
class WorkoutHistoryEntity {
  final int id;
  final String workoutName;
  final DateTime date;
  final int? durationMinutes;
  final int completedSets;
  final int totalSets;
  final int completionPercentage;
  final String status;

  const WorkoutHistoryEntity({
    required this.id,
    required this.workoutName,
    required this.date,
    this.durationMinutes,
    required this.completedSets,
    required this.totalSets,
    required this.completionPercentage,
    required this.status,
  });
}
