import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/live_app.dart';

/// Records a frame timeline while the swipe deck is thrown around: fast drags
/// both ways, and throws from the buttons.
///
/// Numbers only mean something on a physical device, in profile mode:
///
///   flutter drive --profile -d `device` \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/deck_performance_test.dart
///
/// The summary lands in `build/deck_timeline.timeline_summary.json`; look at
/// `average_frame_build_time_millis`, `average_frame_rasterizer_time_millis`
/// and `missed_frame_*_budget_count`.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('deck swipes stay smooth', (tester) async {
    await clearSession();
    await launchApp(tester);
    await pumpUntil(tester, find.text('Welcome back'));
    await tester.tap(find.text('Sign in'));
    await pumpUntil(tester, find.text('Deck'));
    await tester.tap(find.text('Deck'));
    await pumpUntil(tester, find.byTooltip('Like'));
    // Let the first images decode so the timeline measures the gestures.
    await tester.pump(const Duration(seconds: 3));

    await binding.traceAction(() async {
      for (var i = 0; i < 24; i++) {
        if (find.text('Start over').evaluate().isNotEmpty) {
          await tester.tap(find.text('Start over'));
          await tester.pump(const Duration(milliseconds: 300));
          continue;
        }
        if (find.byTooltip('Like').evaluate().isEmpty) {
          await tester.pump(const Duration(milliseconds: 200));
          continue;
        }
        final like = tester.getCenter(find.byTooltip('Like'));
        final card = like - const Offset(0, 320);
        switch (i % 3) {
          case 0:
            await tester.dragFrom(card, Offset(i.isEven ? 300 : -300, -40));
          case 1:
            await tester.tap(find.byTooltip('Like'));
          case 2:
            await tester.tap(find.byTooltip('Skip'));
        }
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      }
    }, reportKey: 'deck_timeline');

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
