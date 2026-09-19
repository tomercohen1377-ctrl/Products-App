import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:network/src/auth/session_contracts.dart';
import 'package:network/src/config/api_extras.dart';

/// Authenticates requests and recovers transparently from a rejected token.
///
/// On a 401 it refreshes the session **once** (concurrent 401s share a single
/// in-flight refresh), then replays the original request **once**. A request
/// that was sent with an already-superseded token is replayed with the current
/// one without refreshing again. If the server definitively rejects the
/// refresh, [onSessionExpired] fires; a transient refresh failure surfaces
/// that failure and leaves the session alone.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this._tokenProvider,
    required this._refresher,
    required this._onSessionExpired,
  });

  final Dio _dio;
  final TokenProvider _tokenProvider;
  final SessionRefresher _refresher;
  final void Function() _onSessionExpired;

  Future<RefreshResult>? _inFlightRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_requiresAuth(options)) {
      final token = await _tokenProvider.accessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isRecoverable =
        err.response?.statusCode == 401 &&
        _requiresAuth(options) &&
        options.extra[ApiExtras.retriedAfterRefresh] != true;
    if (!isRecoverable) return handler.next(err);

    final current = await _tokenProvider.accessToken();
    final sentWith = options.headers['Authorization'];
    final alreadyRefreshed = current != null && sentWith != 'Bearer $current';

    final result = alreadyRefreshed ? const Refreshed() : await _refreshOnce();

    switch (result) {
      case Refreshed():
        await _replay(options, handler);
      case SessionRejected():
        _onSessionExpired();
        handler.next(err);
      case RefreshUnavailable(:final failure):
        handler.reject(err.copyWith(error: failure));
    }
  }

  bool _requiresAuth(RequestOptions options) =>
      options.extra[ApiExtras.auth] != false;

  Future<RefreshResult> _refreshOnce() => _inFlightRefresh ??= _runRefresh()
      .whenComplete(() => _inFlightRefresh = null);

  Future<RefreshResult> _runRefresh() async {
    try {
      return await _refresher.refresh();
    } on Exception catch (exception) {
      return RefreshUnavailable(UnknownFailure(cause: exception));
    }
  }

  Future<void> _replay(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    final data = options.data;
    final replay = options.copyWith(
      data: data is FormData ? data.clone() : data,
      extra: {...options.extra, ApiExtras.retriedAfterRefresh: true},
    );
    try {
      handler.resolve(await _dio.fetch<dynamic>(replay));
    } on DioException catch (error) {
      handler.reject(error);
    }
  }
}
