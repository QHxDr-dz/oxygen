import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

/// Use case: Login with email and password.
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<AuthResultEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}

/// Use case: Register a new account.
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}

/// Use case: Logout the current user.
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

/// Use case: Fetch current user profile.
class GetMeUseCase {
  final AuthRepository _repository;
  const GetMeUseCase(this._repository);

  Future<AuthResultEntity> call() => _repository.getMe();
}

/// Use case: Check if user is authenticated.
class IsAuthenticatedUseCase {
  final AuthRepository _repository;
  const IsAuthenticatedUseCase(this._repository);

  Future<bool> call() => _repository.isAuthenticated();
}

/// Use case: Change user password.
class ChangePasswordUseCase {
  final AuthRepository _repository;
  const ChangePasswordUseCase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }
}

/// Use case: Update user profile.
class UpdateProfileUseCase {
  final AuthRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<UserEntity> call({required String name, required String email}) {
    return _repository.updateProfile(name: name, email: email);
  }
}
