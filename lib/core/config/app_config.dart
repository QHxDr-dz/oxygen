/// Central application configuration.
/// All feature flags, timeouts, and app-wide settings live here.
class AppConfig {
  AppConfig._();

  // App identity
  static const String appName = 'Oxygen Club';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache TTL (seconds)
  static const int dashboardCacheTtl = 300; // 5 min
  static const int workoutsCacheTtl = 600; // 10 min
  static const int notificationsCacheTtl = 60; // 1 min
  static const int subscriptionCacheTtl = 300; // 5 min

  // Offline queue
  static const int maxOfflineQueueSize = 500;
  static const int syncIntervalSeconds = 30;

  // Workout player
  static const int defaultRestSeconds = 60;
  static const int minRestSeconds = 10;
  static const int maxRestSeconds = 300;

  // Image
  static const String placeholderImageUrl =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400';
}
