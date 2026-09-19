import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import '../support/harness.dart';

void main() {
  late Harness h;

  setUp(() => h = Harness());

  const timeout = FakeResponse.failure(DioExceptionType.receiveTimeout);
  const ok = FakeResponse.json({'ok': true});

  test('retries a GET that times out, with exponential backoff', () async {
    h.adapter.onSequence('GET', '/x', [timeout, timeout, ok]);

    final response = await h.dio.get<Object?>('/x');

    expect(response.statusCode, 200);
    expect(h.adapter.count('GET', '/x'), 3);
    expect(h.retryDelays, [
      const Duration(milliseconds: 300),
      const Duration(milliseconds: 600),
    ]);
  });

  test('gives up after the retry budget and reports a timeout', () async {
    h.adapter.on('GET', '/x', (_) => timeout);

    final failure = await h.failureOf(() => h.dio.get<Object?>('/x'));

    expect(failure, const TimeoutFailure());
    expect(h.adapter.count('GET', '/x'), 3, reason: '1 try + 2 retries');
  });

  test('retries transient server statuses', () async {
    h.adapter.onSequence('GET', '/x', [const FakeResponse.status(503), ok]);

    final response = await h.dio.get<Object?>('/x');

    expect(response.statusCode, 200);
    expect(h.adapter.count('GET', '/x'), 2);
  });

  test('does not retry client errors', () async {
    h.adapter.on('GET', '/x', (_) => const FakeResponse.status(404));

    await h.failureOf(() => h.dio.get<Object?>('/x'));

    expect(h.adapter.count('GET', '/x'), 1);
  });

  for (final method in ['POST', 'PUT', 'DELETE']) {
    test('never retries $method', () async {
      h.adapter.on(method, '/x', (_) => timeout);

      final failure = await h.failureOf(
        () => h.dio.request<Object?>('/x', options: Options(method: method)),
      );

      expect(failure, const TimeoutFailure());
      expect(h.adapter.count(method, '/x'), 1);
      expect(h.retryDelays, isEmpty);
    });
  }

  test('a dropped connection is retried like a timeout', () async {
    h.adapter.onSequence('GET', '/x', [
      const FakeResponse.failure(DioExceptionType.connectionError),
      ok,
    ]);

    final response = await h.dio.get<Object?>('/x');

    expect(response.statusCode, 200);
  });
}
