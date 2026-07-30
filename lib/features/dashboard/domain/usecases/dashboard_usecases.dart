import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

/// Use case: Fetch full dashboard data.
class GetDashboardUseCase {
  final DashboardRepository _repository;
  const GetDashboardUseCase(this._repository);

  Future<DashboardEntity> call() => _repository.getDashboard();
}

/// Use case: Get cached dashboard (for offline support).
class GetCachedDashboardUseCase {
  final DashboardRepository _repository;
  const GetCachedDashboardUseCase(this._repository);

  Future<DashboardEntity?> call() => _repository.getCachedDashboard();
}
