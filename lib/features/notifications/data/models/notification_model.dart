import '../../domain/entities/notification_entity.dart';

/// Data model for a notification.
/// Supports both flat and nested (data.data) API response structures.
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? readAt;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Support nested structures: json['data']['data'] or json['data'] or flat json
    final Map<String, dynamic> payload = (json['data'] is Map<String, dynamic>)
        ? (json['data'] as Map<String, dynamic>)
        : json;

    return NotificationModel(
      id: (payload['id'] ?? json['id'] ?? '').toString(),
      title: payload['title'] as String? ?? json['title'] as String? ?? '',
      message:
          payload['message'] as String? ??
          payload['body'] as String? ??
          json['message'] as String? ??
          json['body'] as String? ??
          '',
      type: payload['type'] as String? ?? json['type'] as String? ?? 'general',
      readAt: payload['read_at'] as String? ?? json['read_at'] as String?,
      createdAt:
          payload['created_at'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'read_at': readAt,
    'created_at': createdAt,
  };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? readAt,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  NotificationEntity toEntity() {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(createdAt);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: type,
      readAt: readAt,
      createdAt: parsedDate,
    );
  }
}

/// Data model for notification count.
class NotificationCountModel {
  final int total;
  final int unread;

  const NotificationCountModel({required this.total, required this.unread});

  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return NotificationCountModel(
      total: (payload['total'] as num?)?.toInt() ?? 0,
      unread: (payload['unread'] as num?)?.toInt() ?? 0,
    );
  }

  NotificationCountEntity toEntity() =>
      NotificationCountEntity(total: total, unread: unread);
}
