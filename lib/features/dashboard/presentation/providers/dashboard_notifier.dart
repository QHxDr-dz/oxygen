import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_entity.dart';
import '../../../providers.dart';
import '../../../../core/utils/logger.dart';

/// Manages dashboard data state.
class DashboardNotifier extends AsyncNotifier<DashboardEntity> {
  @override
  Future<DashboardEntity> build() async {
    return _fetchDashboard();
  }

  Future<DashboardEntity> _fetchDashboard() async {
    try {
      return await ref.read(getDashboardUseCaseProvider).call();
    } catch (e) {
      AppLogger.warning(
        'DashboardNotifier: remote failed, trying cache',
        error: e,
      );
      final cached = await ref.read(getCachedDashboardUseCaseProvider).call();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchDashboard);
  }
}

final dashboardNotifierProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardEntity>(
      DashboardNotifier.new,
    );
