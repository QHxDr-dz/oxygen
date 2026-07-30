import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/loading_skeleton_widget.dart';
import './widgets/active_subscription_card_widget.dart';
import './widgets/current_program_card_widget.dart';
import './widgets/heart_rate_chart_widget.dart';
import './widgets/quick_stats_row_widget.dart';
import './widgets/today_workout_card_widget.dart';
import './widgets/user_header_widget.dart';

// TODO: Replace with Riverpod DashboardNotifier for production

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  late Map<String, dynamic> _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    // TODO: Replace with Riverpod DashboardRepository.fetchDashboard()
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _dashboardData = _mockDashboardData;
    });
  }

  Future<void> _refresh() async {
    // TODO: Replace with Riverpod ref.invalidate(dashboardProvider)
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  static final Map<String, dynamic> _mockDashboardData = {
    'member': {
      'name': 'Ahmed Hassan',
      'goal': 'Build Muscle',
      'photo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_188ec9f01-1772420038393.png',
      'photoSemanticLabel':
          'Athletic man with short hair in gym attire smiling',
    },
    'subscription': {
      'plan': 'Premium Elite',
      'status': 'ongoing',
      'daysLeft': 23,
      'totalDays': 30,
      'startDate': 'Jul 7, 2026',
      'endDate': 'Aug 7, 2026',
    },
    'currentProgram': {
      'name': 'Power Hypertrophy Pro',
      'difficulty': 'Advanced',
      'currentWeek': 5,
      'totalWeeks': 8,
      'completedDays': 27,
      'totalDays': 40,
    },
    'todayWorkout': {
      'name': 'Upper Body Power',
      'type': 'Strength',
      'exerciseCount': 8,
      'estimatedMinutes': 55,
      'status': 'scheduled',
      'isRestDay': false,
    },
    'stats': {
      'completedWorkouts': 27,
      'totalSessions': 31,
      'completionRate': 87,
      'personalRecords': 6,
    },
    'heartRateData': [
      72,
      85,
      110,
      145,
      168,
      155,
      142,
      130,
      115,
      98,
      84,
      75,
      70,
      68,
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(child: DashboardSkeletonWidget()),
      );
    }

    final member = _dashboardData['member'] as Map<String, dynamic>;
    final subscription = _dashboardData['subscription'] as Map<String, dynamic>;
    final program = _dashboardData['currentProgram'] as Map<String, dynamic>;
    final todayWorkout = _dashboardData['todayWorkout'] as Map<String, dynamic>;
    final stats = _dashboardData['stats'] as Map<String, dynamic>;
    final hrData = (_dashboardData['heartRateData'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.surfaceDark,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: UserHeaderWidget(
                    name: member['name'] as String,
                    goal: member['goal'] as String,
                    photoUrl: member['photo'] as String,
                    photoSemanticLabel: member['photoSemanticLabel'] as String,
                    notificationCount: 3,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ActiveSubscriptionCardWidget(
                    plan: subscription['plan'] as String,
                    status: subscription['status'] as String,
                    daysLeft: subscription['daysLeft'] as int,
                    totalDays: subscription['totalDays'] as int,
                    startDate: subscription['startDate'] as String,
                    endDate: subscription['endDate'] as String,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CurrentProgramCardWidget(
                    name: program['name'] as String,
                    difficulty: program['difficulty'] as String,
                    currentWeek: program['currentWeek'] as int,
                    totalWeeks: program['totalWeeks'] as int,
                    completedDays: program['completedDays'] as int,
                    totalDays: program['totalDays'] as int,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TodayWorkoutCardWidget(
                    name: todayWorkout['name'] as String,
                    type: todayWorkout['type'] as String,
                    exerciseCount: todayWorkout['exerciseCount'] as int,
                    estimatedMinutes: todayWorkout['estimatedMinutes'] as int,
                    status: todayWorkout['status'] as String,
                    isRestDay: todayWorkout['isRestDay'] as bool,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: QuickStatsRowWidget(
                    completedWorkouts: stats['completedWorkouts'] as int,
                    totalSessions: stats['totalSessions'] as int,
                    completionRate: stats['completionRate'] as int,
                    personalRecords: stats['personalRecords'] as int,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HeartRateChartWidget(heartRateData: hrData),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
