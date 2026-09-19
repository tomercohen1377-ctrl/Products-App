import 'package:auth/src/data/repositories/auth_repository_impl.dart';
import 'package:auth/src/data/repositories/token_refresher.dart';
import 'package:auth/src/data/sources/auth_remote_source.dart';
import 'package:auth/src/data/sources/refresh_remote_source.dart';
import 'package:auth/src/data/storage/secure_token_storage.dart';
import 'package:auth/src/data/storage/token_storage.dart';
import 'package:auth/src/data/storage/token_store.dart';
import 'package:auth/src/debug/auth_debug_tools.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/domain/session_events.dart';
import 'package:auth/src/domain/use_cases/restore_session.dart';
import 'package:auth/src/presentation/login/login_bloc.dart';
import 'package:auth/src/presentation/session/session_bloc.dart';
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:network/network.dart';

/// Registers everything the auth feature owns, including the app's
/// authenticated [Dio] client (which other features resolve).
///
/// [storage] and [adapter] exist so tests can run the real stack in memory.
void registerAuthModule(
  GetIt getIt, {
  required ApiConfig config,
  LoginPrefill? loginPrefill,
  TokenStorage? storage,
  HttpClientAdapter? adapter,
}) {
  getIt
    ..registerLazySingleton<TokenStorage>(() => storage ?? SecureTokenStorage())
    ..registerLazySingleton(() => TokenStore(getIt()))
    ..registerLazySingleton(SessionEvents.new, dispose: (e) => e.dispose())
    ..registerLazySingleton<Dio>(() {
      final logger = getIt<AppLogger>();
      final refresher = TokenRefresher(
        RefreshRemoteSource(
          ApiClient.createBare(
            config: config,
            logger: logger,
            adapter: adapter,
          ),
        ),
        getIt(),
      );
      return ApiClient.create(
        config: config,
        tokenProvider: getIt<TokenStore>(),
        refresher: refresher,
        onSessionExpired: getIt<SessionEvents>().notifyExpired,
        logger: logger,
        adapter: adapter,
      );
    })
    ..registerLazySingleton(() => AuthRemoteSource(getIt()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerFactory(() => RestoreSession(getIt()))
    ..registerFactory(
      () => SessionBloc(
        restoreSession: getIt(),
        repository: getIt(),
        events: getIt(),
      ),
    )
    ..registerFactory(() => LoginBloc(getIt(), prefill: loginPrefill))
    ..registerLazySingleton(() => AuthDebugTools(getIt(), getIt()));
}
