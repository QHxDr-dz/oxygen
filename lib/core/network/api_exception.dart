/// Typed exception hierarchy for the Oxygen Club domain.
/// Repositories catch raw exceptions and convert them to these typed failures.
/// UI never sees raw exceptions.
library;

/// Base class for all domain exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => '$runtimeType: $message (status: $statusCode)';
}

/// No internet connection or DNS failure.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
    super.originalError,
  });
}

/// 401 — token expired or invalid. Triggers automatic logout.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
    super.originalError,
  });
}

/// 422 — server-side validation errors.
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    super.message = 'Please check the form and try again.',
    super.statusCode = 422,
    super.originalError,
    this.errors = const {},
  });
}

/// 404 — resource not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested data was not found.',
    super.statusCode = 404,
    super.originalError,
  });
}

/// 5xx — server-side error.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error. Please try again later.',
    super.statusCode,
    super.originalError,
  });
}

/// Request timed out.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Connection timed out. Please try again.',
    super.statusCode,
    super.originalError,
  });
}

/// Local cache read/write failure.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Data not available offline.',
    super.statusCode,
    super.originalError,
  });
}

/// Catch-all for unexpected errors.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Something went wrong. Please try again.',
    super.statusCode,
    super.originalError,
  });
}
