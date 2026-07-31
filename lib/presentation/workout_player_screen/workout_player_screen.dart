import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/workouts/presentation/providers/workout_session_notifier.dart';
import '../../theme/app_theme.dart';
import './widgets/exercise_player_card_widget.dart';
import './widgets/rest_timer_widget.dart';
import './widgets/set_controls_widget.dart';
import './widgets/workout_player_header_widget.dart';
import './widgets/workout_session_complete_widget.dart';

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  final int? sessionId;
  final int? assignmentId;

  const WorkoutPlayerScreen({this.sessionId, this.assignmentId, super.key});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() =>
      _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isRestTimerVisible = false;
  bool _isSessionComplete = false;
  int _elapsedSeconds = 0;
  late Timer _elapsedTimer;
  // Each entry maps exercise metadata + a list of real backend set IDs.
  // 'setIds' is List<int> — index i holds the backend set ID for set i.
  List<Map<String, dynamic>> _exercises = [];
  bool _initialized = false;

  WorkoutSessionNotifier get _sessionNotifier =>
      ref.read(workoutSessionNotifierProvider.notifier);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _startElapsedTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  /// Problem 1 fix: use initSession() which checks for an existing session
  /// before ever calling startWorkout(). This prevents duplicate sessions.
  Future<void> _initSession() async {
    if (widget.assignmentId != null) {
      // initSession handles the full priority chain:
      // getCurrentSession → getWorkoutSession → startWorkout
      await _sessionNotifier.initSession(widget.assignmentId!);
    } else if (widget.sessionId != null) {
      // A specific session ID was passed — load it directly via current session.
      await _sessionNotifier.loadSession(widget.sessionId!);
    }
    _buildExerciseList();
  }

  /// Problem 2 fix: build the exercise list using real backend set IDs from
  /// sessionSets, not exercise.id. Each exercise entry carries a 'setIds'
  /// list where setIds[i] is the backend ID for the i-th set.
  void _buildExerciseList() {
    final session = ref.read(workoutSessionNotifierProvider).session;
    if (session != null && session.exercises.isNotEmpty) {
      setState(() {
        _exercises = session.exercises.map((e) {
          // Build the list of real backend set IDs for this exercise.
          // If the session returned session_sets, use those IDs in order.
          // Otherwise fall back to an empty list (completeSet will be skipped).
          final setIds = e.sessionSets.isNotEmpty
              ? (e.sessionSets.toList()
                  ..sort((a, b) => a.setNumber.compareTo(b.setNumber)))
              : <dynamic>[];

          return {
            'exerciseDetailId': e.id, // pivot row ID (not used for API calls)
            'name': e.exercise.name,
            'targetMuscle': e.exercise.targetMuscle,
            'equipment': e.exercise.equipment,
            // setIds[i] = real backend set ID for set index i
            'setIds': setIds.map((s) {
              if (s is int) return s;
              // s is SessionSetEntity
              return (s as dynamic).id as int;
            }).toList(),
            'sets': e.sets,
            'reps': '${e.reps}',
            'weight': 0.0,
            'restSeconds': e.restSeconds,
            'gifUrl': e.exercise.image,
            'gifSemanticLabel': 'Exercise animation for ${e.exercise.name}',
            'instructions': e.exercise.description ?? '',
            'completedSets': <int>[],
          };
        }).toList();
        _initialized = true;
      });
    } else {
      // No session data — show empty state (no demo data, per constraints).
      setState(() {
        _exercises = [];
        _initialized = true;
      });
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _elapsedTimer.cancel();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    super.dispose();
  }

  String get _elapsedFormatted {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Map<String, dynamic> get _currentExercise =>
      _exercises.isNotEmpty ? _exercises[_currentExerciseIndex] : {};

  /// Problem 5 fix: use backend completionPercentage for session-level progress.
  double get _sessionProgress {
    final session = ref.read(workoutSessionNotifierProvider).session;
    if (session != null && session.totalSets > 0) {
      return session.completionPercentage / 100.0;
    }
    // Fallback to local count only if backend data is unavailable.
    final total = _exercises.fold(
      0,
      (sum, e) => sum + (e['sets'] as int? ?? 0),
    );
    if (total == 0) return 0.0;
    final completed = _exercises.fold(
      0,
      (sum, e) => sum + (e['completedSets'] as List).length,
    );
    return completed / total;
  }

  int get _totalSets =>
      _exercises.fold(0, (sum, e) => sum + (e['sets'] as int? ?? 0));

  int get _completedSets =>
      _exercises.fold(0, (sum, e) => sum + (e['completedSets'] as List).length);

  Future<void> _completeSet() async {
    final exercise = _exercises[_currentExerciseIndex];
    final completedSets = exercise['completedSets'] as List<int>;
    final weight = exercise['weight'] as double? ?? 0.0;
    final reps =
        int.tryParse((exercise['reps'] as String? ?? '10').split('-').first) ??
        10;

    // Problem 2 fix: use the real backend set ID from setIds[_currentSetIndex].
    final setIds = exercise['setIds'] as List<int>? ?? [];
    final realSetId = setIds.length > _currentSetIndex
        ? setIds[_currentSetIndex]
        : 0;

    if (!completedSets.contains(_currentSetIndex)) {
      setState(() => completedSets.add(_currentSetIndex));
    }

    // Problem 3 fix: await the call — the notifier updates session state from
    // the backend response, keeping completionPercentage in sync.
    if (realSetId > 0) {
      await _sessionNotifier.completeSet(
        setId: realSetId,
        reps: reps,
        weight: weight,
      );
    }

    final totalSets = exercise['sets'] as int? ?? 0;
    if (_currentSetIndex < totalSets - 1) {
      setState(() => _isRestTimerVisible = true);
    } else {
      _advanceExercise();
    }
  }

  void _advanceExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
        _isRestTimerVisible = false;
      });
    } else {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    _elapsedTimer.cancel();
    await _sessionNotifier.finishWorkout();
    if (mounted) {
      setState(() {
        _isSessionComplete = true;
        _isRestTimerVisible = false;
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSetIndex = 0;
        _isRestTimerVisible = false;
      });
    }
  }

  void _onRestComplete() {
    setState(() {
      _currentSetIndex++;
      _isRestTimerVisible = false;
    });
  }

  void _skipRest() {
    setState(() {
      _currentSetIndex++;
      _isRestTimerVisible = false;
    });
  }

  void _updateWeight(double weight) {
    setState(() {
      _exercises[_currentExerciseIndex]['weight'] = weight;
    });
  }

  void _showFinishEarlyDialog() {
    // Problem 5 fix: show backend-sourced completed/total counts.
    final session = ref.read(workoutSessionNotifierProvider).session;
    final completedCount = session?.completedSets ?? _completedSets;
    final totalCount = session?.totalSets ?? _totalSets;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.borderDark, width: 0.5),
        ),
        title: const Text(
          'Finish Workout Early?',
          style: TextStyle(
            color: AppTheme.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'You have completed $completedCount of $totalCount sets. Your progress will be saved.',
          style: const TextStyle(
            color: AppTheme.textSecondaryDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMutedDark),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _finishSession();
              if (mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the session state so the widget rebuilds when backend data arrives.
    final sessionState = ref.watch(workoutSessionNotifierProvider);

    if (!_initialized || sessionState.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_isSessionComplete) {
      final session = sessionState.session;
      final workoutName =
          session?.workoutDay?.name ??
          (_exercises.isNotEmpty
              ? (_exercises.first['name'] as String? ?? 'Workout')
              : 'Workout');
      // Problem 5 fix: use backend totalSets for completion screen.
      final totalSets = session?.totalSets ?? _totalSets;
      return WorkoutSessionCompleteWidget(
        workoutName: workoutName,
        totalSets: totalSets,
        elapsedSeconds: _elapsedSeconds,
        onClose: () => context.pop(),
      );
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textPrimaryDark,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No exercises found for this session.',
            style: TextStyle(color: AppTheme.textSecondaryDark),
          ),
        ),
      );
    }

    final exercise = _currentExercise;
    final totalSets = exercise['sets'] as int? ?? 0;
    // Problem 5 fix: progress comes from backend session data.
    final sessionProgress = _sessionProgress;
    final workoutName = exercise['name'] as String? ?? 'Workout';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                WorkoutPlayerHeaderWidget(
                  workoutName: workoutName,
                  elapsedTime: _elapsedFormatted,
                  sessionProgress: sessionProgress,
                  onFinish: _showFinishEarlyDialog,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ExercisePlayerCardWidget(
                          exerciseName: exercise['name'] as String? ?? '',
                          targetMuscle:
                              exercise['targetMuscle'] as String? ?? '',
                          equipment: exercise['equipment'] as String? ?? '',
                          gifUrl: exercise['gifUrl'] as String? ?? '',
                          gifSemanticLabel:
                              exercise['gifSemanticLabel'] as String? ?? '',
                          instructions:
                              exercise['instructions'] as String? ?? '',
                          reps: exercise['reps'] as String? ?? '10',
                          weight: exercise['weight'] as double? ?? 0.0,
                          onWeightChanged: _updateWeight,
                        ),
                        SetControlsWidget(
                          currentSetIndex: _currentSetIndex,
                          totalSets: totalSets,
                          onPrevious: _previousExercise,
                          onCompleteSet: _completeSet,
                          onNext: _advanceExercise,
                          canGoPrevious: _currentExerciseIndex > 0,
                          canGoNext:
                              _currentExerciseIndex < _exercises.length - 1,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isRestTimerVisible)
            RestTimerWidget(
              durationSeconds: exercise['restSeconds'] as int? ?? 60,
              onComplete: _onRestComplete,
              onSkip: _skipRest,
              nextExerciseName: _currentExerciseIndex < _exercises.length - 1
                  ? _exercises[_currentExerciseIndex + 1]['name'] as String?
                  : null,
            ),
        ],
      ),
    );
  }
}
