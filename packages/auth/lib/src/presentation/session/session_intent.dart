import 'package:auth/src/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

sealed class SessionIntent extends Equatable {
  const SessionIntent();

  @override
  List<Object?> get props => const [];
}

/// App start: restore a stored session, if any.
final class SessionStarted extends SessionIntent {
  const SessionStarted();
}

final class SessionSignedIn extends SessionIntent {
  const SessionSignedIn(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class SessionSignOutRequested extends SessionIntent {
  const SessionSignOutRequested();
}

/// The network layer could not recover the session.
final class SessionExpiredDetected extends SessionIntent {
  const SessionExpiredDetected();
}
