import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:network/src/auth/session_contracts.dart';
import 'package:network/src/config/api_config.dart';
import 'package:network/src/interceptors/auth_interceptor.dart';
import 'package:network/src/interceptors/error_mapping_interceptor.dart';
import 'package:network/src/interceptors/log_interceptor.dart';
import 'package:network/src/interceptors/retry_interceptor.dart';

/// Builds the app's two Dio clients.
abstract final class ApiClient {
  /// The main client: logs, authenticates (with transparent refresh), retries
  /// idempotent GETs, and maps every error to a typed `Failure`.
  static Dio create({
    required ApiConfig config,
    required TokenProvider tokenProvider,
    required SessionRefresher refresher,
    required void Function() onSessionExpired,
    required AppLogger logger,
    HttpClientAdapter? adapter,
    Future<void> Function(Duration)? retryDelay,
  }) {
    final dio = _baseDio(config, adapter);
    dio.interceptors.addAll([
      ApiLogInterceptor(logger),
      AuthInterceptor(
        dio: dio,
        tokenProvider: tokenProvider,
        refresher: refresher,
        onSessionExpired: onSessionExpired,
      ),
      RetryInterceptor(dio: dio, delay: retryDelay),
      ErrorMappingInterceptor(),
    ]);
    return dio;
  }

  /// A client with no auth and no retry, used only for `POST /auth/refresh-token`
  /// so refreshing can never recurse into the auth interceptor.
  static Dio createBare({
    required ApiConfig config,
    required AppLogger logger,
    HttpClientAdapter? adapter,
  }) {
    final dio = _baseDio(config, adapter);
    dio.interceptors.addAll([
      ApiLogInterceptor(logger),
      ErrorMappingInterceptor(),
    ]);
    return dio;
  }

  static Dio _baseDio(ApiConfig config, HttpClientAdapter? adapter) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        sendTimeout: config.sendTimeout,
        receiveTimeout: config.receiveTimeout,
        contentType: Headers.jsonContentType,
        headers: {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );
    if (adapter != null) dio.httpClientAdapter = adapter;
    return dio;
  }
}
