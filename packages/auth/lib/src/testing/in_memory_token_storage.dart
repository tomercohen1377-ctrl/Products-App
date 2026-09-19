import 'package:auth/src/data/storage/token_storage.dart';
import 'package:auth/src/domain/entities/auth_tokens.dart';

/// A [TokenStorage] that keeps tokens in memory and counts its I/O.
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage([this.tokens]);

  AuthTokens? tokens;
  int reads = 0;
  int writes = 0;

  @override
  Future<AuthTokens?> read() async {
    reads++;
    return tokens;
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    writes++;
    this.tokens = tokens;
  }

  @override
  Future<void> clear() async => tokens = null;
}
