import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_entities.dart';
import '../../../providers.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_event_bus.dart';
import '../../../../core/utils/logger.dart';

/// Auth state — represents the current authentication status.
class AuthState {
  final AuthResultEntity? authResult;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.authResult,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  bool get isAuthenticated => authResult != null;
  UserEntity? get user => authResult?.user;
  MemberEntity? get member => authResult?.member;

  AuthState copyWith({
    AuthResultEntity? authResult,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearAuth = false,
    bool clearError = false,
  }) {
    return AuthState(
      authResult: clearAuth ? null : (authResult ?? this.authResult),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Manages authentication state across the app.
/// Handles login, register, logout, and session restoration.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // A 401 from any request invalidates the whole session, not just that call.
    ref.listen(authEventBusProvider, (previous, next) {
      if (next == AuthEvent.unauthorized) {
        state = state.copyWith(
          clearAuth: true,
          isLoading: false,
          isInitialized: true,
          error: 'Session expired. Please log in again.',
        );
      }
    });
    return const AuthState();
  }

  Future<void> initialize() async {
    if (state.isInitialized || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final isAuthenticated = await ref
          .read(isAuthenticatedUseCaseProvider)
          .call();
      if (isAuthenticated) {
        // Try to refresh from the server, then fall back to the cached profile.
        try {
          final result = await ref.read(getMeUseCaseProvider).call();
          state = AuthState(authResult: result, isInitialized: true);
        } catch (e) {
          AppLogger.warning(
            'AuthNotifier: /me failed, using cached auth',
            error: e,
          );
          final cached = await ref.read(getCachedAuthUseCaseProvider).call();
          if (cached != null) {
            state = AuthState(authResult: cached, isInitialized: true);
          } else {
            state = const AuthState(isInitialized: true);
          }
        }
      } else {
        state = const AuthState(isInitialized: true);
      }
    } catch (e) {
      AppLogger.error('AuthNotifier.initialize failed', error: e);
      state = const AuthState(isInitialized: true);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);
      state = AuthState(authResult: result, isInitialized: true);
      ref.read(authEventBusProvider.notifier).reset();
      AppLogger.info('AuthNotifier: login successful', tag: 'Auth');
      return true;
    } catch (e) {
      AppLogger.error('AuthNotifier.login failed', error: e);
      state = state.copyWith(
        isLoading: false,
        error: friendlyErrorMessage(e),
        isInitialized: true,
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(registerUseCaseProvider)
          .call(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation,
          );
      state = state.copyWith(isLoading: false, isInitialized: true);
      return true;
    } catch (e) {
      AppLogger.error('AuthNotifier.register failed', error: e);
      state = state.copyWith(
        isLoading: false,
        error: friendlyErrorMessage(e),
        isInitialized: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(logoutUseCaseProvider).call();
    } catch (e) {
      AppLogger.warning('AuthNotifier.logout: error during logout', error: e);
    } finally {
      ref.read(authEventBusProvider.notifier).reset();
      state = const AuthState(isInitialized: true);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
