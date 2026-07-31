import 'dart:async';

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
  List<Map<String, dynamic>> _exercises = [];
  bool _initialized = false;

  WorkoutSessionNotifier get _sessionNotifier =>
      ref.read(workoutSessionNotifierProvider.notifier);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _startElapsedTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  Future<void> _initSession() async {
    if (widget.assignmentId != null) {
      await _sessionNotifier.startWorkout(widget.assignmentId!);
    }
    final session = ref.read(workoutSessionNotifierProvider).session;
    if (session != null && session.exercises.isNotEmpty) {
      setState(() {
        _exercises = session.exercises
            .map(
              (e) => {
                'id': e.id,
                'name': e.exercise.name,
                'targetMuscle': e.exercise.targetMuscle,
                'equipment': e.exercise.equipment,
                'sets': e.sets,
                'reps': '${e.reps}',
                'weight': 0.0,
                'restSeconds': e.restSeconds,
                'gifUrl': e.exercise.image,
                'gifSemanticLabel': 'Exercise animation for ${e.exercise.name}',
                'instructions': e.exercise.description ?? '',
                'completedSets': <int>[],
              },
            )
            .toList();
        _initialized = true;
      });
    } else {
      setState(() {
        _exercises = _demoExercises;
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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  String get _elapsedFormatted {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Map<String, dynamic> get _currentExercise =>
      _exercises.isNotEmpty ? _exercises[_currentExerciseIndex] : {};

  int get _totalSets =>
      _exercises.fold(0, (sum, e) => sum + (e['sets'] as int? ?? 0));

  int get _completedSets =>
      _exercises.fold(0, (sum, e) => sum + (e['completedSets'] as List).length);

  void _completeSet() {
    final exercise = _exercises[_currentExerciseIndex];
    final completedSets = exercise['completedSets'] as List<int>;
    final setId = exercise['id'] as int? ?? 0;
    final weight = exercise['weight'] as double? ?? 0.0;
    final reps =
        int.tryParse((exercise['reps'] as String? ?? '10').split('-').first) ??
        10;

    if (!completedSets.contains(_currentSetIndex)) {
      setState(() => completedSets.add(_currentSetIndex));
    }

    // Fire-and-forget API call — UI updates immediately without waiting
    if (setId > 0) {
      _sessionNotifier.completeSet(setId: setId, reps: reps, weight: weight);
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
          'You have completed $_completedSets of $_totalSets sets. Your progress will be saved.',
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
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_isSessionComplete) {
      final workoutName = _exercises.isNotEmpty
          ? (_exercises.first['name'] as String? ?? 'Workout')
          : 'Workout';
      return WorkoutSessionCompleteWidget(
        workoutName: workoutName,
        totalSets: _totalSets,
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
    final sessionProgress = _totalSets > 0 ? _completedSets / _totalSets : 0.0;
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

  static final List<Map<String, dynamic>> _demoExercises = [
    {
      'id': 0,
      'name': 'Barbell Bench Press',
      'targetMuscle': 'Chest',
      'equipment': 'Barbell',
      'sets': 4,
      'reps': '8-10',
      'weight': 80.0,
      'restSeconds': 90,
      'gifUrl':
          'https://images.pexels.com/photos/4164761/pexels-photo-4164761.jpeg?auto=compress&cs=tinysrgb&w=400',
      'gifSemanticLabel':
          'Man performing barbell bench press on flat bench with spotter',
      'instructions':
          'Lie on a flat bench. Grip the bar shoulder-width apart. Lower the bar to your mid-chest, then press up explosively.',
      'completedSets': <int>[],
    },
    {
      'id': 0,
      'name': 'Incline Dumbbell Press',
      'targetMuscle': 'Upper Chest',
      'equipment': 'Dumbbells',
      'sets': 3,
      'reps': '10-12',
      'weight': 30.0,
      'restSeconds': 75,
      'gifUrl':
          'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=400',
      'gifSemanticLabel':
          'Muscular man performing incline dumbbell press on incline bench',
      'instructions':
          'Set bench to 30-45 degree incline. Press dumbbells up and slightly inward.',
      'completedSets': <int>[],
    },
  ];
}
