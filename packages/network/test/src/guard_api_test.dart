import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

void main() {
  test('wraps a value in Success', () async {
    expect(await guardApi(() async => 3), const Success<int>(3));
  });

  test('maps a DioException to its Failure', () async {
    final result = await guardApi<int>(
      () async => throw DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(result, const Failed<int>(TimeoutFailure()));
  });

  test('treats a malformed payload as an unknown failure', () async {
    final format = await guardApi<int>(
      () async => throw const FormatException('bad'),
    );
    expect(format.failureOrNull, isA<UnknownFailure>());

    final cast = await guardApi<String>(() async => (1 as dynamic) as String);
    expect(cast.failureOrNull, isA<UnknownFailure>());
  });

  test('does not swallow programming errors', () async {
    await expectLater(
      guardApi<int>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
