import '../entities/dashboard_entity.dart';

/// Contract for dashboard operations.
abstract class DashboardRepository {
  /// Fetch full dashboard data (member, subscription, workout, stats, achievements).
  Future<DashboardEntity> getDashboard();

  /// Return cached dashboard without network call.
  Future<DashboardEntity?> getCachedDashboard();
}
