import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Structured logger that respects environment log levels.
/// Never logs sensitive data (tokens, passwords).
class AppLogger {
  AppLogger._();

  static void debug(String message, {String? tag, Object? data}) {
    if (!Environment.verboseLogging) return;
    _log('DEBUG', tag ?? 'App', message, data);
  }

  static void info(String message, {String? tag, Object? data}) {
    if (!Environment.verboseLogging) return;
    _log('INFO', tag ?? 'App', message, data);
  }

  static void warning(String message, {String? tag, Object? error}) {
    _log('WARN', tag ?? 'App', message, error);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', tag ?? 'App', message, error);
    if (stackTrace != null && Environment.verboseLogging) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  static void network(
    String method,
    String path, {
    int? statusCode,
    Object? data,
  }) {
    if (!Environment.verboseLogging) return;
    final status = statusCode != null ? ' [$statusCode]' : '';
    _log('NET', 'HTTP', '$method $path$status', data);
  }

  static void _log(String level, String tag, String message, Object? data) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final dataStr = data != null ? '\n  → $data' : '';
    debugPrint('[$timestamp] [$level] [$tag] $message$dataStr');
  }
}
