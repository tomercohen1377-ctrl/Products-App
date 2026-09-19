import 'package:auth/testing.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import '../support/auth_harness.dart';

/// End-to-end proof of the refresh path: the real interceptors, token store,
/// refresher and repository over a scripted transport. This is the automated
/// counterpart of the "Expire access token" dev tool.
void main() {
  const refreshPath = '/auth/refresh-token';

  test('an expired access token is refreshed and the call replayed', () async {
    final h = AuthHarness();
    h.profileAccepts('access-2');
    h.adapter.on(
      'POST',
      refreshPath,
      (_) => const FakeResponse.json(AuthHarness.refreshedTokens),
    );

    final result = await h.repository.currentUser();

    expect(result.valueOrNull?.email, 'john@mail.com');
    expect(h.adapter.requests.map((r) => '${r.method} ${r.path}').toList(), [
      'GET /auth/profile',
      'POST $refreshPath',
      'GET /auth/profile',
    ]);
    expect(
      h.adapter.requests.first.headers['Authorization'],
      'Bearer access-1',
    );
    expect(h.adapter.requests[1].headers.containsKey('Authorization'), isFalse);
    expect(h.adapter.requests[1].data, {'refreshToken': 'refresh-1'});
    expect(h.adapter.requests.last.headers['Authorization'], 'Bearer access-2');
    expect(h.storage.tokens?.refreshToken, 'refresh-2');
    expect(h.expiredCount, 0);
  });

  test('concurrent calls with an expired token trigger one refresh', () async {
    final h = AuthHarness();
    h.profileAccepts('access-2');
    h.adapter.on(
      'POST',
      refreshPath,
      (_) => const FakeResponse.json(AuthHarness.refreshedTokens),
    );

    final results = await Future.wait([
      h.repository.currentUser(),
      h.repository.currentUser(),
      h.repository.currentUser(),
    ]);

    expect(results.every((r) => r.isSuccess), isTrue);
    expect(h.adapter.count('POST', refreshPath), 1);
  });

  test(
    'a dead session logs out cleanly: cleared once, event fired once',
    () async {
      final h = AuthHarness();
      h.profileAccepts('access-2');
      h.adapter.on('POST', refreshPath, (_) => const FakeResponse.status(401));

      final result = await h.repository.currentUser();
      await pumpEventQueue();

      expect(result.failureOrNull, const UnauthorizedFailure());
      expect(h.storage.tokens, isNull);
      expect(await h.repository.hasSession(), isFalse);
      expect(h.expiredCount, 1);
      expect(h.adapter.count('GET', '/auth/profile'), 1, reason: 'no replay');
    },
  );

  test('being offline during refresh keeps the session', () async {
    final h = AuthHarness();
    h.profileAccepts('access-2');
    h.adapter.on('POST', refreshPath, (_) => const FakeResponse.offline());

    final result = await h.repository.currentUser();
    await pumpEventQueue();

    expect(result.failureOrNull, const NetworkFailure());
    expect(h.storage.tokens, authTokensFixture);
    expect(h.expiredCount, 0);
  });

  test('after the session dies, later calls do not keep refreshing', () async {
    final h = AuthHarness();
    h.profileAccepts('access-2');
    h.adapter.on('POST', refreshPath, (_) => const FakeResponse.status(401));

    await h.repository.currentUser();
    await h.repository.currentUser();

    expect(
      h.adapter.count('POST', refreshPath),
      1,
      reason: 'second call has no tokens, so there is nothing to refresh',
    );
  });
}
