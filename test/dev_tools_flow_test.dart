import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import 'support/app_harness.dart';

/// The refresh demo: the dev-tools sheet forces a real 401 and shows the
/// app recovering (or logging out cleanly).
void main() {
  Future<void> openDevTools(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Developer tools'));
    await tester.pumpAndSettle();
  }

  testWidgets('dev tools are absent when disabled', (tester) async {
    final h = AppHarness(signedIn: true);
    await h.launch(tester);

    expect(find.byTooltip('Developer tools'), findsNothing);
  });

  testWidgets(
    '"Expire access token" then "Call profile" refreshes transparently',
    (tester) async {
      final h = AppHarness(signedIn: true, devTools: true);
      await h.launch(tester);
      h.acceptToken('access-2');
      h.adapter.on(
        'POST',
        '/auth/refresh-token',
        (_) => const FakeResponse.json({
          'access_token': 'access-2',
          'refresh_token': 'refresh-2',
        }),
      );

      await openDevTools(tester);
      await tester.tap(find.textContaining('Expire access token'));
      await tester.settleApp();
      await tester.tap(find.text('Call profile now'));
      await tester.settleApp();

      expect(find.textContaining('recovered transparently'), findsOneWidget);
      expect(h.adapter.count('POST', '/auth/refresh-token'), 1);
      expect(h.storage.tokens?.accessToken, 'access-2');
    },
  );

  testWidgets('"Kill session" then "Call profile" logs out cleanly', (
    tester,
  ) async {
    final h = AppHarness(signedIn: true, devTools: true);
    await h.launch(tester);

    await openDevTools(tester);
    await tester.tap(find.textContaining('Kill session'));
    await tester.settleApp();
    await tester.tap(find.text('Call profile now'));
    await tester.settleApp();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
    expect(h.storage.tokens, isNull);
  });

  testWidgets('the login form is pre-filled in dev builds', (tester) async {
    final h = AppHarness(devTools: true);
    await h.launch(tester);

    expect(find.text('john@mail.com'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
