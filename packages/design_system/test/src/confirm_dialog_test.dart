import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a button that opens the dialog and returns a getter for the answer.
Future<bool? Function()> openDialog(
  WidgetTester tester, {
  bool destructive = false,
}) async {
  bool? result;
  await tester.pumpApp(
    Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showConfirmDialog(
          context,
          title: 'Delete?',
          message: 'Gone forever.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          destructive: destructive,
        ),
        child: const Text('open'),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => result;
}

void main() {
  testWidgets('shows the title and message, and confirming returns true', (
    tester,
  ) async {
    final answer = await openDialog(tester);
    expect(find.text('Delete?'), findsOneWidget);
    expect(find.text('Gone forever.'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(answer(), isTrue);
  });

  testWidgets('cancelling returns false', (tester) async {
    final answer = await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(answer(), isFalse);
  });

  testWidgets('dismissing by tapping outside counts as cancelling', (
    tester,
  ) async {
    final answer = await openDialog(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(answer(), isFalse);
  });

  testWidgets('destructive confirm uses the error color', (tester) async {
    await openDialog(tester, destructive: true);

    final button = tester.widgetList<TextButton>(find.byType(TextButton)).last;
    expect(
      button.style?.foregroundColor?.resolve({}),
      DSColorsExtension.light.error,
    );
  });
}
