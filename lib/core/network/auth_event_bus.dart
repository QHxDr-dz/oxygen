import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-level events emitted by the HTTP layer.
enum AuthEvent {
  /// No session event. Used as the initial/reset value.
  none,

  /// The backend rejected the access token (HTTP 401).
  unauthorized,
}

/// Holds the latest session event so presentation and routing layers can react
/// to authentication failures originating in the network layer.
class AuthEventBus extends Notifier<AuthEvent> {
  @override
  AuthEvent build() => AuthEvent.none;

  void emitUnauthorized() {
    if (state == AuthEvent.unauthorized) return;
    state = AuthEvent.unauthorized;
  }

  void reset() {
    if (state == AuthEvent.none) return;
    state = AuthEvent.none;
  }
}

final authEventBusProvider = NotifierProvider<AuthEventBus, AuthEvent>(
  AuthEventBus.new,
);
