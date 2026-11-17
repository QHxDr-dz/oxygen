import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/core/network/auth_event_bus.dart';

void main() {
  test('auth event bus emits and resets unauthorized events', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authEventBusProvider), AuthEvent.none);

    container.read(authEventBusProvider.notifier).emitUnauthorized();
    expect(container.read(authEventBusProvider), AuthEvent.unauthorized);

    // Repeated 401s should not create redundant state transitions.
    container.read(authEventBusProvider.notifier).emitUnauthorized();
    expect(container.read(authEventBusProvider), AuthEvent.unauthorized);

    container.read(authEventBusProvider.notifier).reset();
    expect(container.read(authEventBusProvider), AuthEvent.none);
  });
}
