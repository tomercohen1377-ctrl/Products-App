import 'package:auth/src/data/repositories/auth_repository_impl.dart';
import 'package:auth/src/data/repositories/token_refresher.dart';
import 'package:auth/src/data/sources/auth_remote_source.dart';
import 'package:auth/src/data/sources/refresh_remote_source.dart';
import 'package:auth/src/data/storage/token_store.dart';
import 'package:auth/src/domain/entities/auth_tokens.dart';
import 'package:auth/src/domain/session_events.dart';
import 'package:auth/testing.dart';
import 'package:core/core.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';

class _SilentLogger implements AppLogger {
  @override
  void debug(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

/// The real auth stack (interceptors, token store, refresher, repository)
/// wired over a [FakeHttpClientAdapter].
class AuthHarness {
  AuthHarness({AuthTokens? tokens = authTokensFixture})
    : storage = InMemoryTokenStorage(tokens) {
    const config = ApiConfig(baseUrl: 'https://test.local/api');
    final logger = _SilentLogger();
    store = TokenStore(storage);
    refresher = TokenRefresher(
      RefreshRemoteSource(
        ApiClient.createBare(config: config, logger: logger, adapter: adapter),
      ),
      store,
    );
    api = ApiClient.create(
      config: config,
      tokenProvider: store,
      refresher: refresher,
      onSessionExpired: events.notifyExpired,
      logger: logger,
      adapter: adapter,
      retryDelay: (_) async {},
    );
    repository = AuthRepositoryImpl(AuthRemoteSource(api), store);
    events.expired.listen((_) => expiredCount++);
  }

  final FakeHttpClientAdapter adapter = FakeHttpClientAdapter();
  final InMemoryTokenStorage storage;
  final SessionEvents events = SessionEvents();
  late final TokenStore store;
  late final TokenRefresher refresher;
  late final Dio api;
  late final AuthRepositoryImpl repository;
  int expiredCount = 0;

  static const userJson = {
    'id': 1,
    'email': 'john@mail.com',
    'name': 'John',
    'role': 'customer',
    'avatar': 'https://i.imgur.com/LDOO4Qs.jpg',
    'password': 'changeme',
  };

  static const refreshedTokens = {
    'access_token': 'access-2',
    'refresh_token': 'refresh-2',
  };

  /// `GET /auth/profile` succeeds only with [validToken].
  void profileAccepts(String validToken) {
    adapter.on('GET', '/auth/profile', (options) {
      return options.headers['Authorization'] == 'Bearer $validToken'
          ? const FakeResponse.json(userJson)
          : const FakeResponse.status(401);
    });
  }
}
