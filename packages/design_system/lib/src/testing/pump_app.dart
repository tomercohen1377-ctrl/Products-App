import 'package:design_system/src/testing/test_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-test helpers shared by every package, so none re-implements them.
extension PumpApp on WidgetTester {
  /// Pumps [child] in the themed, localized [TestApp] on a phone-sized surface.
  Future<void> pumpApp(
    Widget child, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
  }) async {
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
    await pumpWidget(
      TestApp(locale: locale, brightness: brightness, child: child),
    );
  }

  /// Lets bloc event pipelines (which need real event-loop turns) and the
  /// frames they trigger run to completion. Does not wait for animations;
  /// follow with `pumpAndSettle` when the screen has no endless spinner.
  Future<void> settle() async {
    // A few rounds: navigation, a bloc starting and an async fake each add
    // hops that a single round of the event queue does not cover.
    for (var round = 0; round < 3; round++) {
      await runAsync(() => pumpEventQueue());
      await pump(const Duration(milliseconds: 100));
    }
  }
}
