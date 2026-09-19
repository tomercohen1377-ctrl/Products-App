import 'package:auth/src/domain/entities/auth_tokens.dart';

/// Persistent storage for the session tokens.
abstract interface class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}
