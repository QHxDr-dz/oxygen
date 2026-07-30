import 'dart:convert';
import '../storage/local_storage.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Represents a queued offline operation.
class OfflineOperation {
  final String id;
  final String type;
  final String endpoint;
  final String method;
  final Map<String, dynamic>? body;
  final DateTime createdAt;
  int retryCount;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.method,
    this.body,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      body: json['body'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'endpoint': endpoint,
    'method': method,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'retry_count': retryCount,
  };
}

/// Persisted queue for offline operations.
/// Operations survive app kills and are retried when connectivity is restored.
class OfflineQueue {
  final LocalStorage _localStorage;

  OfflineQueue(this._localStorage);

  Future<void> enqueue(OfflineOperation operation) async {
    final queue = _loadQueue();
    if (queue.length >= AppConstants.maxOfflineQueueSize) {
      AppLogger.warning(
        'OfflineQueue: max size reached, dropping oldest operation',
      );
      queue.removeAt(0);
    }
    queue.add(operation);
    await _saveQueue(queue);
    AppLogger.info('OfflineQueue: enqueued ${operation.type}', tag: 'Sync');
  }

  Future<void> remove(String operationId) async {
    final queue = _loadQueue();
    queue.removeWhere((op) => op.id == operationId);
    await _saveQueue(queue);
  }

  Future<void> updateRetryCount(String operationId) async {
    final queue = _loadQueue();
    final index = queue.indexWhere((op) => op.id == operationId);
    if (index != -1) {
      queue[index].retryCount++;
      await _saveQueue(queue);
    }
  }

  List<OfflineOperation> getAll() => _loadQueue();

  Future<void> clear() async {
    await _localStorage.remove(AppConstants.offlineQueueKey);
  }

  List<OfflineOperation> _loadQueue() {
    try {
      final raw = _localStorage.getString(AppConstants.offlineQueueKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => OfflineOperation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.warning('OfflineQueue: failed to load queue', error: e);
      return [];
    }
  }

  Future<void> _saveQueue(List<OfflineOperation> queue) async {
    try {
      final encoded = jsonEncode(queue.map((op) => op.toJson()).toList());
      await _localStorage.setString(AppConstants.offlineQueueKey, encoded);
    } catch (e) {
      AppLogger.error('OfflineQueue: failed to save queue', error: e);
    }
  }

  int get length => _loadQueue().length;
  bool get isEmpty => _loadQueue().isEmpty;
}