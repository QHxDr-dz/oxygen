import 'dart:math' as math;

import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/logger.dart';

/// Automatically retries failed requests on network errors.
/// Does NOT retry on 4xx client errors.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor(this._dio, {this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = err.requestOptions.extra['_retryCount'] as int? ?? 0;

    final shouldRetry = _isRetryable(err) && attempt < maxRetries;

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    // Exponential backoff with jitter avoids thundering-herd retries.
    final baseMs = 400 * math.pow(2, nextAttempt - 1);
    final jitterMs = math.Random().nextInt(200);
    final delay = Duration(milliseconds: baseMs.toInt() + jitterMs);

    AppLogger.warning(
      'RetryInterceptor: attempt $nextAttempt/$maxRetries after ${delay.inMilliseconds}ms',
      tag: 'Retry',
    );

    await Future.delayed(delay);

    try {
      final options = err.requestOptions;
      options.extra['_retryCount'] = nextAttempt;
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.reject(retryErr);
    }
  }

  bool _isRetryable(DioException err) {
    // Only retry operations that are safe to repeat. Retrying POSTs can create
    // duplicate workout sessions / set completions when the server committed
    // the write but the response was lost.
    final method = err.requestOptions.method.toUpperCase();
    const idempotentMethods = {'GET', 'HEAD', 'OPTIONS'};
    if (!idempotentMethods.contains(method)) return false;

    final path = err.requestOptions.path;
    if (path == ApiConstants.login || path == ApiConstants.register) {
      return false;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        // Retry on 5xx only
        return status >= 500;
      default:
        return false;
    }
  }
}
