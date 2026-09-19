import 'package:auth/src/presentation/login/login_content.dart';
import 'package:auth/src/presentation/login/login_intent.dart';
import 'package:auth/src/presentation/login/login_state.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  Future<List<LoginIntent>> pump(
    WidgetTester tester,
    LoginState state, {
    bool sessionExpired = false,
    Locale locale = const Locale('en'),
  }) async {
    final intents = <LoginIntent>[];
    await tester.pumpApp(
      LoginContent(
        state: state,
        onIntent: intents.add,
        sessionExpired: sessionExpired,
      ),
      locale: locale,
    );
    return intents;
  }

  testWidgets('shows the form in English and in Hebrew', (tester) async {
    await pump(tester, const LoginState());
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await pump(tester, const LoginState(), locale: const Locale('he'));
    await tester.pumpAndSettle();
    expect(find.text('ברוכים השבים'), findsOneWidget);
    expect(find.text('התחברות'), findsOneWidget);
  });

  testWidgets('reports edits and submit as intents', (tester) async {
    final intents = await pump(tester, const LoginState());

    await tester.enterText(find.byType(TextField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.tap(find.text('Sign in'));

    expect(intents, [
      const LoginEmailChanged('a@b.co'),
      const LoginPasswordChanged('pw'),
      const LoginSubmitted(),
    ]);
  });

  testWidgets('the keyboard "done" action submits', (tester) async {
    final intents = await pump(tester, const LoginState());

    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(intents.last, const LoginSubmitted());
  });

  testWidgets('shows localized field errors', (tester) async {
    await pump(tester, const LoginState(email: 'nope', showErrors: true));

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('disables the form and shows progress while submitting', (
    tester,
  ) async {
    await pump(
      tester,
      const LoginState(
        email: 'a@b.co',
        password: 'pw',
        status: LoginSubmitting(),
      ),
    );

    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'wrong credentials read as such, other failures use the shared message',
    (tester) async {
      await pump(
        tester,
        const LoginState(status: LoginFailed(UnauthorizedFailure())),
      );
      expect(find.text('Incorrect email or password.'), findsOneWidget);

      await pump(
        tester,
        const LoginState(status: LoginFailed(NetworkFailure())),
      );
      await tester.pump();
      expect(
        find.text('No internet connection. Check your network and try again.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('explains an expired session, but a fresh failure takes over', (
    tester,
  ) async {
    await pump(tester, const LoginState(), sessionExpired: true);
    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );

    await pump(
      tester,
      const LoginState(status: LoginFailed(UnauthorizedFailure())),
      sessionExpired: true,
    );
    await tester.pump();
    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsNothing,
    );
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}
