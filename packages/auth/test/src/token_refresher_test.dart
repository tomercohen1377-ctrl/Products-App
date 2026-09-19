import 'package:auth/testing.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';

import '../support/auth_harness.dart';

void main() {
  const refreshPath = '/auth/refresh-token';

  test('exchanges the refresh token and stores the new pair', () async {
    final h = AuthHarness();
    h.adapter.on(
      'POST',
      refreshPath,
      (_) => const FakeResponse.json(AuthHarness.refreshedTokens),
    );

    final result = await h.refresher.refresh();

    expect(result, isA<Refreshed>());
    expect(h.storage.tokens?.accessToken, 'access-2');
    expect(h.storage.tokens?.refreshToken, 'refresh-2');

    final request = h.adapter.requestsTo('POST', refreshPath).single;
    expect(request.data, {'refreshToken': 'refresh-1'});
    expect(request.headers.containsKey('Authorization'), isFalse);
  });

  for (final status in [400, 401, 403]) {
    test(
      'a $status from the server rejects the session and clears it',
      () async {
        final h = AuthHarness();
        h.adapter.on('POST', refreshPath, (_) => FakeResponse.status(status));

        final result = await h.refresher.refresh();

        expect(result, isA<SessionRejected>());
        expect(h.storage.tokens, isNull);
      },
    );
  }

  test('no connection keeps the session and reports unavailable', () async {
    final h = AuthHarness();
    h.adapter.on('POST', refreshPath, (_) => const FakeResponse.offline());

    final result = await h.refresher.refresh();

    expect(result, isA<RefreshUnavailable>());
    expect((result as RefreshUnavailable).failure, const NetworkFailure());
    expect(h.storage.tokens, authTokensFixture);
  });

  test('a server error keeps the session', () async {
    final h = AuthHarness();
    h.adapter.on('POST', refreshPath, (_) => const FakeResponse.status(500));

    final result = await h.refresher.refresh();

    expect(result, isA<RefreshUnavailable>());
    expect(h.storage.tokens, authTokensFixture);
  });

  test('with no stored tokens there is nothing to refresh', () async {
    final h = AuthHarness(tokens: null);

    final result = await h.refresher.refresh();

    expect(result, isA<SessionRejected>());
    expect(h.adapter.requests, isEmpty);
  });
}
