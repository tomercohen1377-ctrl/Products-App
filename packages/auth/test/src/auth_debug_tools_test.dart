import 'package:auth/src/debug/auth_debug_tools.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import '../support/auth_harness.dart';

void main() {
  late AuthHarness h;
  late AuthDebugTools tools;

  setUp(() {
    h = AuthHarness();
    tools = AuthDebugTools(h.store, h.repository);
    h.profileAccepts('access-2');
    h.adapter.on(
      'POST',
      '/auth/refresh-token',
      (_) => const FakeResponse.json(AuthHarness.refreshedTokens),
    );
  });

  test('a valid session needs no refresh', () async {
    h.profileAccepts('access-1');

    final ping = await tools.pingProfile();

    expect(ping.succeeded, isTrue);
    expect(ping.tokenRotated, isFalse);
  });

  test(
    '"expire access token" is recovered transparently by the next call',
    () async {
      h.profileAccepts('access-1');
      await tools.expireAccessToken();
      h.profileAccepts('access-2');

      final ping = await tools.pingProfile();

      expect(ping.succeeded, isTrue);
      expect(ping.tokenRotated, isTrue);
      expect(h.adapter.count('POST', '/auth/refresh-token'), 1);
      expect(h.expiredCount, 0);
    },
  );

  test('"kill session" logs out cleanly on the next call', () async {
    h.adapter.on(
      'POST',
      '/auth/refresh-token',
      (_) => const FakeResponse.status(401),
    );
    await tools.killSession();

    final ping = await tools.pingProfile();
    await pumpEventQueue();

    expect(ping.succeeded, isFalse);
    expect(ping.failure, const UnauthorizedFailure());
    expect(h.storage.tokens, isNull);
    expect(h.expiredCount, 1);
  });

  test('do nothing when there is no session', () async {
    final empty = AuthHarness(tokens: null);
    final emptyTools = AuthDebugTools(empty.store, empty.repository);

    await emptyTools.expireAccessToken();
    await emptyTools.killSession();

    expect(empty.storage.tokens, isNull);
  });
}
