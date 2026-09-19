import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mylo_products/app/app.dart';
import 'package:mylo_products/app/bootstrap.dart';

/// Runs the real app on a device/simulator against the live Platzi API, with
/// the real keychain. This is the manual proof of the auth requirements:
///
///   flutter test integration_test/live_auth_test.dart -d `simulator-or-device`
///
/// It needs network access and the demo user `john@mail.com` / `changeme`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for $finder');
  }

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MyloApp(getIt: bootstrap(devTools: true)));
  }

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
    // Clean slate: whatever a previous run left in the keychain.
    final cleanup = bootstrap(devTools: true);
    await cleanup<AuthRepository>().logout();

    // 1. Login (form is pre-filled in dev builds).
    await launch(tester);
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
    await launch(tester);
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
