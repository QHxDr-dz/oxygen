import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/core/network/api_exception.dart';
import 'package:oxygenclub/core/network/interceptors/auth_interceptor.dart';
import 'package:oxygenclub/core/network/interceptors/retry_interceptor.dart';
import 'package:oxygenclub/core/storage/secure_storage.dart';

class _FakeSecureStorage extends SecureStorage {
  int deleteCallCount = 0;

  @override
  Future<String?> read(String key) async => 'test-token';

  @override
  Future<void> delete(String key) async {
    deleteCallCount++;
  }
}

class _StatusAdapter implements HttpClientAdapter {
  final int statusCode;

  const _StatusAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      statusCode,
      statusMessage: 'Test status',
      headers: const {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FailingAdapter implements HttpClientAdapter {
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'offline',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthInterceptor', () {
    test('401 on a protected endpoint emits an unauthorized event', () async {
      final storage = _FakeSecureStorage();
      var unauthorizedEvents = 0;
      final dio = Dio()..httpClientAdapter = const _StatusAdapter(401);
      dio.interceptors.add(
        AuthInterceptor(storage, onUnauthorized: () => unauthorizedEvents++),
      );

      try {
        await dio.get('/me');
        fail('Expected a DioException');
      } on DioException catch (error) {
        expect(error.error, isA<UnauthorizedException>());
      }

      expect(unauthorizedEvents, 1);
      expect(storage.deleteCallCount, 1);
    });

    test(
      '401 from login is treated as bad credentials, not session expiry',
      () async {
        final storage = _FakeSecureStorage();
        var unauthorizedEvents = 0;
        final dio = Dio()..httpClientAdapter = const _StatusAdapter(401);
        dio.interceptors.add(
          AuthInterceptor(storage, onUnauthorized: () => unauthorizedEvents++),
        );

        await expectLater(dio.post('/login'), throwsA(isA<DioException>()));

        expect(unauthorizedEvents, 0);
        expect(storage.deleteCallCount, 0);
      },
    );
  });

  group('RetryInterceptor', () {
    test('does not retry a failed write request', () async {
      final adapter = _FailingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      dio.interceptors.add(RetryInterceptor(dio, maxRetries: 3));

      await expectLater(
        dio.post('/workouts/1/start'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.callCount, 1);
    });
  });
}
