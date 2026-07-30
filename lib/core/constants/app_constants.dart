/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String memberDataKey = 'member_data';
  static const String localeKey = 'app_locale';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_complete';
  static const String offlineQueueKey = 'offline_queue';
  static const String lastSyncKey = 'last_sync_timestamp';

  // Hive box names
  static const String dashboardBox = 'dashboard_cache';
  static const String workoutsBox = 'workouts_cache';
  static const String notificationsBox = 'notifications_cache';
  static const String subscriptionBox = 'subscription_cache';
  static const String offlineQueueBox = 'offline_queue';
  static const String settingsBox = 'settings';

  // Supported locales
  static const String localeEn = 'en';
  static const String localeAr = 'ar';

  // Workout statuses
  static const String statusScheduled = 'scheduled';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusOngoing = 'ongoing';
  static const String statusExpired = 'expired';
  static const String statusCancelled = 'cancelled';
  static const String statusActive = 'active';
  static const String statusApproved = 'approved';
  static const String statusPending = 'pending';
    // Offline sync
  static const int maxOfflineQueueSize = 1000;
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
}
