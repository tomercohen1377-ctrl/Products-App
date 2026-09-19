import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import '../support/auth_harness.dart';

void main() {
  const loginJson = {'access_token': 'access-9', 'refresh_token': 'refresh-9'};

  group('login', () {
    test('stores the tokens and returns the user', () async {
      final h = AuthHarness(tokens: null);
      h.adapter.on(
        'POST',
        '/auth/login',
        (_) => const FakeResponse.json(loginJson),
      );
      h.profileAccepts('access-9');

      final result = await h.repository.login(
        email: 'john@mail.com',
        password: 'changeme',
      );

      expect(result.valueOrNull?.email, 'john@mail.com');
      expect(h.storage.tokens?.accessToken, 'access-9');

      final request = h.adapter.requestsTo('POST', '/auth/login').single;
      expect(request.data, {'email': 'john@mail.com', 'password': 'changeme'});
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test(
      'bad credentials fail with Unauthorized, store nothing, do not refresh',
      () async {
        final h = AuthHarness(tokens: null);
        h.adapter.on(
          'POST',
          '/auth/login',
          (_) => const FakeResponse.status(401),
        );

        final result = await h.repository.login(email: 'a@b.co', password: 'x');

        expect(result.failureOrNull, const UnauthorizedFailure());
        expect(h.storage.tokens, isNull);
        expect(h.adapter.count('POST', '/auth/refresh-token'), 0);
        expect(h.expiredCount, 0);
      },
    );

    test('a failing profile after login leaves no session behind', () async {
      final h = AuthHarness(tokens: null);
      h.adapter.on(
        'POST',
        '/auth/login',
        (_) => const FakeResponse.json(loginJson),
      );
      h.adapter.on(
        'GET',
        '/auth/profile',
        (_) => const FakeResponse.status(500),
      );

      final result = await h.repository.login(email: 'a@b.co', password: 'x');

      expect(result.failureOrNull, isA<ServerFailure>());
      expect(h.storage.tokens, isNull);
    });

    test('offline surfaces a network failure', () async {
      final h = AuthHarness(tokens: null);
      h.adapter.on('POST', '/auth/login', (_) => const FakeResponse.offline());

      final result = await h.repository.login(email: 'a@b.co', password: 'x');

      expect(result.failureOrNull, const NetworkFailure());
    });
  });

  test('currentUser maps the profile and drops an empty avatar', () async {
    final h = AuthHarness();
    h.adapter.on(
      'GET',
      '/auth/profile',
      (_) => const FakeResponse.json({
        'id': 7,
        'email': 'a@b.co',
        'name': 'A',
        'avatar': '',
      }),
    );

    final user = (await h.repository.currentUser()).valueOrNull!;

    expect(user.id, 7);
    expect(user.avatarUrl, isNull);
  });

  test('hasSession and logout reflect the stored tokens', () async {
    final h = AuthHarness();
    expect(await h.repository.hasSession(), isTrue);

    await h.repository.logout();

    expect(await h.repository.hasSession(), isFalse);
    expect(h.storage.tokens, isNull);
  });
}
