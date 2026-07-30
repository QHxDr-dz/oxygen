import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';

/// Concrete implementation of [SubscriptionRepository].
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  const SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<SubscriptionEntity?> getSubscription() async {
    try {
      final model = await _remoteDataSource.getSubscription();
      return model?.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'SubscriptionRepository.getSubscription failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<SubscriptionEntity?> getCachedSubscription() async {
    try {
      final model = _remoteDataSource.getCachedSubscription();
      return model?.toEntity();
    } catch (e) {
      AppLogger.warning(
        'SubscriptionRepository.getCachedSubscription failed',
        error: e,
      );
      return null;
    }
  }
}
