import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/logger.dart';

/// Monitors network connectivity and broadcasts state changes.
/// Used by SyncEngine to trigger queue processing when online.
class ConnectivityMonitor {
  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityMonitor(this._connectivity);

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    // Check current state
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);
    AppLogger.info(
      'ConnectivityMonitor: initial state = ${_isOnline ? "online" : "offline"}',
      tag: 'Sync',
    );

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _hasConnection(results);

      if (_isOnline != wasOnline) {
        AppLogger.info(
          'ConnectivityMonitor: ${_isOnline ? "came online" : "went offline"}',
          tag: 'Sync',
        );
        _controller.add(_isOnline);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
