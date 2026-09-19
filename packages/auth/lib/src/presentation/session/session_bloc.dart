import 'dart:async';

import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/domain/session_events.dart';
import 'package:auth/src/domain/use_cases/restore_session.dart';
import 'package:auth/src/presentation/session/session_intent.dart';
import 'package:auth/src/presentation/session/session_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Emitter;

/// Owns "is someone signed in?" for the whole app. The router redirects on
/// its state, so sign-in, sign-out and session expiry need no per-screen
/// handling.
class SessionBloc extends MviBloc<SessionIntent, SessionState, NoEffect> {
  SessionBloc({
    required this._restoreSession,
    required this._repository,
    required SessionEvents events,
  }) : super(const SessionState.unknown()) {
    on<SessionStarted>(_onStarted, transformer: sequential());
    on<SessionSignedIn>(
      (intent, emit) => emit(
        SessionState(status: SessionStatus.authenticated, user: intent.user),
      ),
      transformer: sequential(),
    );
    on<SessionSignOutRequested>(_onSignOut, transformer: sequential());
    on<SessionExpiredDetected>(_onExpired, transformer: sequential());

    _expiredSubscription = events.expired.listen(
      (_) => add(const SessionExpiredDetected()),
    );
  }

  final RestoreSession _restoreSession;
  final AuthRepository _repository;
  late final StreamSubscription<void> _expiredSubscription;

  Future<void> _onStarted(
    SessionStarted intent,
    Emitter<SessionState> emit,
  ) async {
    final outcome = await _restoreSession();
    emit(switch (outcome) {
      SessionRestored(:final user) => SessionState(
        status: SessionStatus.authenticated,
        user: user,
      ),
      SessionRestoredOffline() => const SessionState(
        status: SessionStatus.authenticated,
      ),
      NoSession() => const SessionState(status: SessionStatus.unauthenticated),
      SessionInvalid() => const SessionState(
        status: SessionStatus.unauthenticated,
        expired: true,
      ),
    });
  }

  Future<void> _onSignOut(
    SessionSignOutRequested intent,
    Emitter<SessionState> emit,
  ) async {
    await _repository.logout();
    emit(const SessionState(status: SessionStatus.unauthenticated));
  }

  Future<void> _onExpired(
    SessionExpiredDetected intent,
    Emitter<SessionState> emit,
  ) async {
    await _repository.logout();
    emit(
      const SessionState(status: SessionStatus.unauthenticated, expired: true),
    );
  }

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return super.close();
  }
}
