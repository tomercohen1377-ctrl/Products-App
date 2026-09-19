import 'package:auth/src/data/storage/token_store.dart';
import 'package:auth/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the keystore once and serves later reads from memory', () async {
    final storage = InMemoryTokenStorage(authTokensFixture);
    final store = TokenStore(storage);

    expect(await store.accessToken(), 'access-1');
    expect(await store.accessToken(), 'access-1');
    expect(await store.read(), authTokensFixture);

    expect(storage.reads, 1);
  });

  test('an empty keystore means no session and is remembered', () async {
    final storage = InMemoryTokenStorage();
    final store = TokenStore(storage);

    expect(await store.accessToken(), isNull);
    expect(await store.read(), isNull);
    expect(storage.reads, 1);
  });

  test('save writes through and updates the cache', () async {
    final storage = InMemoryTokenStorage();
    final store = TokenStore(storage);

    await store.save(authTokensFixture);

    expect(storage.tokens, authTokensFixture);
    expect(await store.accessToken(), 'access-1');
    expect(storage.reads, 0, reason: 'cache was primed by save');
  });

  test('clear empties storage and cache', () async {
    final storage = InMemoryTokenStorage(authTokensFixture);
    final store = TokenStore(storage);
    await store.read();

    await store.clear();

    expect(storage.tokens, isNull);
    expect(await store.accessToken(), isNull);
  });
}
