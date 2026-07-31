import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/workouts/domain/entities/workout_entities.dart';
import '../../features/workouts/presentation/providers/workout_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(workoutHistoryNotifierProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(workoutHistoryNotifierProvider);

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
                          'Workout History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your completed sessions',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.invalidate(workoutHistoryNotifierProvider),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: historyAsync.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerBox(height: 90, borderRadius: 16),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                          error.toString(),
                          style: const TextStyle(
                            color: AppTheme.textSecondaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(workoutHistoryNotifierProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (history) {
                  if (history.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.history_rounded,
                      title: 'No Workout History',
                      description:
                          'Complete your first workout to see your history here.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(workoutHistoryNotifierProvider),
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceDark,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return _HistoryTile(entry: history[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WorkoutHistoryEntity entry;

  const _HistoryTile({required this.entry});

  Color get _statusColor {
    switch (entry.status) {
      case 'completed':
        return AppTheme.success;
      case 'in_progress':
        return AppTheme.accent;
      default:
        return AppTheme.textMutedDark;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 22,
              color: _statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.workoutName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDate(entry.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                    if (entry.durationMinutes != null) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '·',
                        style: TextStyle(color: AppTheme.textMutedDark),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.durationMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.completionPercentage}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.completedSets}/${entry.totalSets} sets',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
