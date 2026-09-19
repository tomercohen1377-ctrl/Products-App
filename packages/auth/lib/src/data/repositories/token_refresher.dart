import 'package:auth/src/data/mappers/auth_mappers.dart';
import 'package:auth/src/data/sources/refresh_remote_source.dart';
import 'package:auth/src/data/storage/token_store.dart';
import 'package:core/core.dart';
import 'package:network/network.dart';

/// Exchanges the stored refresh token for a new session.
///
/// A **definitive** rejection (the server answers 4xx) clears the stored
/// session and reports [SessionRejected]. Anything transient (offline,
/// timeout, 5xx) reports [RefreshUnavailable] and keeps the session, so being
/// offline never logs the user out.
class TokenRefresher implements SessionRefresher {
  const TokenRefresher(this._remote, this._tokens);

  final RefreshRemoteSource _remote;
  final TokenStore _tokens;

  @override
  Future<RefreshResult> refresh() async {
    final current = await _tokens.read();
    if (current == null) return const SessionRejected();

    final result = await guardApi(() => _remote.refresh(current.refreshToken));
    switch (result) {
      case Success(:final value):
        await _tokens.save(value.toEntity());
        return const Refreshed();
      case Failed(failure: UnauthorizedFailure() || ValidationFailure()):
        await _tokens.clear();
        return const SessionRejected();
      case Failed(:final failure):
        return RefreshUnavailable(failure);
    }
  }
}
