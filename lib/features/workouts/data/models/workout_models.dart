import '../../domain/entities/workout_entities.dart';

/// Data model for a workout assignment.
class WorkoutAssignmentModel {
  final int id;
  final WorkoutProgramModel program;
  final int progress;
  final int currentWeek;
  final bool completed;
  final WorkoutSessionSummaryModel? latestSession;

  const WorkoutAssignmentModel({
    required this.id,
    required this.program,
    required this.progress,
    required this.currentWeek,
    required this.completed,
    this.latestSession,
  });

  factory WorkoutAssignmentModel.fromJson(Map<String, dynamic> json) {
    return WorkoutAssignmentModel(
      id: json['id'] as int,
      program: WorkoutProgramModel.fromJson(
        json['program'] as Map<String, dynamic>,
      ),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      currentWeek: (json['current_week'] as num?)?.toInt() ?? 1,
      completed: json['completed'] as bool? ?? false,
      latestSession: json['latest_session'] != null
          ? WorkoutSessionSummaryModel.fromJson(
              json['latest_session'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  WorkoutAssignmentEntity toEntity() => WorkoutAssignmentEntity(
    id: id,
    program: program.toEntity(),
    progress: progress,
    currentWeek: currentWeek,
    completed: completed,
    latestSession: latestSession?.toEntity(),
  );
}

/// Data model for a workout program.
class WorkoutProgramModel {
  final int id;
  final String name;
  final String? description;
  final String difficulty;
  final int durationWeeks;
  final List<PhaseModel> phases;

  const WorkoutProgramModel({
    required this.id,
    required this.name,
    this.description,
    required this.difficulty,
    required this.durationWeeks,
    this.phases = const [],
  });

  factory WorkoutProgramModel.fromJson(Map<String, dynamic> json) {
    final phasesList = json['phases'] as List<dynamic>? ?? [];
    return WorkoutProgramModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      durationWeeks: (json['duration_weeks'] as num?)?.toInt() ?? 8,
      phases: phasesList
          .map((p) => PhaseModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  WorkoutProgramEntity toEntity() => WorkoutProgramEntity(
    id: id,
    name: name,
    description: description,
    difficulty: difficulty,
    durationWeeks: durationWeeks,
    phases: phases.map((p) => p.toEntity()).toList(),
  );
}

/// Data model for a program phase.
class PhaseModel {
  final int id;
  final String name;
  final int phaseOrder;
  final int startWeek;
  final int endWeek;
  final List<WorkoutDayModel> workoutDays;

  const PhaseModel({
    required this.id,
    required this.name,
    required this.phaseOrder,
    required this.startWeek,
    required this.endWeek,
    this.workoutDays = const [],
  });

  factory PhaseModel.fromJson(Map<String, dynamic> json) {
    final daysList = json['workout_days'] as List<dynamic>? ?? [];
    return PhaseModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phaseOrder: (json['phase_order'] as num?)?.toInt() ?? 1,
      startWeek: (json['start_week'] as num?)?.toInt() ?? 1,
      endWeek: (json['end_week'] as num?)?.toInt() ?? 1,
      workoutDays: daysList
          .map((d) => WorkoutDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  PhaseEntity toEntity() => PhaseEntity(
    id: id,
    name: name,
    phaseOrder: phaseOrder,
    startWeek: startWeek,
    endWeek: endWeek,
    workoutDays: workoutDays.map((d) => d.toEntity()).toList(),
  );
}

/// Data model for a workout day.
class WorkoutDayModel {
  final int id;
  final String name;
  final int dayNumber;
  final String focus;
  final bool isRestDay;
  final List<ExerciseDetailModel> exercises;

  const WorkoutDayModel({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.focus,
    required this.isRestDay,
    this.exercises = const [],
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    final exercisesList = json['exercises'] as List<dynamic>? ?? [];
    return WorkoutDayModel(
      id: json['id'] as int,
      name: json['name'] as String,
      dayNumber: (json['day_number'] as num?)?.toInt() ?? 1,
      focus: json['focus'] as String? ?? '',
      isRestDay: json['is_rest_day'] as bool? ?? false,
      exercises: exercisesList
          .map((e) => ExerciseDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  WorkoutDayEntity toEntity() => WorkoutDayEntity(
    id: id,
    name: name,
    dayNumber: dayNumber,
    focus: focus,
    isRestDay: isRestDay,
    exercises: exercises.map((e) => e.toEntity()).toList(),
  );
}

/// Data model for an exercise detail within a day.
class ExerciseDetailModel {
  final int id;
  final int exerciseId;
  final int sets;
  final int reps;
  final int restSeconds;
  final ExerciseModel exercise;

  const ExerciseDetailModel({
    required this.id,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.exercise,
  });

  factory ExerciseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExerciseDetailModel(
      id: json['id'] as int,
      exerciseId: (json['exercise_id'] as num?)?.toInt() ?? 0,
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: (json['reps'] as num?)?.toInt() ?? 10,
      restSeconds: (json['rest_seconds'] as num?)?.toInt() ?? 60,
      exercise: ExerciseModel.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
    );
  }

  ExerciseDetailEntity toEntity() => ExerciseDetailEntity(
    id: id,
    exerciseId: exerciseId,
    sets: sets,
    reps: reps,
    restSeconds: restSeconds,
    exercise: exercise.toEntity(),
  );
}

/// Data model for an exercise definition.
class ExerciseModel {
  final int id;
  final String name;
  final String? description;
  final String bodyPart;
  final String targetMuscle;
  final String equipment;
  final String image;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    required this.bodyPart,
    required this.targetMuscle,
    required this.equipment,
    required this.image,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      bodyPart: json['body_part'] as String? ?? '',
      targetMuscle: json['target_muscle'] as String? ?? '',
      equipment: json['equipment'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  ExerciseEntity toEntity() => ExerciseEntity(
    id: id,
    name: name,
    description: description,
    bodyPart: bodyPart,
    targetMuscle: targetMuscle,
    equipment: equipment,
    image: image,
  );
}

/// Data model for a session summary.
class WorkoutSessionSummaryModel {
  final int id;
  final String status;
  final int completionPercentage;

  const WorkoutSessionSummaryModel({
    required this.id,
    required this.status,
    required this.completionPercentage,
  });

  factory WorkoutSessionSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionSummaryModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'scheduled',
      completionPercentage:
          (json['completion_percentage'] as num?)?.toInt() ?? 0,
    );
  }

  WorkoutSessionSummaryEntity toEntity() => WorkoutSessionSummaryEntity(
    id: id,
    status: status,
    completionPercentage: completionPercentage,
  );
}

/// Data model for a full workout session.
class WorkoutSessionModel {
  final int id;
  final String status;
  final int completionPercentage;
  final int totalSets;
  final int completedSets;
  final String? startedAt;
  final String? finishedAt;
  final WorkoutDayModel? workoutDay;
  final List<ExerciseDetailModel> exercises;

  const WorkoutSessionModel({
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

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    final exercisesList = json['exercises'] as List<dynamic>? ?? [];
    return WorkoutSessionModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'in_progress',
      completionPercentage:
          (json['completion_percentage'] as num?)?.toInt() ?? 0,
      totalSets: (json['total_sets'] as num?)?.toInt() ?? 0,
      completedSets: (json['completed_sets'] as num?)?.toInt() ?? 0,
      startedAt: json['started_at'] as String?,
      finishedAt: json['finished_at'] as String?,
      workoutDay: json['workout_day'] != null
          ? WorkoutDayModel.fromJson(
              json['workout_day'] as Map<String, dynamic>,
            )
          : null,
      exercises: exercisesList
          .map((e) => ExerciseDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  WorkoutSessionEntity toEntity() => WorkoutSessionEntity(
    id: id,
    status: status,
    completionPercentage: completionPercentage,
    totalSets: totalSets,
    completedSets: completedSets,
    startedAt: startedAt,
    finishedAt: finishedAt,
    workoutDay: workoutDay?.toEntity(),
    exercises: exercises.map((e) => e.toEntity()).toList(),
  );
}

/// Data model for a workout history entry.
class WorkoutHistoryModel {
  final int id;
  final String workoutName;
  final String date;
  final int? durationMinutes;
  final int completedSets;
  final int totalSets;
  final int completionPercentage;
  final String status;

  const WorkoutHistoryModel({
    required this.id,
    required this.workoutName,
    required this.date,
    this.durationMinutes,
    required this.completedSets,
    required this.totalSets,
    required this.completionPercentage,
    required this.status,
  });

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      id: json['id'] as int,
      workoutName:
          json['workout_name'] as String? ??
          json['name'] as String? ??
          'Workout',
      date: json['date'] as String? ?? json['started_at'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      completedSets: (json['completed_sets'] as num?)?.toInt() ?? 0,
      totalSets: (json['total_sets'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (json['completion_percentage'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'completed',
    );
  }

  WorkoutHistoryEntity toEntity() {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(date);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return WorkoutHistoryEntity(
      id: id,
      workoutName: workoutName,
      date: parsedDate,
      durationMinutes: durationMinutes,
      completedSets: completedSets,
      totalSets: totalSets,
      completionPercentage: completionPercentage,
      status: status,
    );
  }
}
