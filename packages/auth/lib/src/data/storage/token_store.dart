import 'package:auth/src/data/storage/token_storage.dart';
import 'package:auth/src/domain/entities/auth_tokens.dart';
import 'package:network/network.dart';

/// The single owner of the session tokens: an in-memory cache in front of
/// [TokenStorage], so the auth interceptor reading the token on every request
/// never hits the keystore.
class TokenStore implements TokenProvider {
  TokenStore(this._storage);

  final TokenStorage _storage;
  AuthTokens? _cache;
  bool _loaded = false;

  Future<AuthTokens?> read() async {
    if (!_loaded) {
      _cache = await _storage.read();
      _loaded = true;
    }
    return _cache;
  }

  Future<void> save(AuthTokens tokens) async {
    await _storage.write(tokens);
    _cache = tokens;
    _loaded = true;
  }

  Future<void> clear() async {
    await _storage.clear();
    _cache = null;
    _loaded = true;
  }

  @override
  Future<String?> accessToken() async => (await read())?.accessToken;
}
