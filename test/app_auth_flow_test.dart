import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import 'support/app_harness.dart';

/// The auth requirements, end to end through the real app: login, session
/// persisting across restarts, logout clearing it, and a dead session ending
/// in a clean logout.
void main() {
  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'john@mail.com');
    await tester.enterText(find.byType(TextField).at(1), 'changeme');
    await tester.tap(find.text('Sign in'));
    await tester.settle();
  }

  testWidgets('cold start with no session shows login', (tester) async {
    final h = AppHarness();
    await h.launch(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(h.adapter.requests, isEmpty, reason: 'nothing to restore');
  });

  testWidgets('login lands on products and stores the session', (tester) async {
    final h = AppHarness();
    await h.launch(tester);

    await signIn(tester);

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(h.storage.tokens?.accessToken, 'access-1');
  });

  testWidgets('wrong credentials stay on the form with a message', (
    tester,
  ) async {
    final h = AppHarness();
    h.adapter.on('POST', '/auth/login', (_) => const FakeResponse.status(401));
    await h.launch(tester);

    await signIn(tester);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Products'), findsNothing);
    expect(h.storage.tokens, isNull);
  });

  testWidgets('the session persists across an app restart', (tester) async {
    final first = AppHarness();
    await first.launch(tester);
    await signIn(tester);
    expect(find.text('Products'), findsOneWidget);

    // "Restart": a brand-new app over the same keystore.
    await tester.pumpWidget(const SizedBox());
    final second = AppHarness(signedIn: false)
      ..storage.tokens = first.storage.tokens;
    await tester.pumpWidget(second.build());
    await tester.settle();

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('John'), findsOneWidget);
  });

  testWidgets('logout clears the stored session', (tester) async {
    final h = AppHarness(signedIn: true);
    await h.launch(tester);
    expect(find.text('Products'), findsOneWidget);

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.settle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(h.storage.tokens, isNull);
  });

  testWidgets('an expired access token on start is refreshed transparently', (
    tester,
  ) async {
    final h = AppHarness(signedIn: true);
    h.acceptToken('access-2');
    h.adapter.on(
      'POST',
      '/auth/refresh-token',
      (_) => const FakeResponse.json({
        'access_token': 'access-2',
        'refresh_token': 'refresh-2',
      }),
    );

    await h.launch(tester);

    expect(find.text('Products'), findsOneWidget);
    expect(h.adapter.count('POST', '/auth/refresh-token'), 1);
    expect(h.storage.tokens?.refreshToken, 'refresh-2');
  });

  testWidgets('a dead stored session ends on login with an explanation', (
    tester,
  ) async {
    final h = AppHarness(signedIn: true);
    h.acceptToken('never-matches');

    await h.launch(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
    expect(h.storage.tokens, isNull);
  });

  testWidgets('offline at start keeps the user signed in', (tester) async {
    final h = AppHarness(signedIn: true);
    h.adapter.on('GET', '/auth/profile', (_) => const FakeResponse.offline());

    await h.launch(tester);

    expect(find.text('Products'), findsOneWidget);
    expect(h.storage.tokens, isNotNull);
  });
}
