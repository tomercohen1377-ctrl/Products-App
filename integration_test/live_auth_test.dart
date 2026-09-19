import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/live_app.dart';

/// Runs the real app on a device/simulator against the live Platzi API, with
/// the real keychain. This is the manual proof of the auth requirements:
///
///   flutter test integration_test -d `simulator-or-device`
///
/// It needs network access and the demo user `john@mail.com` / `changeme`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> runDevAction(
    WidgetTester tester,
    String button,
    Finder expectedOutcome,
  ) async {
    await tester.tap(find.byTooltip('Developer tools'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(button));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call profile now'));
    await pumpUntil(tester, expectedOutcome);
  }

  testWidgets('live API: login, transparent refresh, restart, dead session', (
    tester,
  ) async {
    await clearSession();

    // 1. Login (form is pre-filled in dev builds).
    await launchApp(tester);
    await pumpUntil(tester, find.text('Welcome back'));
    await tester.tap(find.text('Sign in'));
    await pumpUntil(tester, find.text('Products'));

    // 2. Real 401 -> real refresh -> replay, no user-visible interruption.
    await runDevAction(
      tester,
      'Expire access token',
      find.textContaining('recovered transparently'),
    );
    expect(find.text('Products'), findsOneWidget);

    // 3. The session survives an app restart (real keychain).
    await launchApp(tester);
    await pumpUntil(tester, find.text('Products'));
    expect(find.text('Welcome back'), findsNothing);

    // 4. A dead session ends in a clean logout with an explanation.
    await runDevAction(
      tester,
      'Kill session',
      find.text('Your session has expired. Please sign in again.'),
    );
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
