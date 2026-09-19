import 'package:auth/src/presentation/login/login_screen.dart';
import 'package:auth/testing.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  late AuthBlocs blocs;

  setUp(() => blocs = AuthBlocs());
  tearDown(() => blocs.dispose());

  testWidgets('a successful login signs the session in', (tester) async {
    await tester.pumpApp(blocs.provide(const LoginScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'john@mail.com');
    await tester.enterText(find.byType(TextField).at(1), 'changeme');
    await tester.tap(find.text('Sign in'));
    await tester.settle();

    expect(blocs.repository.lastLogin?.email, 'john@mail.com');
    expect(blocs.session.state.isAuthenticated, isTrue);
    expect(blocs.session.state.user, userFixture);
  });

  testWidgets('failed login stays on the form and shows the reason', (
    tester,
  ) async {
    blocs.repository.loginResult = const Failed(UnauthorizedFailure());
    await tester.pumpApp(blocs.provide(const LoginScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'john@mail.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('Sign in'));
    await tester.settle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(blocs.session.state.isAuthenticated, isFalse);
  });

  testWidgets('shows the expired-session notice after a forced sign-out', (
    tester,
  ) async {
    await tester.pumpApp(blocs.provide(const LoginScreen()));

    blocs.events.notifyExpired();
    await tester.settle();

    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
  });
}
