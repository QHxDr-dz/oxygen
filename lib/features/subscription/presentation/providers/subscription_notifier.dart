import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// Manages subscription state.
class SubscriptionNotifier extends AsyncNotifier<SubscriptionEntity?> {
  @override
  Future<SubscriptionEntity?> build() async {
    return _fetchSubscription();
  }

  Future<SubscriptionEntity?> _fetchSubscription() async {
    try {
      return await ref.read(getSubscriptionUseCaseProvider).call();
    } catch (e) {
      AppLogger.warning(
        'SubscriptionNotifier: remote failed, trying cache',
        error: e,
      );
      final cached = await ref
          .read(subscriptionRepositoryProvider)
          .getCachedSubscription();
      return cached;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchSubscription);
  }
}

final subscriptionNotifierProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionEntity?>(
      SubscriptionNotifier.new,
    );
