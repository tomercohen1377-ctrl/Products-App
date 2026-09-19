import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:network/src/config/api_extras.dart';

/// Retries **idempotent GETs** that failed for a transient reason (timeouts,
/// connection errors, 502/503/504) with capped exponential backoff.
///
/// POST/PUT/DELETE are never retried automatically: replaying them could
/// duplicate a create or repeat a destructive action.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 3),
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final Future<void> Function(Duration) _delay;

  static const _transientStatuses = {502, 503, 504};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[ApiExtras.retryCount] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    await _delay(_backoff(attempt));
    options.extra[ApiExtras.retryCount] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.reject(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => _transientStatuses.contains(
        err.response?.statusCode,
      ),
      _ => false,
    };
  }

  Duration _backoff(int attempt) {
    final millis = baseDelay.inMilliseconds * math.pow(2, attempt).toInt();
    return Duration(milliseconds: math.min(millis, maxDelay.inMilliseconds));
  }
}
