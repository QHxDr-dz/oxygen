import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/workouts/domain/entities/workout_entities.dart';
import '../../features/workouts/presentation/providers/workout_state_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutNotifierProvider.notifier).loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Programs',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your assigned workout programs',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(workoutNotifierProvider.notifier)
                        .loadWorkouts(),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WorkoutState state) {
    if (state.isLoading && state.assignments.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerBox(height: 280, borderRadius: 20),
        ),
      );
    }

    if (state.error != null && state.assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.textMutedDark,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppTheme.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  ref.read(workoutNotifierProvider.notifier).loadWorkouts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.assignments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.fitness_center_outlined,
        title: 'No Programs Assigned',
        description:
            'Your trainer hasn\'t assigned any workout programs yet. Check back soon!',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(workoutNotifierProvider.notifier).loadWorkouts(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surfaceDark,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: state.assignments.length,
        itemBuilder: (context, index) {
          final assignment = state.assignments[index];
          return _WorkoutProgramCard(assignment: assignment, onTap: () {});
        },
      ),
    );
  }
}

class _WorkoutProgramCard extends StatelessWidget {
  final WorkoutAssignmentEntity assignment;
  final VoidCallback onTap;

  const _WorkoutProgramCard({required this.assignment, required this.onTap});

  Color get _difficultyColor {
    switch (assignment.program.difficulty.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final progress = assignment.progress / 100.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderDark, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image area
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withAlpha(60),
                    AppTheme.secondary.withAlpha(60),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _difficultyColor.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        assignment.program.difficulty,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _difficultyColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Week ${assignment.currentWeek}/${assignment.program.durationWeeks}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.program.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (assignment.program.description != null &&
                      assignment.program.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      assignment.program.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),
                      Text(
                        '${assignment.progress}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.borderDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: assignment.completed
                            ? AppTheme.success.withAlpha(30)
                            : AppTheme.primary,
                        foregroundColor: assignment.completed
                            ? AppTheme.success
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        assignment.completed
                            ? 'Completed ✓'
                            : (assignment.progress > 0
                                  ? 'Continue'
                                  : 'Start Program'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
