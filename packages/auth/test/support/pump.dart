import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/src/presentation/login/login_bloc.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

extension PumpAuth on WidgetTester {
  /// Pumps [child] in the themed, localized [TestApp] on a phone-sized surface.
  Future<void> pumpApp(
    Widget child, {
    Locale locale = const Locale('en'),
  }) async {
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
    await pumpWidget(TestApp(locale: locale, child: child));
  }

  /// Lets bloc event pipelines (which need real event-loop turns) and the
  /// frames they trigger run to completion.
  Future<void> settle() async {
    await runAsync(() => pumpEventQueue());
    await pump();
    await pump(const Duration(milliseconds: 100));
  }
}

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
