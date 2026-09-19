import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Converts a [DioException] into the app's typed [Failure].
Failure mapDioException(DioException exception) {
  final error = exception.error;
  if (error is Failure) return error;

  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const TimeoutFailure(),
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate => const NetworkFailure(),
    DioExceptionType.badResponse => _fromResponse(exception.response),
    DioExceptionType.cancel ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.unknown => UnknownFailure(cause: error ?? exception),
  };
}

Failure _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;
  final messages = _messagesFrom(response?.data);
  return switch (status) {
    401 || 403 => const UnauthorizedFailure(),
    400 || 422 => ValidationFailure(messages: messages),
    _ => ServerFailure(
      statusCode: status,
      message: messages.isEmpty ? null : messages.join('\n'),
    ),
  };
}

/// The API reports errors as `{"message": "..."}` or `{"message": ["...", ...]}`.
List<String> _messagesFrom(Object? data) {
  if (data is! Map<String, dynamic>) return const [];
  return switch (data['message']) {
    final String message => [message],
    final List<dynamic> messages => messages.whereType<String>().toList(),
    _ => const [],
  };
}
