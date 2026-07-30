import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

/// Use case: Get current subscription.
class GetSubscriptionUseCase {
  final SubscriptionRepository _repository;
  const GetSubscriptionUseCase(this._repository);

  Future<SubscriptionEntity?> call() => _repository.getSubscription();
}
