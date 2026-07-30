import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_entities.dart';
import '../../../providers.dart';
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
  AuthState build() => const AuthState();

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await ref
          .read(isAuthenticatedUseCaseProvider)
          .call();
      if (isAuthenticated) {
        // Try to refresh from server, fall back to cache
        try {
          final result = await ref.read(getMeUseCaseProvider).call();
          state = AuthState(authResult: result, isInitialized: true);
        } catch (e) {
          AppLogger.warning(
            'AuthNotifier: /me failed, using cached auth',
            error: e,
          );
          // Still authenticated — token exists
          state = AuthState(isInitialized: true);
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
      AppLogger.info('AuthNotifier: login successful', tag: 'Auth');
      return true;
    } catch (e) {
      AppLogger.error('AuthNotifier.login failed', error: e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
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
        error: e.toString(),
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
