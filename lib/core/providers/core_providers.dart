import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../sync/connectivity_monitor.dart';
import '../sync/offline_queue.dart';
import '../sync/sync_engine.dart';

// ─── Core Infrastructure Providers ──────────────────────────────────────────

/// Secure storage — singleton.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Local storage — must be initialized before use.
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

/// Dio HTTP client — depends on secure storage for auth token injection.
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
});

/// Connectivity monitor.
final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  return ConnectivityMonitor(Connectivity());
});

/// Offline queue.
final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return OfflineQueue(localStorage);
});

/// Sync engine — central coordinator for offline operations.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final offlineQueue = ref.watch(offlineQueueProvider);
  final connectivityMonitor = ref.watch(connectivityMonitorProvider);
  return SyncEngine(dioClient, offlineQueue, connectivityMonitor);
});
