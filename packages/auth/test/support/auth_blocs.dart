import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/src/presentation/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'fake_auth_repository.dart';

/// Real blocs over a [FakeAuthRepository], for screen-level tests.
class AuthBlocs {
  AuthBlocs({FakeAuthRepository? repository, LoginPrefill? prefill})
    : repository = repository ?? FakeAuthRepository() {
    events = SessionEvents();
    session = SessionBloc(
      restoreSession: RestoreSession(this.repository),
      repository: this.repository,
      events: events,
    );
    login = LoginBloc(this.repository, prefill: prefill);
  }

  final FakeAuthRepository repository;
  late final SessionEvents events;
  late final SessionBloc session;
  late final LoginBloc login;

  Widget provide(Widget child) => MultiBlocProvider(
    providers: [
      BlocProvider<SessionBloc>.value(value: session),
      BlocProvider<LoginBloc>.value(value: login),
    ],
    child: child,
  );

  /// Not awaited: closing streams needs real event-loop turns, which a widget
  /// test's fake async zone does not provide.
  void dispose() {
    unawaited(session.close());
    unawaited(login.close());
    unawaited(events.dispose());
  }
}
