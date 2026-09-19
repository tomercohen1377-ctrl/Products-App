import 'package:auth/src/domain/entities/user.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

sealed class RestoreOutcome extends Equatable {
  const RestoreOutcome();

  @override
  List<Object?> get props => const [];
}

/// Nothing stored: show login.
final class NoSession extends RestoreOutcome {
  const NoSession();
}

/// Stored tokens are valid (refreshed transparently if needed).
final class SessionRestored extends RestoreOutcome {
  const SessionRestored(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Tokens exist but the server could not be reached to verify them; the user
/// stays signed in rather than being logged out for being offline.
final class SessionRestoredOffline extends RestoreOutcome {
  const SessionRestoredOffline();
}

/// The server rejected the stored session; it has been cleared.
final class SessionInvalid extends RestoreOutcome {
  const SessionInvalid();
}

/// Decides what a cold start means for the user, based on stored tokens and a
/// profile check (which itself exercises the refresh path).
class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<RestoreOutcome> call() async {
    if (!await _repository.hasSession()) return const NoSession();

    final result = await _repository.currentUser();
    switch (result) {
      case Success(:final value):
        return SessionRestored(value);
      case Failed(failure: UnauthorizedFailure()):
        await _repository.logout();
        return const SessionInvalid();
      case Failed():
        return const SessionRestoredOffline();
    }
  }
}
