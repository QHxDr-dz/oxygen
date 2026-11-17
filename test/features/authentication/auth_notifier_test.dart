import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/core/network/auth_event_bus.dart';
import 'package:oxygenclub/features/authentication/domain/entities/auth_entities.dart';
import 'package:oxygenclub/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oxygenclub/features/authentication/presentation/providers/auth_notifier.dart';
import 'package:oxygenclub/features/providers.dart';

final AuthResultEntity _authResult = AuthResultEntity(
  token: 'test-token',
  user: UserEntity(
    id: 1,
    name: 'Test Member',
    email: 'member@example.com',
    status: 'active',
    approvalStatus: 'approved',
  ),
);

class FakeAuthRepository implements AuthRepository {
  bool hasToken = true;
  Object? meError;
  AuthResultEntity? cachedAuth;
  int cachedAuthCallCount = 0;

  @override
  Future<AuthResultEntity> login({
    required String email,
    required String password,
  }) async {
    return _authResult;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _authResult.user;
  }

  @override
  Future<AuthResultEntity> getMe() async {
    if (meError != null) throw meError!;
    return _authResult;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {}

  @override
  Future<UserEntity> updateProfile({
    required String name,
    required String email,
  }) async {
    return _authResult.user;
  }

  @override
  Future<bool> isAuthenticated() async => hasToken;

  @override
  Future<String?> getToken() async => hasToken ? 'test-token' : null;

  @override
  Future<AuthResultEntity?> getCachedAuth() async {
    cachedAuthCallCount++;
    return cachedAuth;
  }
}

void main() {
  group('AuthNotifier', () {
    test('initialize falls back to cached auth when /me fails', () async {
      final repository = FakeAuthRepository()
        ..meError = StateError('temporary outage')
        ..cachedAuth = _authResult;
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      // Read first so the notifier's auth-event listener is registered.
      container.read(authNotifierProvider);
      await container.read(authNotifierProvider.notifier).initialize();

      final state = container.read(authNotifierProvider);
      expect(state.isInitialized, isTrue);
      expect(state.isAuthenticated, isTrue);
      expect(state.user?.email, 'member@example.com');
      expect(repository.cachedAuthCallCount, 1);
    });

    test('unauthorized event clears an authenticated session', () async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      container.read(authNotifierProvider);
      final signedIn = await container
          .read(authNotifierProvider.notifier)
          .login(email: 'member@example.com', password: 'password');
      expect(signedIn, isTrue);
      expect(container.read(authNotifierProvider).isAuthenticated, isTrue);

      container.read(authEventBusProvider.notifier).emitUnauthorized();

      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isInitialized, isTrue);
      expect(state.error, 'Session expired. Please log in again.');
    });
  });
}
