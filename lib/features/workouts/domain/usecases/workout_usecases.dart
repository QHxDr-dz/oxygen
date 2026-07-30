import '../entities/workout_entities.dart';
import '../repositories/workout_repository.dart';

/// Use case: Get all workout assignments.
class GetWorkoutsUseCase {
  final WorkoutRepository _repository;
  const GetWorkoutsUseCase(this._repository);

  Future<List<WorkoutAssignmentEntity>> call() => _repository.getWorkouts();
}

/// Use case: Get full workout assignment detail.
class GetWorkoutDetailUseCase {
  final WorkoutRepository _repository;
  const GetWorkoutDetailUseCase(this._repository);

  Future<WorkoutAssignmentEntity> call(int assignmentId) =>
      _repository.getWorkoutDetail(assignmentId);
}

/// Use case: Start a workout session.
class StartWorkoutUseCase {
  final WorkoutRepository _repository;
  const StartWorkoutUseCase(this._repository);

  Future<WorkoutSessionEntity> call(int assignmentId) =>
      _repository.startWorkout(assignmentId);
}

/// Use case: Get the currently active session.
class GetCurrentSessionUseCase {
  final WorkoutRepository _repository;
  const GetCurrentSessionUseCase(this._repository);

  Future<WorkoutSessionEntity?> call() => _repository.getCurrentSession();
}

/// Use case: Complete a set with performance data.
class CompleteSetUseCase {
  final WorkoutRepository _repository;
  const CompleteSetUseCase(this._repository);

  Future<void> call({
    required int sessionId,
    required int setId,
    required int reps,
    required double weight,
    int? duration,
  }) {
    return _repository.completeSet(
      sessionId: sessionId,
      setId: setId,
      reps: reps,
      weight: weight,
      duration: duration,
    );
  }
}

/// Use case: Finish the current workout session.
class FinishWorkoutUseCase {
  final WorkoutRepository _repository;
  const FinishWorkoutUseCase(this._repository);

  Future<WorkoutSessionEntity> call(int sessionId) =>
      _repository.finishWorkout(sessionId);
}

/// Use case: Get workout history.
class GetWorkoutHistoryUseCase {
  final WorkoutRepository _repository;
  const GetWorkoutHistoryUseCase(this._repository);

  Future<List<WorkoutHistoryEntity>> call() => _repository.getWorkoutHistory();
}
