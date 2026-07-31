import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/about_screen/about_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/help_screen/help_screen.dart';
import '../presentation/history_screen/history_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/privacy_screen/privacy_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/register_screen/register_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/subscription_screen/subscription_screen.dart';
import '../presentation/workout_detail_screen/workout_detail_screen.dart';
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
  static const String aboutScreen = '/about';
  static const String privacyScreen = '/privacy';
  static const String helpScreen = '/help';
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
    GoRoute(
      path: AppRoutes.workoutDetailScreen,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final assignmentId = extra?['assignmentId'] as int? ?? 0;
        return _slidePage(
          WorkoutDetailScreen(assignmentId: assignmentId),
          state,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settingsScreen,
      pageBuilder: (context, state) =>
          _slidePage(const SettingsScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.aboutScreen,
      pageBuilder: (context, state) => _slidePage(const AboutScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.privacyScreen,
      pageBuilder: (context, state) => _slidePage(const PrivacyScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.helpScreen,
      pageBuilder: (context, state) => _slidePage(const HelpScreen(), state),
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
