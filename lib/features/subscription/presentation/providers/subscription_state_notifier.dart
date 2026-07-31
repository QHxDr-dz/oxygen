import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

class SubscriptionState {
  final SubscriptionEntity? subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionEntity? subscription,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SubscriptionStateNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  Future<void> loadSubscription() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final subscription = await ref
          .read(getSubscriptionUseCaseProvider)
          .call();
      state = state.copyWith(subscription: subscription, isLoading: false);
    } catch (e) {
      AppLogger.error(
        'SubscriptionStateNotifier.loadSubscription failed',
        error: e,
      );
      try {
        final cached = await ref
            .read(subscriptionRepositoryProvider)
            .getCachedSubscription();
        state = state.copyWith(subscription: cached, isLoading: false);
      } catch (_) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionStateNotifier, SubscriptionState>(
      SubscriptionStateNotifier.new,
    );
