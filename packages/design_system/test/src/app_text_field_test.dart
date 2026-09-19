import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  testWidgets('reports edits and shows the seeded value', (tester) async {
    final edits = <String>[];
    await tester.pumpApp(
      AppTextField(label: 'Title', initialValue: 'Hat', onChanged: edits.add),
    );

    expect(find.text('Hat'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hats');
    expect(edits, ['Hats']);
  });

  testWidgets('shows the error text', (tester) async {
    await tester.pumpApp(
      const AppTextField(label: 'Price', errorText: 'Enter a valid number'),
    );
    expect(find.text('Enter a valid number'), findsOneWidget);
  });

  testWidgets('password field toggles visibility', (tester) async {
    await tester.pumpApp(
      const AppTextField(label: 'Password', obscureText: true),
    );

    bool obscured() =>
        tester.widget<TextField>(find.byType(TextField)).obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(obscured(), isFalse);
  });

  testWidgets('uses an external controller without disposing it', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'x');
    addTearDown(controller.dispose);
    await tester.pumpApp(AppTextField(label: 'Url', controller: controller));

    controller.clear();
    await tester.pump();
    expect(find.text('x'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    expect(() => controller.text = 'still usable', returnsNormally);
  });
}
