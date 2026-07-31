import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/notification_model.dart';

/// Remote data source for notification endpoints.
/// Supports pagination for infinite scroll.
class NotificationRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  const NotificationRemoteDataSource(this._dioClient, this._localStorage);

  /// Fetch paginated notifications. [page] starts at 1.
  Future<NotificationPageModel> getNotifications({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = response.data!;

    // Support both paginated and non-paginated responses
    final List<dynamic> list;
    int? lastPage;
    int? total;

    if (data['data'] is List) {
      list = data['data'] as List<dynamic>;
      // Check for pagination meta
      final meta = data['meta'] as Map<String, dynamic>?;
      lastPage = (meta?['last_page'] as num?)?.toInt();
      total = (meta?['total'] as num?)?.toInt();
    } else if (data['data'] is Map) {
      // Laravel paginator wraps in data.data
      final inner = data['data'] as Map<String, dynamic>;
      list = inner['data'] as List<dynamic>? ?? [];
      lastPage = (inner['last_page'] as num?)?.toInt();
      total = (inner['total'] as num?)?.toInt();
    } else {
      list = [];
    }

    final models = list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache first page for offline
    if (page == 1) {
      await _localStorage.setString(
        AppConstants.notificationsBox,
        jsonEncode(list),
      );
    }

    return NotificationPageModel(
      notifications: models,
      currentPage: page,
      lastPage: lastPage ?? 1,
      total: total ?? models.length,
    );
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

/// Paginated response wrapper.
class NotificationPageModel {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;

  const NotificationPageModel({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
}
