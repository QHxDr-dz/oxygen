import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_models.dart';

/// Remote data source for authentication endpoints.
class AuthRemoteDataSource {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  const AuthRemoteDataSource(
    this._dioClient,
    this._secureStorage,
    this._localStorage,
  );

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    final model = AuthResponseModel.fromJson(data);

    // Persist token and user data
    await _secureStorage.write(AppConstants.authTokenKey, model.token);
    await _localStorage.setJson(AppConstants.userDataKey, model.user.toJson());
    if (model.member != null) {
      await _localStorage.setJson(
        AppConstants.memberDataKey,
        model.member!.toJson(),
      );
    }

    AppLogger.info('Login successful for ${model.user.email}', tag: 'Auth');
    return model;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final data = response.data!;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AuthResponseModel> getMe() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.me,
    );
    final data = response.data!;
    // /me may return data wrapped or flat
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    final model = AuthResponseModel.fromJson(payload);

    // Refresh local cache
    await _localStorage.setJson(AppConstants.userDataKey, model.user.toJson());
    if (model.member != null) {
      await _localStorage.setJson(
        AppConstants.memberDataKey,
        model.member!.toJson(),
      );
    }
    return model;
  }

  Future<void> logout() async {
    try {
      await _dioClient.post<void>(ApiConstants.logout);
    } catch (e) {
      AppLogger.warning(
        'Logout API call failed (continuing local cleanup)',
        error: e,
      );
    } finally {
      await _secureStorage.delete(AppConstants.authTokenKey);
      await _localStorage.remove(AppConstants.userDataKey);
      await _localStorage.remove(AppConstants.memberDataKey);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _dioClient.put<void>(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.updateProfile,
      data: {'name': name, 'email': email},
    );
    final data = response.data!;
    final user = UserModel.fromJson(
      data['user'] as Map<String, dynamic>? ?? data,
    );
    await _localStorage.setJson(AppConstants.userDataKey, user.toJson());
    return user;
  }

  Future<String?> getStoredToken() =>
      _secureStorage.read(AppConstants.authTokenKey);

  Future<bool> hasToken() async {
    final token = await _secureStorage.read(AppConstants.authTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Returns cached user from local storage (no network call).
  AuthResponseModel? getCachedAuth() {
    final userData = _localStorage.getJson(AppConstants.userDataKey);
    if (userData == null) return null;
    final memberData = _localStorage.getJson(AppConstants.memberDataKey);
    return AuthResponseModel(
      token: '',
      user: UserModel.fromJson(userData),
      member: memberData != null ? MemberModel.fromJson(memberData) : null,
    );
  }
}
