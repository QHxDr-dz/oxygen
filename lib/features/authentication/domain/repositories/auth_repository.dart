import '../entities/auth_entities.dart';

/// Contract for authentication operations.
/// Implementations live in the data layer.
abstract class AuthRepository {
  /// Authenticate with email and password.
  /// Returns [AuthResultEntity] with token, user, and member.
  Future<AuthResultEntity> login({
    required String email,
    required String password,
  });

  /// Register a new account.
  /// Returns the created [UserEntity] (pending approval).
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Fetch current authenticated user profile.
  Future<AuthResultEntity> getMe();

  /// Invalidate token on the server and clear local storage.
  Future<void> logout();

  /// Change the authenticated user's password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  /// Update the authenticated user's profile.
  Future<UserEntity> updateProfile({
    required String name,
    required String email,
  });

  /// Check if a valid token exists locally.
  Future<bool> isAuthenticated();

  /// Retrieve the stored auth token.
  Future<String?> getToken();
}
