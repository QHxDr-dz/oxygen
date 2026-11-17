import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../../network/api_exception.dart';
import '../../utils/logger.dart';

/// Injects the Bearer token into every request.
/// On 401 response, clears token and throws [UnauthorizedException].
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final void Function()? onUnauthorized;

  AuthInterceptor(this._secureStorage, {this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.read(AppConstants.authTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      AppLogger.warning('AuthInterceptor: failed to read token', error: e);
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final isAuthEndpoint =
        path == ApiConstants.login || path == ApiConstants.register;

    // A 401 from login/register means "bad credentials", not "session expired".
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      AppLogger.warning('AuthInterceptor: 401 received, clearing token');
      try {
        await _secureStorage.delete(AppConstants.authTokenKey);
      } catch (_) {}
      onUnauthorized?.call();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
