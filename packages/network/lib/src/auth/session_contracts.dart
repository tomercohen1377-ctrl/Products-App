import 'package:core/core.dart';

/// Supplies the current access token to the auth interceptor.
///
/// Declared here (and implemented by the `auth` package) so `network` never
/// depends on `auth`.
abstract interface class TokenProvider {
  Future<String?> accessToken();
}

/// Exchanges the refresh token for a new session.
abstract interface class SessionRefresher {
  Future<RefreshResult> refresh();
}

sealed class RefreshResult {
  const RefreshResult();
}

/// New tokens were obtained and stored.
final class Refreshed extends RefreshResult {
  const Refreshed();
}

/// The server definitively rejected the refresh token; the session is over.
final class SessionRejected extends RefreshResult {
  const SessionRejected();
}

/// Refreshing failed for a transient reason (offline, timeout, 5xx); the
/// session may still be valid, so the user must not be logged out.
final class RefreshUnavailable extends RefreshResult {
  const RefreshUnavailable(this.failure);

  final Failure failure;
}
