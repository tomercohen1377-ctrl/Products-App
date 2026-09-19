import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late RestoreSession restore;

  setUp(() {
    repository = FakeAuthRepository();
    restore = RestoreSession(repository);
  });

  test('no stored session means show login', () async {
    repository.session = false;

    expect(await restore(), const NoSession());
  });

  test('a valid stored session is restored with its user', () async {
    repository.session = true;

    expect(await restore(), const SessionRestored(userFixture));
    expect(repository.logoutCalls, 0);
  });

  test('a rejected session is cleared', () async {
    repository
      ..session = true
      ..currentUserResult = const Failed(UnauthorizedFailure());

    expect(await restore(), const SessionInvalid());
    expect(repository.logoutCalls, 1);
  });

  for (final failure in <Failure>[
    const NetworkFailure(),
    const TimeoutFailure(),
    const ServerFailure(statusCode: 500),
  ]) {
    test('${failure.runtimeType} keeps the user signed in', () async {
      repository
        ..session = true
        ..currentUserResult = Failed(failure);

      expect(await restore(), const SessionRestoredOffline());
      expect(repository.logoutCalls, 0);
    });
  }
}
