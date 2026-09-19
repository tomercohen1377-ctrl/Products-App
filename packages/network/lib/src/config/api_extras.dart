import 'package:dio/dio.dart';

/// Keys in `RequestOptions.extra` that steer the interceptors.
abstract final class ApiExtras {
  /// `false` for requests that must not carry a Bearer token (login, refresh).
  static const String auth = 'auth';

  /// Set on a request that was already replayed after a token refresh.
  static const String retriedAfterRefresh = 'retriedAfterRefresh';

  static const String retryCount = 'retryCount';
  static const String startedAt = 'startedAt';

  /// Options for endpoints that are called without a session.
  static Options get noAuth => Options(extra: {auth: false});
}
