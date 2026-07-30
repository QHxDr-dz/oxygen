import '../../domain/entities/notification_entity.dart';

/// Data model for a notification.
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
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      readAt: json['read_at'] as String?,
      createdAt:
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
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
    return NotificationCountModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }

  NotificationCountEntity toEntity() =>
      NotificationCountEntity(total: total, unread: unread);
}
