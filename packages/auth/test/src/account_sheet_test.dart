import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/auth_blocs.dart';

void main() {
  testWidgets('shows who is signed in and signs out', (tester) async {
    var signedOut = 0;
    await tester.pumpApp(
      AccountSheetContent(user: userFixture, onSignOut: () => signedOut++),
    );

    expect(find.text('John'), findsOneWidget);
    expect(find.text('john@mail.com'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    expect(signedOut, 1);
  });

  testWidgets('offline (no profile) still offers sign out', (tester) async {
    await tester.pumpApp(AccountSheetContent(user: null, onSignOut: () {}));

    expect(find.text('Signed in as'), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets(
    'the app-bar button opens the sheet and sign out ends the session',
    (tester) async {
      final blocs = AuthBlocs();
      addTearDown(blocs.dispose);
      blocs.session.add(const SessionSignedIn(userFixture));
      await tester.pumpApp(blocs.provide(const Center(child: AccountButton())));
      await tester.settle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.text('john@mail.com'), findsOneWidget);

      await tester.tap(find.text('Sign out'));
      await tester.settle();
      await tester.pumpAndSettle();

      expect(blocs.session.state.status, SessionStatus.unauthenticated);
      expect(find.text('john@mail.com'), findsNothing);
    },
  );
}
