import 'package:auth/src/data/storage/token_store.dart';
import 'package:auth/src/domain/entities/auth_tokens.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:core/core.dart';

/// What a [AuthDebugTools.pingProfile] call observed.
class ProfilePing {
  const ProfilePing({
    required this.succeeded,
    required this.tokenRotated,
    this.failure,
  });

  final bool succeeded;

  /// The access token changed during the call, i.e. a refresh happened.
  final bool tokenRotated;
  final Failure? failure;
}

/// Dev-only actions that make the token refresh path demonstrable, since the
/// API's tokens don't expire during a short demo.
class AuthDebugTools {
  const AuthDebugTools(this._store, this._repository);

  final TokenStore _store;
  final AuthRepository _repository;

  /// Corrupts the access token: the next protected call gets a real 401 from
  /// the server, then refreshes and replays transparently.
  Future<void> expireAccessToken() async {
    final tokens = await _store.read();
    if (tokens == null) return;
    await _store.save(
      AuthTokens(
        accessToken: 'expired.${tokens.accessToken}',
        refreshToken: tokens.refreshToken,
      ),
    );
  }

  /// Corrupts both tokens: the next protected call gets a 401, the refresh is
  /// rejected too, and the user is logged out cleanly.
  Future<void> killSession() async {
    final tokens = await _store.read();
    if (tokens == null) return;
    await _store.save(
      AuthTokens(
        accessToken: 'expired.${tokens.accessToken}',
        refreshToken: 'revoked.${tokens.refreshToken}',
      ),
    );
  }

  /// Calls `GET /auth/profile` now and reports whether a refresh happened.
  Future<ProfilePing> pingProfile() async {
    final before = (await _store.read())?.accessToken;
    final result = await _repository.currentUser();
    final after = (await _store.read())?.accessToken;
    return ProfilePing(
      succeeded: result.isSuccess,
      tokenRotated: before != after,
      failure: result.failureOrNull,
    );
  }
}
