import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionEvents events;

  setUp(() {
    repository = FakeAuthRepository();
    events = SessionEvents();
  });

  tearDown(() => events.dispose());

  SessionBloc build() => SessionBloc(
    restoreSession: RestoreSession(repository),
    repository: repository,
    events: events,
  );

  const signedOut = SessionState(status: SessionStatus.unauthenticated);
  const signedOutExpired = SessionState(
    status: SessionStatus.unauthenticated,
    expired: true,
  );

  test('starts unknown', () {
    expect(build().state, const SessionState.unknown());
    expect(build().state.isKnown, isFalse);
  });

  blocTest<SessionBloc, SessionState>(
    'start with no stored session -> signed out',
    build: build,
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [signedOut],
  );

  blocTest<SessionBloc, SessionState>(
    'start with a valid stored session -> signed in with the user',
    setUp: () => repository.session = true,
    build: build,
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [
      const SessionState(
        status: SessionStatus.authenticated,
        user: userFixture,
      ),
    ],
  );

  blocTest<SessionBloc, SessionState>(
    'start while offline keeps the user signed in without a profile',
    setUp: () {
      repository
        ..session = true
        ..currentUserResult = const Failed(NetworkFailure());
    },
    build: build,
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [const SessionState(status: SessionStatus.authenticated)],
  );

  blocTest<SessionBloc, SessionState>(
    'start with a rejected session -> signed out, flagged as expired',
    setUp: () {
      repository
        ..session = true
        ..currentUserResult = const Failed(UnauthorizedFailure());
    },
    build: build,
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [signedOutExpired],
    verify: (_) => expect(repository.logoutCalls, 1),
  );

  blocTest<SessionBloc, SessionState>(
    'signing in stores the user',
    build: build,
    act: (bloc) => bloc.add(const SessionSignedIn(userFixture)),
    expect: () => [
      const SessionState(
        status: SessionStatus.authenticated,
        user: userFixture,
      ),
    ],
  );

  blocTest<SessionBloc, SessionState>(
    'signing out clears the stored session',
    seed: () => const SessionState(
      status: SessionStatus.authenticated,
      user: userFixture,
    ),
    build: build,
    act: (bloc) => bloc.add(const SessionSignOutRequested()),
    expect: () => [signedOut],
    verify: (_) => expect(repository.logoutCalls, 1),
  );

  blocTest<SessionBloc, SessionState>(
    'a session-expired event from the network layer signs out as expired',
    seed: () => const SessionState(
      status: SessionStatus.authenticated,
      user: userFixture,
    ),
    build: build,
    act: (_) => events.notifyExpired(),
    wait: const Duration(milliseconds: 20),
    expect: () => [signedOutExpired],
  );

  blocTest<SessionBloc, SessionState>(
    'signing out after an expiry clears the expired flag',
    seed: () => signedOutExpired,
    build: build,
    act: (bloc) => bloc.add(const SessionSignOutRequested()),
    expect: () => [signedOut],
  );
}
