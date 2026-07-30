import '../entities/workout_entities.dart';

/// Contract for workout operations.
abstract class WorkoutRepository {
  /// Fetch all workout assignments for the current member.
  Future<List<WorkoutAssignmentEntity>> getWorkouts();

  /// Fetch full details of a specific assignment including phases and days.
  Future<WorkoutAssignmentEntity> getWorkoutDetail(int assignmentId);

  /// Start a workout session for the given assignment.
  /// Returns the created session with exercises.
  Future<WorkoutSessionEntity> startWorkout(int assignmentId);

  /// Get the currently active session (if any).
  Future<WorkoutSessionEntity?> getCurrentSession();

  /// Get the session for a specific assignment.
  Future<WorkoutSessionEntity?> getWorkoutSession(int assignmentId);

  /// Mark a set as completed with performance data.
  Future<void> completeSet({
    required int sessionId,
    required int setId,
    required int reps,
    required double weight,
    int? duration,
  });

  /// Finish the current workout session.
  Future<WorkoutSessionEntity> finishWorkout(int sessionId);

  /// Fetch workout history for the current member.
  Future<List<WorkoutHistoryEntity>> getWorkoutHistory();

  /// Return cached workouts without network call.
  Future<List<WorkoutAssignmentEntity>> getCachedWorkouts();
}
