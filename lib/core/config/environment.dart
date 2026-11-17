/// Environment configuration for Oxygen Club.
/// Switch environments via:
///   flutter run --dart-define=ENV=development
///   flutter run --dart-define=ENV=staging
///   flutter run --dart-define=ENV=production
enum AppEnvironment { development, staging, production }

class Environment {
  Environment._();

  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static AppEnvironment get current {
    switch (_env) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  static bool get isDevelopment => current == AppEnvironment.development;
  static bool get isStaging => current == AppEnvironment.staging;
  static bool get isProduction => current == AppEnvironment.production;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.staging:
        return 'http://127.0.0.1:8000/api/mobile/v1';
      case AppEnvironment.production:
        return 'http://127.0.0.1:8000/api/mobile/v1';
      default:
        return 'http://127.0.0.1:8000/api/mobile/v1';
    }
  }

  static bool get verboseLogging => !isProduction;

  static int get connectTimeoutMs => 15000;
  static int get receiveTimeoutMs => 30000;
  static int get maxRetries => 3;

static String get websiteUrl {
  switch (current) {
    case AppEnvironment.staging:
      return 'https://staging.oxygenclub.app';

    case AppEnvironment.production:
      return 'https://api.oxygenclub.app'; // غيّرها إذا كان موقعك العام ليس على api.
                                           // مثلاً: https://oxygenclub.app

    default:
      return 'http://192.168.0.166:8000';
  }
}
}
