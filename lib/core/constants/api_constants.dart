import '../config/environment.dart';

/// All API endpoint paths.
/// Never hardcode paths in data sources — always reference this class.
class ApiConstants {
  ApiConstants._();

  static String get baseUrl => Environment.baseUrl;

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String changePassword = '/password';
  static const String updateProfile = '/profile';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Workouts
  static const String workouts = '/workouts';
  static String workoutDetail(int assignmentId) => '/workouts/$assignmentId';
  static String startWorkout(int assignmentId) =>
      '/workouts/$assignmentId/start';
  static const String currentWorkout = '/workouts/current';
  static String workoutSession(int assignmentId) =>
      '/workouts/$assignmentId/session';
  static String completeSet(int sessionId, int setId) =>
      '/workouts/session/$sessionId/sets/$setId/complete';
  static String finishWorkout(int sessionId) =>
      '/workouts/session/$sessionId/finish';
  static const String workoutHistory = '/workouts/history';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsCount = '/notifications/count';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static String deleteNotification(String id) => '/notifications/$id';

  // Subscription
  static const String subscription = '/subscription';
}
