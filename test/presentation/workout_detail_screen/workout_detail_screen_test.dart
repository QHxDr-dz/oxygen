import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/features/providers.dart';
import 'package:oxygenclub/features/workouts/domain/entities/workout_entities.dart';
import 'package:oxygenclub/features/workouts/domain/repositories/workout_repository.dart';
import 'package:oxygenclub/presentation/workout_detail_screen/workout_detail_screen.dart';

WorkoutAssignmentEntity _assignment(int id) => WorkoutAssignmentEntity(
  id: id,
  program: WorkoutProgramEntity(
    id: 10,
    name: 'Deep Link Program',
    difficulty: 'beginner',
    durationWeeks: 4,
  ),
  progress: 0,
  currentWeek: 1,
  completed: false,
);

class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({
    this.detailResult,
    this.detailError,
    this.workouts = const [],
    this.cachedWorkouts = const [],
  });

  final WorkoutAssignmentEntity? detailResult;
  final Object? detailError;
  final List<WorkoutAssignmentEntity> workouts;
  final List<WorkoutAssignmentEntity> cachedWorkouts;

  int detailCallCount = 0;
  int workoutsCallCount = 0;
  int? lastDetailId;

  @override
  Future<WorkoutAssignmentEntity> getWorkoutDetail(int assignmentId) async {
    detailCallCount++;
    lastDetailId = assignmentId;
    if (detailError != null) throw detailError!;
    return detailResult!;
  }

  @override
  Future<List<WorkoutAssignmentEntity>> getWorkouts() async {
    workoutsCallCount++;
    return workouts;
  }

  @override
  Future<List<WorkoutAssignmentEntity>> getCachedWorkouts() async =>
      cachedWorkouts;

  @override
  Future<WorkoutSessionEntity> startWorkout(int assignmentId) =>
      throw UnimplementedError();

  @override
  Future<WorkoutSessionEntity?> getCurrentSession() =>
      throw UnimplementedError();

  @override
  Future<WorkoutSessionEntity?> getWorkoutSession(int assignmentId) =>
      throw UnimplementedError();

  @override
  Future<WorkoutSessionEntity> completeSet({
    required int sessionId,
    required int setId,
    required int reps,
    required double weight,
    int? duration,
  }) => throw UnimplementedError();

  @override
  Future<WorkoutSessionEntity> finishWorkout(int sessionId) =>
      throw UnimplementedError();

  @override
  Future<List<WorkoutHistoryEntity>> getWorkoutHistory() =>
      throw UnimplementedError();
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required FakeWorkoutRepository repository,
  required int assignmentId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [workoutRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: WorkoutDetailScreen(assignmentId: assignmentId)),
    ),
  );
  // Allow the post-frame callback plus the async detail/list futures to resolve.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('WorkoutDetailScreen deep-link fallback', () {
    testWidgets('detail fails, cache initially empty, list fetch supplies the '
        'assignment', (tester) async {
      final target = _assignment(42);
      final repository = FakeWorkoutRepository(
        detailError: StateError('detail unavailable'),
        workouts: [target],
      );

      await _pumpDetail(tester, repository: repository, assignmentId: 42);

      expect(repository.detailCallCount, 1);
      expect(repository.lastDetailId, 42);
      expect(repository.workoutsCallCount, 1);
      expect(find.text('Deep Link Program'), findsWidgets);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('detail fails and refreshed cache misses the assignment, '
        'showing a recoverable error', (tester) async {
      final repository = FakeWorkoutRepository(
        detailError: StateError('detail unavailable'),
        workouts: [_assignment(99)],
      );

      await _pumpDetail(tester, repository: repository, assignmentId: 42);

      expect(repository.detailCallCount, 1);
      expect(repository.workoutsCallCount, 1);
      expect(find.text('Retry'), findsOneWidget);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Deep Link Program'), findsNothing);
    });

    testWidgets('invalid or missing assignment id never calls the detail '
        'endpoint', (tester) async {
      final repository = FakeWorkoutRepository(detailResult: _assignment(0));

      await _pumpDetail(tester, repository: repository, assignmentId: 0);

      expect(repository.detailCallCount, 0);
      expect(repository.workoutsCallCount, 0);
      expect(find.text('This workout program is unavailable.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry issues exactly one additional detail request', (
      tester,
    ) async {
      final repository = FakeWorkoutRepository(
        detailError: StateError('detail unavailable'),
        workouts: const [],
      );

      await _pumpDetail(tester, repository: repository, assignmentId: 42);
      expect(repository.detailCallCount, 1);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(repository.detailCallCount, 2);
      expect(repository.workoutsCallCount, 2);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
