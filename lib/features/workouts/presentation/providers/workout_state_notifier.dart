import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout_entities.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

class WorkoutState {
  final List<WorkoutAssignmentEntity> assignments;
  final bool isLoading;
  final String? error;

  const WorkoutState({
    this.assignments = const [],
    this.isLoading = false,
    this.error,
  });

  WorkoutState copyWith({
    List<WorkoutAssignmentEntity>? assignments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WorkoutState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WorkoutStateNotifier extends Notifier<WorkoutState> {
  @override
  WorkoutState build() => const WorkoutState();

  Future<void> loadWorkouts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final assignments = await ref.read(getWorkoutsUseCaseProvider).call();
      state = state.copyWith(assignments: assignments, isLoading: false);
    } catch (e) {
      AppLogger.error('WorkoutStateNotifier.loadWorkouts failed', error: e);
      try {
        final cached = await ref
            .read(workoutRepositoryProvider)
            .getCachedWorkouts();
        state = state.copyWith(assignments: cached, isLoading: false);
      } catch (_) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final workoutNotifierProvider =
    NotifierProvider<WorkoutStateNotifier, WorkoutState>(
      WorkoutStateNotifier.new,
    );
