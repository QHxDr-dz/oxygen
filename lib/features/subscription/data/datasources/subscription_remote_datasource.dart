import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/subscription_model.dart';

/// Remote data source for subscription endpoint.
class SubscriptionRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  const SubscriptionRemoteDataSource(this._dioClient, this._localStorage);

  Future<SubscriptionModel?> getSubscription() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.subscription,
    );
    final data = response.data!;
    final payload = data['data'];
    if (payload == null) return null;
    final model = SubscriptionModel.fromJson(payload as Map<String, dynamic>);

    // Cache
    await _localStorage.setString(
      AppConstants.subscriptionBox,
      jsonEncode(payload),
    );
    return model;
  }

  SubscriptionModel? getCachedSubscription() {
    try {
      final raw = _localStorage.getString(AppConstants.subscriptionBox);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SubscriptionModel.fromJson(json);
    } catch (e) {
      AppLogger.warning('Failed to read cached subscription', error: e);
      return null;
    }
  }
}
