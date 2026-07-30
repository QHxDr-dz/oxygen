import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/logger.dart';

/// Concrete implementation of [AuthRepository].
/// Coordinates between remote data source and local cache.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthResultEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('AuthRepository.login failed', error: e, stackTrace: st);
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final model = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'AuthRepository.register failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<AuthResultEntity> getMe() async {
    try {
      final model = await _remoteDataSource.getMe();
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('AuthRepository.getMe failed', error: e, stackTrace: st);
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      AppLogger.warning(
        'AuthRepository.logout: remote call failed, local cleared',
        error: e,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'AuthRepository.changePassword failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final model = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error(
        'AuthRepository.updateProfile failed',
        error: e,
        stackTrace: st,
      );
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<bool> isAuthenticated() => _remoteDataSource.hasToken();

  @override
  Future<String?> getToken() => _remoteDataSource.getStoredToken();
}
