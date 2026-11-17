import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout_entities.dart';
import '../../../providers.dart';

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
