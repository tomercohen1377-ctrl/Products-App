import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:core/core.dart';

/// A scriptable [AuthRepository] for use case and bloc tests.
class FakeAuthRepository implements AuthRepository {
  bool session = false;
  Result<User> loginResult = const Success(userFixture);
  Result<User> currentUserResult = const Success(userFixture);
  int logoutCalls = 0;
  int loginCalls = 0;

  /// When set, `login` waits for it, so tests can hold a submit in flight.
  Completer<void>? loginGate;
  ({String email, String password})? lastLogin;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastLogin = (email: email, password: password);
    await loginGate?.future;
    return loginResult;
  }

  @override
  Future<Result<User>> currentUser() async => currentUserResult;

  @override
  Future<bool> hasSession() async => session;

  @override
  Future<void> logout() async {
    logoutCalls++;
    session = false;
  }
}
