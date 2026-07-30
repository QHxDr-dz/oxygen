import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'widgets/exercise_player_card_widget.dart';
import 'widgets/rest_timer_widget.dart';
import 'widgets/set_controls_widget.dart';
import 'widgets/workout_player_header_widget.dart';
import 'widgets/workout_session_complete_widget.dart';

// TODO: Replace with Riverpod WorkoutSessionNotifier for production

class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  // TODO: Replace with Riverpod WorkoutSessionState
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isRestTimerVisible = false;
  bool _isSessionComplete = false;
  int _elapsedSeconds = 0;
  late Timer _elapsedTimer;

  final List<Map<String, dynamic>> _exercises = [
    {
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
          'Lie on a flat bench. Grip the bar shoulder-width apart. Lower the bar to your mid-chest, then press up explosively. Keep your feet flat on the floor and back slightly arched.',
      'completedSets': <int>[],
    },
    {
      'name': 'Incline Dumbbell Press',
      'targetMuscle': 'Upper Chest',
      'equipment': 'Dumbbells',
      'sets': 3,
      'reps': '10-12',
      'weight': 30.0,
      'restSeconds': 75,
      'gifUrl':
          'https://images.pixabay.com/photo/2017/08/07/14/02/man-2604149_640.jpg',
      'gifSemanticLabel':
          'Muscular man performing incline dumbbell press on incline bench',
      'instructions':
          'Set bench to 30-45 degree incline. Press dumbbells up and slightly inward. Lower slowly with control. Feel the stretch at the bottom.',
      'completedSets': <int>[],
    },
    {
      'name': 'Cable Chest Flyes',
      'targetMuscle': 'Chest / Pecs',
      'equipment': 'Cable Machine',
      'sets': 3,
      'reps': '12-15',
      'weight': 15.0,
      'restSeconds': 60,
      'gifUrl':
          'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=400',
      'gifSemanticLabel':
          'Athlete performing cable chest fly exercise with arms extended',
      'instructions':
          'Stand in center of cable station. Bring handles together in front of chest with slight bend in elbows. Squeeze chest at peak contraction. Return slowly.',
      'completedSets': <int>[],
    },
    {
      'name': 'Tricep Pushdowns',
      'targetMuscle': 'Triceps',
      'equipment': 'Cable Machine',
      'sets': 3,
      'reps': '12-15',
      'weight': 25.0,
      'restSeconds': 60,
      'gifUrl':
          'https://images.pexels.com/photos/4162487/pexels-photo-4162487.jpeg?auto=compress&cs=tinysrgb&w=400',
      'gifSemanticLabel': 'Person doing cable tricep pushdown exercise in gym',
      'instructions':
          'Stand facing cable stack. Grip bar overhand. Keep elbows at sides and push bar down until arms fully extend. Return slowly.',
      'completedSets': <int>[],
    },
  ];

  Map<String, dynamic> get _currentExercise =>
      _exercises[_currentExerciseIndex];
  int get _totalSets =>
      _exercises.fold(0, (sum, e) => sum + (e['sets'] as int));
  int get _completedSets =>
      _exercises.fold(0, (sum, e) => sum + (e['completedSets'] as List).length);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _startElapsedTimer();
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

  void _completeSet() {
    final exercise = _exercises[_currentExerciseIndex];
    final completedSets = exercise['completedSets'] as List<int>;
    if (!completedSets.contains(_currentSetIndex)) {
      setState(() {
        completedSets.add(_currentSetIndex);
      });
    }

    final totalSets = exercise['sets'] as int;
    if (_currentSetIndex < totalSets - 1) {
      // More sets remaining — show rest timer
      setState(() => _isRestTimerVisible = true);
    } else {
      // All sets done for this exercise — go to next
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
      // All exercises done
      setState(() {
        _isSessionComplete = true;
        _isRestTimerVisible = false;
      });
      _elapsedTimer.cancel();
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

  void _finishWorkout() {
    // TODO: Replace with Riverpod WorkoutSessionRepository.finishSession()
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
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
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
    if (_isSessionComplete) {
      return WorkoutSessionCompleteWidget(
        workoutName: 'Upper Body Power',
        totalSets: _totalSets,
        elapsedSeconds: _elapsedSeconds,
        onClose: () => context.pop(),
      );
    }

    final exercise = _currentExercise;
    final completedSets = exercise['completedSets'] as List<int>;
    final totalSets = exercise['sets'] as int;
    final sessionProgress = _totalSets > 0 ? _completedSets / _totalSets : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.backgroundDark, Color(0xFF1A1040)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Fixed header
                WorkoutPlayerHeaderWidget(
                  workoutName: 'Upper Body Power',
                  elapsedTime: _elapsedFormatted,
                  sessionProgress: sessionProgress,
                  onFinish: _finishWorkout,
                ),
                // Scrollable exercise content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        // Exercise navigation indicator
                        _ExerciseStepIndicator(
                          current: _currentExerciseIndex,
                          total: _exercises.length,
                        ),
                        const SizedBox(height: 16),
                        // Exercise card with GIF
                        ExercisePlayerCardWidget(
                          exerciseName: exercise['name'] as String,
                          targetMuscle: exercise['targetMuscle'] as String,
                          equipment: exercise['equipment'] as String,
                          gifUrl: exercise['gifUrl'] as String,
                          gifSemanticLabel:
                              exercise['gifSemanticLabel'] as String,
                          instructions: exercise['instructions'] as String,
                          reps: exercise['reps'] as String,
                          weight: exercise['weight'] as double,
                          onWeightChanged: _updateWeight,
                        ),
                        const SizedBox(height: 16),
                        // Set tracker
                        _SetTrackerWidget(
                          totalSets: exercise['sets'] as int,
                          currentSetIndex: _currentSetIndex,
                          completedSets: completedSets.cast<int>(),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom controls
                SetControlsWidget(
                  currentSetIndex: _currentSetIndex,
                  totalSets: exercise['sets'] as int,
                  onPrevious: _previousExercise,
                  onCompleteSet: _completeSet,
                  onNext: _advanceExercise,
                  canGoPrevious: _currentExerciseIndex > 0,
                  canGoNext: _currentExerciseIndex < _exercises.length - 1,
                ),
              ],
            ),
          ),
          // Rest timer overlay
          if (_isRestTimerVisible)
            RestTimerWidget(
              durationSeconds: _currentExercise['restSeconds'] as int,
              onComplete: _onRestComplete,
              onSkip: _skipRest,
              nextExerciseName: _currentExerciseIndex < _exercises.length - 1
                  ? _exercises[_currentExerciseIndex + 1]['name'] as String
                  : null,
            ),
        ],
      ),
    );
  }
}

class _ExerciseStepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _ExerciseStepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final isDone = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.success
                : isActive
                ? AppTheme.primary
                : AppTheme.borderDark,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _SetTrackerWidget extends StatelessWidget {
  final int totalSets;
  final int currentSetIndex;
  final List<int> completedSets;

  const _SetTrackerWidget({
    required this.totalSets,
    required this.currentSetIndex,
    required this.completedSets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sets',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const Spacer(),
              Text(
                'Set ${currentSetIndex + 1} of $totalSets',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(totalSets, (i) {
              final isCompleted = completedSets.contains(i);
              final isCurrent = i == currentSetIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < totalSets - 1 ? 8 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.success.withOpacity(0.15)
                          : isCurrent
                          ? AppTheme.primary.withOpacity(0.15)
                          : AppTheme.backgroundDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.success.withOpacity(0.5)
                            : isCurrent
                            ? AppTheme.primary.withOpacity(0.5)
                            : AppTheme.borderDark,
                        width: isCurrent ? 1.5 : 0.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppTheme.success,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? AppTheme.primaryLight
                                    : AppTheme.textMutedDark,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
