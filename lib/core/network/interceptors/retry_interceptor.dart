import 'package:dio/dio.dart';
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
    final delay = Duration(milliseconds: 500 * nextAttempt);

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
      handler.next(retryErr);
    }
  }

  bool _isRetryable(DioException err) {
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
