import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:mylo_products/app/dev/dev_tools.dart';
import 'package:network/network.dart';

/// The demo account from the assignment, pre-filled on the login form in dev
/// builds only.
const _devLoginPrefill = LoginPrefill(
  email: 'john@mail.com',
  password: 'changeme',
);

/// Composition root: builds the dependency graph. Each package registers its
/// own module; the app only decides configuration.
///
/// [storage] and [adapter] let tests run the real stack in memory.
GetIt bootstrap({
  ApiConfig config = const ApiConfig(),
  bool devTools = DevTools.enabled,
  TokenStorage? storage,
  HttpClientAdapter? adapter,
}) {
  final getIt = GetIt.asNewInstance()
    ..registerLazySingleton<AppLogger>(() => const DeveloperLogger());

  registerAuthModule(
    getIt,
    config: config,
    loginPrefill: devTools ? _devLoginPrefill : null,
    storage: storage,
    adapter: adapter,
  );
  return getIt;
}
