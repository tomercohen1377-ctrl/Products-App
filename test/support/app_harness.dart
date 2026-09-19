import 'package:auth/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mylo_products/app/app.dart';
import 'package:mylo_products/app/bootstrap.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';

/// The whole app (real bootstrap, router, blocs, interceptors) over an
/// in-memory keystore and a scripted transport.
class AppHarness {
  AppHarness({bool signedIn = false, this.devTools = false})
    : storage = InMemoryTokenStorage(signedIn ? authTokensFixture : null) {
    adapter
      ..on(
        'POST',
        '/auth/login',
        (_) => const FakeResponse.json({
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
        }),
      )
      ..on(
        'POST',
        '/auth/refresh-token',
        (_) => const FakeResponse.status(401),
      );
    acceptToken('access-1');
  }

  final InMemoryTokenStorage storage;
  final FakeHttpClientAdapter adapter = FakeHttpClientAdapter();
  final bool devTools;
  GetIt? _getIt;

  static const user = {
    'id': 1,
    'email': 'john@mail.com',
    'name': 'John',
    'avatar': '',
  };

  /// `GET /auth/profile` succeeds only with [token].
  void acceptToken(String token) {
    adapter.on('GET', '/auth/profile', (options) {
      return options.headers['Authorization'] == 'Bearer $token'
          ? const FakeResponse.json(user)
          : const FakeResponse.status(401);
    });
  }

  Widget build() {
    _getIt = bootstrap(
      config: const ApiConfig(baseUrl: 'https://test.local/api'),
      devTools: devTools,
      storage: storage,
      adapter: adapter,
    );
    return MyloApp(getIt: _getIt!, devTools: devTools);
  }

  Future<void> launch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(build());
    await tester.settle();
  }
}

extension AppTester on WidgetTester {
  /// Runs real event-loop turns (bloc pipelines, async I/O fakes) and the
  /// frames they trigger.
  Future<void> settle() async {
    await runAsync(() => pumpEventQueue());
    await pump();
    await pump(const Duration(milliseconds: 100));
    await pumpAndSettle();
  }
}
