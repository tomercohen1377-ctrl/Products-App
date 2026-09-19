import 'package:auth/src/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState extends Equatable {
  const SessionState({required this.status, this.user, this.expired = false});

  /// Before the stored session has been checked.
  const SessionState.unknown() : this(status: SessionStatus.unknown);

  final SessionStatus status;

  /// Null when signed in but not (yet) verified, e.g. restored while offline.
  final User? user;

  /// The user was signed out because the session could not be recovered, so
  /// the login screen can explain why.
  final bool expired;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isKnown => status != SessionStatus.unknown;

  @override
  List<Object?> get props => [status, user, expired];
}
