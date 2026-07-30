import '../entities/subscription_entity.dart';

/// Contract for subscription operations.
abstract class SubscriptionRepository {
  /// Fetch the current member's active subscription.
  /// Returns null if no active subscription exists.
  Future<SubscriptionEntity?> getSubscription();

  /// Return cached subscription without network call.
  Future<SubscriptionEntity?> getCachedSubscription();
}
