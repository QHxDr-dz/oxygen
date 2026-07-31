import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/history_screen/history_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/register_screen/register_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/subscription_screen/subscription_screen.dart';
import '../presentation/workout_player_screen/workout_player_screen.dart';
import '../presentation/workouts_screen/workouts_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String dashboardScreen = '/dashboard';
  static const String workoutsScreen = '/workouts';
  static const String workoutDetailScreen = '/workout-detail';
  static const String workoutPlayerScreen = '/workout-player';
  static const String historyScreen = '/history';
  static const String notificationsScreen = '/notifications';
  static const String subscriptionScreen = '/subscription';
  static const String profileScreen = '/profile';
  static const String settingsScreen = '/settings';
}

CustomTransitionPage _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

CustomTransitionPage _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    GoRoute(
      path: AppRoutes.splashScreen,
      pageBuilder: (context, state) => _fadePage(const SplashScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.loginScreen,
      pageBuilder: (context, state) => _fadePage(const LoginScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.registerScreen,
      pageBuilder: (context, state) =>
          _slidePage(const RegisterScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.workoutPlayerScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final sessionId = extra?['sessionId'] as int?;
        final assignmentId = extra?['assignmentId'] as int?;
        return _slidePage(
          WorkoutPlayerScreen(sessionId: sessionId, assignmentId: assignmentId),
          state,
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboardScreen,
              pageBuilder: (context, state) =>
                  _fadePage(const DashboardScreen(), state),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.workoutsScreen,
              pageBuilder: (context, state) =>
                  _fadePage(const WorkoutsScreen(), state),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.historyScreen,
              pageBuilder: (context, state) =>
                  _fadePage(const HistoryScreen(), state),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.notificationsScreen,
              pageBuilder: (context, state) =>
                  _fadePage(const NotificationsScreen(), state),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profileScreen,
              pageBuilder: (context, state) =>
                  _fadePage(const ProfileScreen(), state),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.subscriptionScreen,
      pageBuilder: (context, state) =>
          _slidePage(const SubscriptionScreen(), state),
    ),
  ],
);
