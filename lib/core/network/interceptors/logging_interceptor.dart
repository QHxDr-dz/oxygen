import 'package:dio/dio.dart';

import '../../config/environment.dart';
import '../../utils/logger.dart';

/// Logs all HTTP requests and responses.
/// Only active when [Environment.verboseLogging] is true (handled by AppLogger).
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.network(
      options.method,
      options.path,
      data: options.data != null ? '[body present]' : null,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.network(
      response.requestOptions.method,
      response.requestOptions.path,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'HTTP error: ${err.requestOptions.method} ${err.requestOptions.path}',
      tag: 'HTTP',
      error: err.message,
    );
    handler.next(err);
  }
}
