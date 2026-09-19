import 'package:auth/src/data/storage/token_storage.dart';
import 'package:auth/src/domain/entities/auth_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps tokens in the platform keystore (Keychain / Android Keystore).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      if (access == null || refresh == null) return null;
      return AuthTokens(accessToken: access, refreshToken: refresh);
    } on PlatformException {
      // An unreadable keystore entry (e.g. restored from backup) is treated
      // as "no session" so the user can simply sign in again.
      return null;
    }
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
