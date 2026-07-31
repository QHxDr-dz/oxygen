import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/workouts/domain/entities/workout_entities.dart';
import '../../features/workouts/presentation/providers/workout_state_notifier.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_skeleton_widget.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final int assignmentId;

  const WorkoutDetailScreen({required this.assignmentId, super.key});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  WorkoutAssignmentEntity? _assignment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignment();
    });
  }

  void _loadAssignment() {
    final state = ref.read(workoutNotifierProvider);
    if (state.assignments.isEmpty) {
      ref.read(workoutNotifierProvider.notifier).loadWorkouts().then((_) {
        _findAssignment();
      });
    } else {
      _findAssignment();
    }
  }

  void _findAssignment() {
    final state = ref.read(workoutNotifierProvider);
    final found = state.assignments
        .where((a) => a.id == widget.assignmentId)
        .firstOrNull;
    if (mounted) {
      setState(() => _assignment = found);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutNotifierProvider);

    if (_assignment == null && workoutState.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, null),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ShimmerBox(height: 120, borderRadius: 16),
                      SizedBox(height: 16),
                      ShimmerBox(height: 80, borderRadius: 16),
                      SizedBox(height: 16),
                      ShimmerBox(height: 200, borderRadius: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_assignment == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, null),
              const Expanded(
                child: Center(
                  child: Text(
                    'Program not found',
                    style: TextStyle(color: AppTheme.textSecondaryDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final assignment = _assignment!;
    final program = assignment.program;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildAppBar(context, program.name)),
            SliverToBoxAdapter(child: _buildProgramHeader(assignment)),
            SliverToBoxAdapter(child: _buildProgressSection(assignment)),
            if (program.phases.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildPhaseCard(program.phases[index], assignment),
                  childCount: program.phases.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(assignment),
    );
  }

  Widget _buildAppBar(BuildContext context, String? title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppTheme.textPrimaryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title ?? 'Program Details',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramHeader(WorkoutAssignmentEntity assignment) {
    final program = assignment.program;
    final difficultyColor = _difficultyColor(program.difficulty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withAlpha(40),
              AppTheme.secondary.withAlpha(40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          program.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (program.description != null) ...[
              const SizedBox(height: 14),
              Text(
                program.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryDark,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                  icon: Icons.calendar_month_outlined,
                  label: '${program.durationWeeks} Weeks',
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.layers_outlined,
                  label: '${program.phases.length} Phases',
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.today_outlined,
                  label: 'Week ${assignment.currentWeek}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(WorkoutAssignmentEntity assignment) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                Text(
                  '${assignment.progress}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (assignment.progress / 100.0).clamp(0.0, 1.0),
                backgroundColor: AppTheme.borderDark,
                valueColor: AlwaysStoppedAnimation<Color>(
                  assignment.completed ? AppTheme.success : AppTheme.primary,
                ),
                minHeight: 8,
              ),
            ),
            if (assignment.completed) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Program Completed!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(
    PhaseEntity phase,
    WorkoutAssignmentEntity assignment,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${phase.phaseOrder}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        Text(
                          'Weeks ${phase.startWeek}–${phase.endWeek}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (phase.workoutDays.isNotEmpty) ...[
              const Divider(height: 1, color: AppTheme.borderDark),
              ...phase.workoutDays.map((day) => _buildDayRow(day, assignment)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(
    WorkoutDayEntity day,
    WorkoutAssignmentEntity assignment,
  ) {
    return InkWell(
      onTap: day.isRestDay
          ? null
          : () {
              context.push(
                AppRoutes.workoutPlayerScreen,
                extra: {'assignmentId': assignment.id, 'dayId': day.id},
              );
            },
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: day.isRestDay
                    ? AppTheme.borderDark
                    : AppTheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  day.isRestDay
                      ? Icons.self_improvement_rounded
                      : Icons.fitness_center_rounded,
                  size: 18,
                  color: day.isRestDay
                      ? AppTheme.textMutedDark
                      : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  Text(
                    day.isRestDay
                        ? 'Rest Day'
                        : day.focus.isNotEmpty
                        ? day.focus
                        : '${day.exercises.length} exercises',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (!day.isRestDay)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMutedDark,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(WorkoutAssignmentEntity assignment) {
    // Problem 4 fix: if the assignment already has an in-progress session,
    // show "Continue Workout" and resume it — never create a new session.
    final hasActiveSession = assignment.latestSession?.isInProgress ?? false;
    final isCompleted = assignment.completed;

    final buttonLabel = isCompleted
        ? 'Program Completed'
        : hasActiveSession
        ? 'Continue Workout'
        : 'Start Workout';

    final buttonIcon = isCompleted
        ? Icons.check_circle_rounded
        : hasActiveSession
        ? Icons.play_circle_filled_rounded
        : Icons.play_arrow_rounded;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: const Border(
          top: BorderSide(color: AppTheme.borderDark, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isCompleted
              ? null
              : () {
                  // Pass assignmentId — WorkoutPlayerScreen.initSession()
                  // will detect the existing session and resume it without
                  // creating a duplicate (Problem 4 fix).
                  context.push(
                    AppRoutes.workoutPlayerScreen,
                    extra: {'assignmentId': assignment.id},
                  );
                },
          icon: Icon(buttonIcon, size: 20),
          label: Text(buttonLabel),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: isCompleted
                ? AppTheme.success
                : hasActiveSession
                ? AppTheme.accent
                : AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.success;
      case 'intermediate':
        return AppTheme.accent;
      case 'advanced':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondaryDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
