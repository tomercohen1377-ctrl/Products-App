import 'dart:async';

import 'package:core/core.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';

class SilentLogger implements AppLogger {
  final List<String> messages = [];

  @override
  void debug(String message) => messages.add(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      messages.add(message);
}

class InMemoryTokens implements TokenProvider {
  InMemoryTokens(this.value);

  String? value;

  @override
  Future<String?> accessToken() async => value;
}

/// Refresher whose outcome is scripted. On [Refreshed] it stores `newToken`.
class ScriptedRefresher implements SessionRefresher {
  ScriptedRefresher(this._tokens);

  final InMemoryTokens _tokens;
  RefreshResult result = const Refreshed();
  String newToken = 'new';
  int calls = 0;

  /// When set, `refresh()` waits for it, so tests can pile up concurrent 401s.
  Completer<void>? gate;

  @override
  Future<RefreshResult> refresh() async {
    calls++;
    await gate?.future;
    if (result is Refreshed) _tokens.value = newToken;
    return result;
  }
}

/// A fully wired client over a [FakeHttpClientAdapter].
class Harness {
  Harness({String? token = 'old'}) : tokens = InMemoryTokens(token) {
    refresher = ScriptedRefresher(tokens);
    dio = ApiClient.create(
      config: const ApiConfig(baseUrl: 'https://test.local/api'),
      tokenProvider: tokens,
      refresher: refresher,
      onSessionExpired: () => sessionExpiredCount++,
      logger: logger,
      adapter: adapter,
      retryDelay: (delay) async => retryDelays.add(delay),
    );
  }

  final FakeHttpClientAdapter adapter = FakeHttpClientAdapter();
  final SilentLogger logger = SilentLogger();
  final InMemoryTokens tokens;
  late final ScriptedRefresher refresher;
  late final Dio dio;
  int sessionExpiredCount = 0;
  final List<Duration> retryDelays = [];

  /// A protected endpoint that only accepts `Bearer new`.
  void protect(String path, {Object? body = const {'ok': true}}) {
    adapter.on('GET', path, (options) {
      final authorized = options.headers['Authorization'] == 'Bearer new';
      return authorized
          ? FakeResponse.json(body)
          : const FakeResponse.status(401);
    });
  }

  /// Runs [request] and returns the `Failure` it fails with.
  Future<Failure> failureOf(Future<Object?> Function() request) async {
    try {
      await request();
    } on DioException catch (error) {
      return error.error! as Failure;
    }
    throw StateError('Expected the request to fail');
  }
}
