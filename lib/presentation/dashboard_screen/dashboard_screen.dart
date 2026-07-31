import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/domain/entities/dashboard_entity.dart';
import '../../features/dashboard/presentation/providers/dashboard_notifier.dart';
import '../../features/notifications/presentation/providers/notification_state_notifier.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';
import './widgets/active_subscription_card_widget.dart';
import './widgets/current_program_card_widget.dart';
import './widgets/heart_rate_chart_widget.dart';
import './widgets/quick_stats_row_widget.dart';
import './widgets/today_workout_card_widget.dart';
import './widgets/user_header_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load notification count for badge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationNotifierProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardNotifierProvider);
    final notifState = ref.watch(notificationNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: dashboardAsync.when(
          loading: () => const DashboardSkeletonWidget(),
          error: (error, _) => _buildError(error.toString()),
          data: (dashboard) => _buildContent(dashboard, notifState.unreadCount),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppTheme.textMutedDark,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(dashboardNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DashboardEntity dashboard, int unreadCount) {
    final member = dashboard.member;
    final subscription = dashboard.subscription;
    final workout = dashboard.workout;
    final stats = dashboard.statistics;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardNotifierProvider.notifier).refresh(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surfaceDark,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: UserHeaderWidget(
                name: member.name,
                goal: member.goal,
                photoUrl: member.photo ?? '',
                photoSemanticLabel:
                    'Profile photo of ${member.name}, gym member',
                notificationCount: unreadCount,
                onNotificationTap: () =>
                    context.go(AppRoutes.notificationsScreen),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (subscription != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActiveSubscriptionCardWidget(
                  plan: subscription.plan.name,
                  status: subscription.status,
                  daysLeft: subscription.daysLeft,
                  totalDays: subscription.plan.days,
                  startDate: _formatDate(subscription.startDate),
                  endDate: _formatDate(subscription.endDate),
                ),
              ),
            ),
          if (subscription != null)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (workout != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CurrentProgramCardWidget(
                  name: workout.program.name,
                  difficulty: workout.program.difficulty,
                  currentWeek: workout.currentWeek,
                  totalWeeks: workout.program.durationWeeks,
                  completedDays:
                      (workout.progress *
                              workout.program.durationWeeks *
                              5 /
                              100)
                          .round(),
                  totalDays: workout.program.durationWeeks * 5,
                ),
              ),
            ),
          if (workout != null)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (workout?.today != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TodayWorkoutCardWidget(
                  name: workout!.program.name,
                  type: workout.program.difficulty,
                  exerciseCount: 0,
                  estimatedMinutes: 45,
                  status: workout.today!.status,
                  isRestDay: false,
                  onStartTap: () => context.push(
                    AppRoutes.workoutPlayerScreen,
                    extra: {'sessionId': workout.today!.id},
                  ),
                ),
              ),
            ),
          if (workout?.today != null)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (workout == null && subscription == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: EmptyStateWidget(
                  icon: Icons.fitness_center_outlined,
                  title: 'No Active Program',
                  description:
                      'Contact your trainer to get a workout program assigned.',
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: QuickStatsRowWidget(
                completedWorkouts: stats.workoutsCompleted,
                totalSessions: stats.totalSessions,
                completionRate: stats.completionRate.round(),
                personalRecords: stats.personalRecords,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: HeartRateChartWidget(heartRateData: []),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
