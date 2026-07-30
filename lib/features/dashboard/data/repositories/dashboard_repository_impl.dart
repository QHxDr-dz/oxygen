import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';

/// Concrete implementation of [DashboardRepository].
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  const DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardEntity> getDashboard() async {
    try {
      final model = await _remoteDataSource.getDashboard();
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'DashboardRepository.getDashboard failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<DashboardEntity?> getCachedDashboard() async {
    try {
      final model = _remoteDataSource.getCachedDashboard();
      return model?.toEntity();
    } catch (e) {
      AppLogger.warning(
        'DashboardRepository.getCachedDashboard failed',
        error: e,
      );
      return null;
    }
  }
}
