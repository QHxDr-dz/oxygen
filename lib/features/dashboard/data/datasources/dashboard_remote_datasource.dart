import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/dashboard_model.dart';

/// Remote data source for dashboard endpoint.
class DashboardRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  const DashboardRemoteDataSource(this._dioClient, this._localStorage);

  Future<DashboardModel> getDashboard() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.dashboard,
    );
    final data = response.data!;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    final model = DashboardModel.fromJson(payload);

    // Cache for offline
    await _localStorage.setString(
      AppConstants.dashboardBox,
      jsonEncode(payload),
    );
    AppLogger.info('Dashboard fetched and cached', tag: 'Dashboard');
    return model;
  }

  DashboardModel? getCachedDashboard() {
    try {
      final raw = _localStorage.getString(AppConstants.dashboardBox);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DashboardModel.fromJson(json);
    } catch (e) {
      AppLogger.warning('Failed to read cached dashboard', error: e);
      return null;
    }
  }
}
