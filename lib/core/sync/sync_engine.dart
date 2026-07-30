import 'dart:async';

import '../network/dio_client.dart';
import '../utils/logger.dart';
import './connectivity_monitor.dart';
import './offline_queue.dart';

/// Centralized synchronization engine.
///
/// Responsibilities:
/// - Detect connectivity changes
/// - Process queued offline operations
/// - Retry failed operations with backoff
/// - Notify listeners when sync completes
///
/// No feature implements its own sync — all go through here.
class SyncEngine {
  final DioClient _dioClient;
  final OfflineQueue _offlineQueue;
  final ConnectivityMonitor _connectivityMonitor;

  final _syncCompleteController = StreamController<void>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncEngine(this._dioClient, this._offlineQueue, this._connectivityMonitor);

  Stream<void> get onSyncComplete => _syncCompleteController.stream;

  Future<void> initialize() async {
    await _connectivityMonitor.initialize();

    _connectivitySubscription = _connectivityMonitor.onConnectivityChanged
        .listen((isOnline) {
          if (isOnline) {
            AppLogger.info(
              'SyncEngine: connectivity restored, processing queue',
              tag: 'Sync',
            );
            processQueue();
          }
        });

    // Process any pending operations on startup if online
    if (_connectivityMonitor.isOnline) {
      await processQueue();
    }
  }

  /// Enqueue an operation for later sync.
  Future<void> enqueue(OfflineOperation operation) async {
    await _offlineQueue.enqueue(operation);
    AppLogger.info(
      'SyncEngine: operation queued (${operation.type})',
      tag: 'Sync',
    );

    // Try immediately if online
    if (_connectivityMonitor.isOnline) {
      await processQueue();
    }
  }

  /// Process all queued operations.
  Future<void> processQueue() async {
    if (_isSyncing) return;
    if (_offlineQueue.isEmpty) return;

    _isSyncing = true;
    AppLogger.info(
      'SyncEngine: processing ${_offlineQueue.length} queued operations',
      tag: 'Sync',
    );

    final operations = _offlineQueue.getAll();
    int successCount = 0;

    for (final operation in operations) {
      if (!_connectivityMonitor.isOnline) {
        AppLogger.warning(
          'SyncEngine: went offline during sync, stopping',
          tag: 'Sync',
        );
        break;
      }

      try {
        await _executeOperation(operation);
        await _offlineQueue.remove(operation.id);
        successCount++;
        AppLogger.info(
          'SyncEngine: operation ${operation.id} synced',
          tag: 'Sync',
        );
      } catch (e) {
        await _offlineQueue.updateRetryCount(operation.id);
        AppLogger.warning(
          'SyncEngine: operation ${operation.id} failed (retry ${operation.retryCount})',
          error: e,
        );

        // Drop operations that have failed too many times
        if (operation.retryCount >= 5) {
          AppLogger.error(
            'SyncEngine: dropping operation ${operation.id} after 5 retries',
            tag: 'Sync',
          );
          await _offlineQueue.remove(operation.id);
        }
      }
    }

    _isSyncing = false;

    if (successCount > 0) {
      _syncCompleteController.add(null);
      AppLogger.info(
        'SyncEngine: sync complete ($successCount operations)',
        tag: 'Sync',
      );
    }
  }

  Future<void> _executeOperation(OfflineOperation operation) async {
    switch (operation.method.toUpperCase()) {
      case 'POST':
        await _dioClient.post<void>(operation.endpoint, data: operation.body);
        break;
      case 'PUT':
        await _dioClient.put<void>(operation.endpoint, data: operation.body);
        break;
      case 'DELETE':
        await _dioClient.delete<void>(operation.endpoint);
        break;
      default:
        throw UnsupportedError(
          'SyncEngine: unsupported method ${operation.method}',
        );
    }
  }

  bool get isOnline => _connectivityMonitor.isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingCount => _offlineQueue.length;

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncCompleteController.close();
    _connectivityMonitor.dispose();
  }
}
