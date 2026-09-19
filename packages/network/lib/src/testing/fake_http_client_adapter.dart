import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// A canned HTTP response, or a transport failure, for [FakeHttpClientAdapter].
class FakeResponse {
  const FakeResponse.json(this.body, {this.status = 200}) : errorType = null;

  const FakeResponse.status(this.status) : body = null, errorType = null;

  /// Fails the request the way Dio would (timeout, no connection, ...).
  const FakeResponse.failure(DioExceptionType this.errorType)
    : body = null,
      status = 0;

  final Object? body;
  final int status;
  final DioExceptionType? errorType;
}

typedef FakeHandler = FutureOr<FakeResponse> Function(RequestOptions options);

/// A scriptable [HttpClientAdapter] so tests exercise the real Dio interceptor
/// chain without a network or a mocking library.
class FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<_Route> _routes = [];

  /// Answers every matching request with [handler]. Later routes win.
  void on(String method, String path, FakeHandler handler) {
    _routes.add(_Route(method.toUpperCase(), path, handler));
  }

  /// Answers matching requests with [responses] in order; the last one repeats.
  void onSequence(String method, String path, List<FakeResponse> responses) {
    var index = 0;
    on(method, path, (_) {
      final response = responses[index];
      if (index < responses.length - 1) index++;
      return response;
    });
  }

  /// Requests received for [method] [path], in arrival order.
  List<RequestOptions> requestsTo(String method, String path) => requests
      .where((r) => r.method.toUpperCase() == method.toUpperCase())
      .where((r) => r.path == path)
      .toList();

  int count(String method, String path) => requestsTo(method, path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = _routes.lastWhere(
      (r) => r.matches(options),
      orElse: () => _Route(
        options.method,
        options.path,
        (_) => const FakeResponse.json({
          'message': 'No fake route registered',
        }, status: 404),
      ),
    );

    final response = await route.handler(options);
    final errorType = response.errorType;
    if (errorType != null) {
      throw DioException(requestOptions: options, type: errorType);
    }
    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Route {
  const _Route(this.method, this.path, this.handler);

  final String method;
  final String path;
  final FakeHandler handler;

  bool matches(RequestOptions options) =>
      options.method.toUpperCase() == method && options.path == path;
}
