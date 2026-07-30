import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../network/api_exception.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';

/// Configured Dio HTTP client.
/// All features use this single instance via dependency injection.
class DioClient {
  late final Dio _dio;

  DioClient(SecureStorage secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl,
        connectTimeout: Duration(milliseconds: Environment.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: Environment.receiveTimeoutMs),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Order matters: logging → auth → retry
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(secureStorage),
      RetryInterceptor(_dio, maxRetries: Environment.maxRetries),
    ]);
  }

  Dio get dio => _dio;

  // ─── Convenience wrappers ────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {Options? options}) async {
    try {
      return await _dio.delete<T>(path, options: options);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // ─── Exception mapping ───────────────────────────────────────────────────

  AppException _mapException(DioException e) {
    // Already mapped by AuthInterceptor
    if (e.error is AppException) return e.error as AppException;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        final body = e.response?.data;

        if (status == 401) return const UnauthorizedException();
        if (status == 404) return const NotFoundException();
        if (status == 422) {
          final errors = _parseValidationErrors(body);
          final message = _extractMessage(body) ?? 'Validation failed.';
          return ValidationException(message: message, errors: errors);
        }
        if (status >= 500) {
          return ServerException(
            message: _extractMessage(body) ?? 'Server error.',
            statusCode: status,
          );
        }
        return UnknownException(
          message: _extractMessage(body) ?? 'Request failed.',
          statusCode: status,
        );

      default:
        AppLogger.error('Unmapped DioException', error: e);
        return const UnknownException();
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['message'] as String?;
    }
    return null;
  }

  Map<String, List<String>> _parseValidationErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return {};
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return {};
    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, [value.toString()]);
    });
  }
}
