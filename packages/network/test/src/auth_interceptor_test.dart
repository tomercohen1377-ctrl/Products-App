import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';

import '../support/harness.dart';

void main() {
  late Harness h;

  setUp(() => h = Harness());

  group('attaching the token', () {
    test('adds the Bearer header to protected requests', () async {
      h.adapter.on('GET', '/products', (_) => const FakeResponse.json([]));
      await h.dio.get<Object?>('/products');

      expect(h.adapter.requests.single.headers['Authorization'], 'Bearer old');
    });

    test('leaves requests without a header when there is no token', () async {
      final noToken = Harness(token: null);
      noToken.adapter.on(
        'GET',
        '/products',
        (_) => const FakeResponse.json([]),
      );
      await noToken.dio.get<Object?>('/products');

      expect(
        noToken.adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('never sends a token on requests that opt out of auth', () async {
      h.adapter.on(
        'POST',
        '/auth/login',
        (_) => const FakeResponse.json({'access_token': 'a'}),
      );
      await h.dio.post<Object?>('/auth/login', options: ApiExtras.noAuth);

      expect(
        h.adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });
  });

  group('recovering from a rejected token', () {
    test('refreshes once and replays the request with the new token', () async {
      h.protect('/products', body: [1, 2]);

      final response = await h.dio.get<Object?>('/products');

      expect(response.data, [1, 2]);
      expect(h.refresher.calls, 1);
      expect(h.adapter.count('GET', '/products'), 2);
      expect(h.adapter.requests.last.headers['Authorization'], 'Bearer new');
      expect(h.sessionExpiredCount, 0);
    });

    test('replays a POST with its original body', () async {
      h.adapter.on('POST', '/products', (o) {
        return o.headers['Authorization'] == 'Bearer new'
            ? const FakeResponse.json({'id': 9}, status: 201)
            : const FakeResponse.status(401);
      });

      final response = await h.dio.post<Object?>(
        '/products',
        data: {'title': 'Hat'},
      );

      expect(response.statusCode, 201);
      expect(h.adapter.requestsTo('POST', '/products').last.data, {
        'title': 'Hat',
      });
    });

    test('concurrent 401s share exactly one refresh', () async {
      h.protect('/products');
      h.refresher.gate = Completer<void>();

      final calls = [
        for (var i = 0; i < 4; i++) h.dio.get<Object?>('/products'),
      ];
      await pumpEventQueue();
      expect(h.refresher.calls, 1, reason: 'all 401s must join one refresh');

      h.refresher.gate!.complete();
      final responses = await Future.wait(calls);

      expect(responses.map((r) => r.statusCode), everyElement(200));
      expect(h.refresher.calls, 1);
    });

    test(
      'a late 401 from a stale token replays without refreshing again',
      () async {
        final lateResponse = Completer<void>();
        h.adapter.on('GET', '/fast', (o) {
          return o.headers['Authorization'] == 'Bearer new'
              ? const FakeResponse.json({'ok': true})
              : const FakeResponse.status(401);
        });
        h.adapter.on('GET', '/slow', (o) async {
          if (o.headers['Authorization'] != 'Bearer new') {
            await lateResponse.future;
            return const FakeResponse.status(401);
          }
          return const FakeResponse.json({'ok': true});
        });

        final slow = h.dio.get<Object?>('/slow');
        final fast = h.dio.get<Object?>('/fast');
        await fast;
        expect(h.refresher.calls, 1);

        lateResponse.complete();
        final slowResponse = await slow;

        expect(slowResponse.statusCode, 200);
        expect(h.refresher.calls, 1, reason: 'token was already refreshed');
      },
    );

    test('does not loop when the refreshed token is also rejected', () async {
      h.adapter.on('GET', '/products', (_) => const FakeResponse.status(401));

      final failure = await h.failureOf(() => h.dio.get<Object?>('/products'));

      expect(failure, const UnauthorizedFailure());
      expect(h.refresher.calls, 1);
      expect(h.adapter.count('GET', '/products'), 2);
    });
  });

  group('when recovery fails', () {
    test('a rejected refresh ends the session once and surfaces 401', () async {
      h.protect('/products');
      h.refresher.result = const SessionRejected();

      final failure = await h.failureOf(() => h.dio.get<Object?>('/products'));

      expect(failure, const UnauthorizedFailure());
      expect(h.sessionExpiredCount, 1);
      expect(h.adapter.count('GET', '/products'), 1, reason: 'no replay');
    });

    test('a transient refresh failure keeps the session', () async {
      h.protect('/products');
      h.refresher.result = const RefreshUnavailable(NetworkFailure());

      final failure = await h.failureOf(() => h.dio.get<Object?>('/products'));

      expect(failure, const NetworkFailure());
      expect(h.sessionExpiredCount, 0);
    });

    test('a refresher that throws is treated as transient', () async {
      h.protect('/products');
      final throwing = _ThrowingRefresher();
      final dio = ApiClient.create(
        config: const ApiConfig(baseUrl: 'https://test.local/api'),
        tokenProvider: h.tokens,
        refresher: throwing,
        onSessionExpired: () => h.sessionExpiredCount++,
        logger: h.logger,
        adapter: h.adapter,
      );

      Failure? failure;
      try {
        await dio.get<Object?>('/products');
      } on DioException catch (e) {
        failure = e.error as Failure?;
      }

      expect(failure, isA<UnknownFailure>());
      expect(h.sessionExpiredCount, 0);
    });
  });

  test('non-401 errors are left alone', () async {
    h.adapter.on('GET', '/products', (_) => const FakeResponse.status(404));

    final failure = await h.failureOf(() => h.dio.get<Object?>('/products'));

    expect(failure, isA<ServerFailure>());
    expect(h.refresher.calls, 0);
  });

  test('a 401 on a request that opted out of auth does not refresh', () async {
    h.adapter.on('POST', '/auth/login', (_) => const FakeResponse.status(401));

    final failure = await h.failureOf(
      () => h.dio.post<Object?>('/auth/login', options: ApiExtras.noAuth),
    );

    expect(failure, const UnauthorizedFailure());
    expect(h.refresher.calls, 0);
    expect(h.sessionExpiredCount, 0);
  });
}

class _ThrowingRefresher implements SessionRefresher {
  @override
  Future<RefreshResult> refresh() async => throw StateError('boom');
}
