import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

void main() {
  DioException exception(
    DioExceptionType type, {
    int? status,
    Object? data,
    Object? error,
  }) {
    final request = RequestOptions(path: '/x');
    return DioException(
      requestOptions: request,
      type: type,
      error: error,
      response: status == null
          ? null
          : Response<Object?>(
              requestOptions: request,
              statusCode: status,
              data: data,
            ),
    );
  }

  final cases = <String, (DioException, Failure)>{
    'connect timeout': (
      exception(DioExceptionType.connectionTimeout),
      const TimeoutFailure(),
    ),
    'send timeout': (
      exception(DioExceptionType.sendTimeout),
      const TimeoutFailure(),
    ),
    'receive timeout': (
      exception(DioExceptionType.receiveTimeout),
      const TimeoutFailure(),
    ),
    'connection error': (
      exception(DioExceptionType.connectionError),
      const NetworkFailure(),
    ),
    'bad certificate': (
      exception(DioExceptionType.badCertificate),
      const NetworkFailure(),
    ),
    '401': (
      exception(DioExceptionType.badResponse, status: 401),
      const UnauthorizedFailure(),
    ),
    '403': (
      exception(DioExceptionType.badResponse, status: 403),
      const UnauthorizedFailure(),
    ),
    '400 with a message list': (
      exception(
        DioExceptionType.badResponse,
        status: 400,
        data: {
          'message': ['price must be positive', 'images must be URLs'],
        },
      ),
      const ValidationFailure(
        messages: ['price must be positive', 'images must be URLs'],
      ),
    ),
    '400 with a single message': (
      exception(
        DioExceptionType.badResponse,
        status: 400,
        data: {'message': 'Not found'},
      ),
      const ValidationFailure(messages: ['Not found']),
    ),
    '400 without a body': (
      exception(DioExceptionType.badResponse, status: 400),
      const ValidationFailure(),
    ),
    '500 with a message': (
      exception(
        DioExceptionType.badResponse,
        status: 500,
        data: {'message': 'boom'},
      ),
      const ServerFailure(statusCode: 500, message: 'boom'),
    ),
    '503 with a non-JSON body': (
      exception(DioExceptionType.badResponse, status: 503, data: '<html/>'),
      const ServerFailure(statusCode: 503),
    ),
  };

  cases.forEach((name, testCase) {
    test('maps $name', () {
      final (input, expected) = testCase;
      expect(mapDioException(input), expected);
    });
  });

  test('keeps a Failure that is already attached', () {
    const attached = NetworkFailure();
    final input = exception(DioExceptionType.unknown, error: attached);
    expect(mapDioException(input), same(attached));
  });

  test('unknown errors keep their cause', () {
    final cause = StateError('x');
    final failure = mapDioException(
      exception(DioExceptionType.unknown, error: cause),
    );
    expect(failure, UnknownFailure(cause: cause));
  });
}
