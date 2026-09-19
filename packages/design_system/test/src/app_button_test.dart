import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await tester.pumpApp(AppButton(label: 'Go', onPressed: () => taps++));

    await tester.tap(find.text('Go'));
    expect(taps, 1);
  });

  testWidgets('is inert while loading, and shows a spinner', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppButton(label: 'Save', isLoading: true, onPressed: () => taps++),
    );

    await tester.tap(find.text('Save'), warnIfMissed: false);
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await tester.pumpApp(const AppButton(label: 'Go', onPressed: null));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('renders each variant with its Material button', (tester) async {
    await tester.pumpApp(
      Column(
        children: [
          AppButton(label: 'a', onPressed: () {}),
          AppButton(
            label: 'b',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          AppButton(
            label: 'c',
            variant: AppButtonVariant.text,
            onPressed: () {},
          ),
        ],
      ),
    );

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });
}
