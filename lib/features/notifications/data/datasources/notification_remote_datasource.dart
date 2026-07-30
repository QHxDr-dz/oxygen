import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/notification_model.dart';

/// Remote data source for notification endpoints.
class NotificationRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  const NotificationRemoteDataSource(this._dioClient, this._localStorage);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.notifications,
    );
    final data = response.data!;
    final list = data['data'] as List<dynamic>? ?? [];
    final models = list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache
    await _localStorage.setString(
      AppConstants.notificationsBox,
      jsonEncode(list),
    );
    return models;
  }

  Future<NotificationCountModel> getNotificationCount() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.notificationsCount,
    );
    final data = response.data!;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return NotificationCountModel.fromJson(payload);
  }

  Future<void> markAsRead(String notificationId) async {
    await _dioClient.post<void>(
      ApiConstants.markNotificationRead(notificationId),
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dioClient.delete<void>(
      ApiConstants.deleteNotification(notificationId),
    );
  }

  List<NotificationModel>? getCachedNotifications() {
    try {
      final raw = _localStorage.getString(AppConstants.notificationsBox);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.warning('Failed to read cached notifications', error: e);
      return null;
    }
  }
}
