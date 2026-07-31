import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout_entities.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// State for an active workout session.
class WorkoutSessionState {
  final WorkoutSessionEntity? session;
  final bool isLoading;
  final bool isFinishing;
  final String? error;
  final Set<int> completingSetIds;

  const WorkoutSessionState({
    this.session,
    this.isLoading = false,
    this.isFinishing = false,
    this.error,
    this.completingSetIds = const {},
  });

  WorkoutSessionState copyWith({
    WorkoutSessionEntity? session,
    bool? isLoading,
    bool? isFinishing,
    String? error,
    Set<int>? completingSetIds,
    bool clearError = false,
  }) {
    return WorkoutSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      isFinishing: isFinishing ?? this.isFinishing,
      error: clearError ? null : (error ?? this.error),
      completingSetIds: completingSetIds ?? this.completingSetIds,
    );
  }
}

/// Manages a live workout session.
class WorkoutSessionNotifier extends Notifier<WorkoutSessionState> {
  @override
  WorkoutSessionState build() => const WorkoutSessionState();

  /// Start a workout from an assignment ID.
  Future<void> startWorkout(int assignmentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await ref
          .read(startWorkoutUseCaseProvider)
          .call(assignmentId);
      state = state.copyWith(session: session, isLoading: false);
      AppLogger.info(
        'WorkoutSessionNotifier: session ${session.id} started',
        tag: 'Workout',
      );
    } catch (e) {
      AppLogger.error('WorkoutSessionNotifier.startWorkout failed', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load an existing session by assignment ID.
  Future<void> loadSession(int assignmentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await ref
          .read(workoutRepositoryProvider)
          .getWorkoutSession(assignmentId);
      state = state.copyWith(session: session, isLoading: false);
    } catch (e) {
      AppLogger.error('WorkoutSessionNotifier.loadSession failed', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Complete a single set — updates UI immediately without full reload.
  Future<void> completeSet({
    required int setId,
    required int reps,
    required double weight,
    int? duration,
  }) async {
    final sessionId = state.session?.id;
    if (sessionId == null) return;

    final newCompletingIds = {...state.completingSetIds, setId};
    state = state.copyWith(completingSetIds: newCompletingIds);

    try {
      await ref
          .read(completeSetUseCaseProvider)
          .call(
            sessionId: sessionId,
            setId: setId,
            reps: reps,
            weight: weight,
            duration: duration,
          );
      AppLogger.info(
        'WorkoutSessionNotifier: set $setId completed',
        tag: 'Workout',
      );
    } catch (e) {
      AppLogger.error('WorkoutSessionNotifier.completeSet failed', error: e);
    } finally {
      final updated = <int>{...state.completingSetIds}..remove(setId);
      state = state.copyWith(completingSetIds: updated);
    }
  }

  /// Finish the workout session.
  Future<WorkoutSessionEntity?> finishWorkout() async {
    final sessionId = state.session?.id;
    if (sessionId == null) return null;

    state = state.copyWith(isFinishing: true, clearError: true);
    try {
      final finished = await ref
          .read(finishWorkoutUseCaseProvider)
          .call(sessionId);
      state = state.copyWith(session: finished, isFinishing: false);
      AppLogger.info(
        'WorkoutSessionNotifier: session $sessionId finished',
        tag: 'Workout',
      );
      return finished;
    } catch (e) {
      AppLogger.error('WorkoutSessionNotifier.finishWorkout failed', error: e);
      state = state.copyWith(isFinishing: false, error: e.toString());
      return null;
    }
  }
}

final workoutSessionNotifierProvider =
    NotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>(
      WorkoutSessionNotifier.new,
    );
