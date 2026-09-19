import 'dart:async';

import 'package:auth/src/presentation/login/login_bloc.dart';
import 'package:auth/src/presentation/login/login_effect.dart';
import 'package:auth/src/presentation/login/login_intent.dart';
import 'package:auth/src/presentation/login/login_state.dart';
import 'package:auth/testing.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  LoginBloc build({LoginPrefill? prefill}) =>
      LoginBloc(repository, prefill: prefill);

  const valid = LoginState(email: 'john@mail.com', password: 'changeme');

  test('starts empty, or with the dev prefill', () {
    expect(build().state, const LoginState());
    expect(
      build(
        prefill: const LoginPrefill(email: 'a@b.co', password: 'pw'),
      ).state,
      const LoginState(email: 'a@b.co', password: 'pw'),
    );
  });

  blocTest<LoginBloc, LoginState>(
    'editing fields updates state and hides a previous failure',
    build: build,
    seed: () => valid.copyWith(status: const LoginFailed(NetworkFailure())),
    act: (bloc) => bloc
      ..add(const LoginEmailChanged('a@b.co'))
      ..add(const LoginPasswordChanged('pw')),
    expect: () => [
      const LoginState(email: 'a@b.co', password: 'changeme'),
      const LoginState(email: 'a@b.co', password: 'pw'),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'submitting invalid input shows field errors and does not call the server',
    build: build,
    seed: () => const LoginState(email: 'nope'),
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => [const LoginState(email: 'nope', showErrors: true)],
    verify: (bloc) {
      expect(repository.loginCalls, 0);
      expect(bloc.state.emailError, FieldError.invalidEmail);
      expect(bloc.state.passwordError, FieldError.required);
    },
  );

  test('errors stay hidden until the first submit', () {
    const state = LoginState(email: 'nope');
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
    expect(state.isValid, isFalse);
  });

  blocTest<LoginBloc, LoginState>(
    'valid submit signs in and emits a one-shot effect',
    build: build,
    seed: () => valid.copyWith(email: '  john@mail.com  '),
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => [
      isA<LoginState>().having((s) => s.isSubmitting, 'submitting', isTrue),
      isA<LoginState>()
          .having((s) => s.isSubmitting, 'submitting', isFalse)
          .having((s) => s.failure, 'failure', isNull),
    ],
    verify: (_) {
      expect(repository.lastLogin, (
        email: 'john@mail.com',
        password: 'changeme',
      ));
    },
  );

  test('the success effect carries the user', () async {
    final bloc = build();
    addTearDown(bloc.close);
    final effects = <LoginEffect>[];
    final subscription = bloc.effects.listen(effects.add);
    addTearDown(subscription.cancel);

    bloc
      ..add(const LoginEmailChanged('john@mail.com'))
      ..add(const LoginPasswordChanged('changeme'))
      ..add(const LoginSubmitted());
    await pumpEventQueue();

    expect(effects, [const LoginSucceeded(userFixture)]);
  });

  blocTest<LoginBloc, LoginState>(
    'wrong credentials surface the failure and keep the form',
    build: build,
    setUp: () => repository.loginResult = const Failed(UnauthorizedFailure()),
    seed: () => valid,
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => [
      isA<LoginState>().having((s) => s.isSubmitting, 'submitting', isTrue),
      valid.copyWith(
        showErrors: true,
        status: const LoginFailed(UnauthorizedFailure()),
      ),
    ],
  );

  test('a failed attempt emits no success effect', () async {
    repository.loginResult = const Failed(NetworkFailure());
    final bloc = build();
    addTearDown(bloc.close);
    final effects = <LoginEffect>[];
    final subscription = bloc.effects.listen(effects.add);
    addTearDown(subscription.cancel);

    bloc
      ..add(const LoginEmailChanged('john@mail.com'))
      ..add(const LoginPasswordChanged('changeme'))
      ..add(const LoginSubmitted());
    await pumpEventQueue();

    expect(effects, isEmpty);
    expect(bloc.state.failure, const NetworkFailure());
  });

  test('a double tap only logs in once', () async {
    repository.loginGate = Completer<void>();
    final bloc = build(
      prefill: const LoginPrefill(email: 'john@mail.com', password: 'changeme'),
    );
    addTearDown(bloc.close);

    bloc
      ..add(const LoginSubmitted())
      ..add(const LoginSubmitted())
      ..add(const LoginSubmitted());
    await pumpEventQueue();
    repository.loginGate!.complete();
    await pumpEventQueue();

    expect(repository.loginCalls, 1);
  });
}
