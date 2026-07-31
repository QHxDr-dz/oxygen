import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';

/// Concrete implementation of [WorkoutRepository].
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remoteDataSource;

  const WorkoutRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<WorkoutAssignmentEntity>> getWorkouts() async {
    try {
      final models = await _remoteDataSource.getWorkouts();
      return models.map((m) => m.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.getWorkouts failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<WorkoutAssignmentEntity> getWorkoutDetail(int assignmentId) async {
    try {
      final model = await _remoteDataSource.getWorkoutDetail(assignmentId);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.getWorkoutDetail failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<WorkoutSessionEntity> startWorkout(int assignmentId) async {
    try {
      final model = await _remoteDataSource.startWorkout(assignmentId);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.startWorkout failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<WorkoutSessionEntity?> getCurrentSession() async {
    try {
      final model = await _remoteDataSource.getCurrentSession();
      return model?.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.getCurrentSession failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<WorkoutSessionEntity?> getWorkoutSession(int assignmentId) async {
    try {
      final model = await _remoteDataSource.getWorkoutSession(assignmentId);
      return model?.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.getWorkoutSession failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<WorkoutSessionEntity> completeSet({
    required int sessionId,
    required int setId,
    required int reps,
    required double weight,
    int? duration,
  }) async {
    try {
      final model = await _remoteDataSource.completeSet(
        sessionId: sessionId,
        setId: setId,
        reps: reps,
        weight: weight,
        duration: duration,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.completeSet failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<WorkoutSessionEntity> finishWorkout(int sessionId) async {
    try {
      final model = await _remoteDataSource.finishWorkout(sessionId);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.finishWorkout failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<List<WorkoutHistoryEntity>> getWorkoutHistory() async {
    try {
      final models = await _remoteDataSource.getWorkoutHistory();
      return models.map((m) => m.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'WorkoutRepository.getWorkoutHistory failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<List<WorkoutAssignmentEntity>> getCachedWorkouts() async {
    try {
      final models = _remoteDataSource.getCachedWorkouts();
      return models?.map((m) => m.toEntity()).toList() ?? [];
    } catch (e) {
      AppLogger.warning('WorkoutRepository.getCachedWorkouts failed', error: e);
      return [];
    }
  }
}
