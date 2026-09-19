import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';

import '../support/harness.dart';

void main() {
  late Harness h;

  setUp(() => h = Harness());

  group('error mapping through the full chain', () {
    test('validation errors carry the server messages', () async {
      h.adapter.on(
        'POST',
        '/products',
        (_) => const FakeResponse.json({
          'message': ['images must be an array'],
        }, status: 400),
      );

      final failure = await h.failureOf(() => h.dio.post<Object?>('/products'));

      expect(
        failure,
        const ValidationFailure(messages: ['images must be an array']),
      );
    });

    test('server errors keep their status code', () async {
      h.adapter.on('POST', '/products', (_) => const FakeResponse.status(500));

      final failure = await h.failureOf(() => h.dio.post<Object?>('/products'));

      expect(failure, const ServerFailure(statusCode: 500));
    });

    test('no connection becomes a NetworkFailure', () async {
      h.adapter.on(
        'POST',
        '/products',
        (_) => const FakeResponse.failure(DioExceptionType.connectionError),
      );

      final failure = await h.failureOf(() => h.dio.post<Object?>('/products'));

      expect(failure, const NetworkFailure());
    });
  });

  group('logging', () {
    test('logs method, path and status but never tokens or bodies', () async {
      h.adapter.on(
        'POST',
        '/auth/login',
        (_) => const FakeResponse.json({'access_token': 'SECRET-TOKEN'}),
      );

      await h.dio.post<Object?>('/auth/login', data: {'password': 'hunter2'});

      final log = h.logger.messages.join('\n');
      expect(log, contains('--> POST /auth/login'));
      expect(log, contains('<-- 200 POST /auth/login'));
      expect(log, isNot(contains('Bearer')));
      expect(log, isNot(contains('hunter2')));
      expect(log, isNot(contains('SECRET-TOKEN')));
    });
  });

  group('bare client', () {
    test('never authenticates or refreshes', () async {
      final adapter = FakeHttpClientAdapter()
        ..on(
          'POST',
          '/auth/refresh-token',
          (_) => const FakeResponse.status(401),
        );
      final bare = ApiClient.createBare(
        config: const ApiConfig(baseUrl: 'https://test.local/api'),
        logger: h.logger,
        adapter: adapter,
      );

      Failure? failure;
      try {
        await bare.post<Object?>('/auth/refresh-token');
      } on DioException catch (e) {
        failure = e.error as Failure?;
      }

      expect(failure, const UnauthorizedFailure());
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(adapter.requests, hasLength(1));
    });
  });
}
