import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Pumps [child] in the themed, localized [TestApp] at a phone-sized surface.
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
}
