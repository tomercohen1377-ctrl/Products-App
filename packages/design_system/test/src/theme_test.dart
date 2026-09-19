import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light and dark themes expose the design tokens', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured.dsColors.brand, isNotNull);
      expect(captured.dsTypography.h1().fontSize, 28);
      expect(
        Theme.of(captured).scaffoldBackgroundColor,
        captured.dsColors.bgPrimary,
      );
    }
  });

  test('semantic colors differ between light and dark', () {
    expect(
      DSColorsExtension.light.bgPrimary,
      isNot(DSColorsExtension.dark.bgPrimary),
    );
    expect(
      DSColorsExtension.light.lerp(DSColorsExtension.dark, 0).brand,
      DSColorsExtension.light.brand,
    );
    expect(
      DSColorsExtension.light.lerp(DSColorsExtension.dark, 1).brand,
      DSColorsExtension.dark.brand,
    );
  });
}
