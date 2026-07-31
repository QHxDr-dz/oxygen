import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout_entities.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// Manages workout list state.
class WorkoutsNotifier extends AsyncNotifier<List<WorkoutAssignmentEntity>> {
  @override
  Future<List<WorkoutAssignmentEntity>> build() async {
    return _fetchWorkouts();
  }

  Future<List<WorkoutAssignmentEntity>> _fetchWorkouts() async {
    try {
      return await ref.read(getWorkoutsUseCaseProvider).call();
    } catch (e) {
      AppLogger.warning(
        'WorkoutsNotifier: remote failed, trying cache',
        error: e,
      );
      final cached = await ref
          .read(workoutRepositoryProvider)
          .getCachedWorkouts();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchWorkouts);
  }
}

final workoutsNotifierProvider =
    AsyncNotifierProvider<WorkoutsNotifier, List<WorkoutAssignmentEntity>>(
      WorkoutsNotifier.new,
    );

/// Manages a single workout assignment detail.
class WorkoutDetailNotifier extends AsyncNotifier<WorkoutAssignmentEntity> {
  WorkoutDetailNotifier(this._arg);
  final int _arg;

  @override
  Future<WorkoutAssignmentEntity> build() async {
    return ref.read(getWorkoutDetailUseCaseProvider).call(_arg);
  }

  Future<void> refresh(int assignmentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getWorkoutDetailUseCaseProvider).call(assignmentId),
    );
  }
}

final workoutDetailNotifierProvider =
    AsyncNotifierProvider.family<
      WorkoutDetailNotifier,
      WorkoutAssignmentEntity,
      int
    >((arg) => WorkoutDetailNotifier(arg));

/// Manages workout history state.
class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutHistoryEntity>> {
  @override
  Future<List<WorkoutHistoryEntity>> build() async {
    return ref.read(getWorkoutHistoryUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getWorkoutHistoryUseCaseProvider).call(),
    );
  }
}

final workoutHistoryNotifierProvider =
    AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutHistoryEntity>>(
      WorkoutHistoryNotifier.new,
    );
