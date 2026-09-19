import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/live_app.dart';

/// Creates, edits and deletes a throwaway product on the live API (and
/// cleans up after itself), through the real UI:
///
///   flutter test integration_test -d `simulator-or-device`
///
/// The Platzi API is shared and resets periodically, so this only relies on
/// at least one category existing (`GET /categories`).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets('live API: create, edit and delete a product', (tester) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final created = 'mylo-e2e $stamp';
    final edited = 'mylo-e2e edited $stamp';

    await clearSession();
    await launchApp(tester);
    await pumpUntil(tester, find.text('Welcome back'));
    await tester.tap(find.text('Sign in'));
    await pumpUntil(tester, find.text('Add product'));

    // Create.
    await tester.tap(find.text('Add product'));
    await pumpUntil(tester, find.text('New product'));
    await pumpUntil(tester, find.byType(DropdownButtonFormField<int>));
    await tester.enterText(field('Title'), created);
    await tester.enterText(field('Price'), '12.5');
    await tester.enterText(
      field('Description'),
      'Created by the live e2e test.',
    );
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenuItem<int>).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(field('Image URL'));
    await tester.enterText(
      field('Image URL'),
      'https://i.imgur.com/1twoaDy.jpeg',
    );
    await tester.tap(find.byTooltip('Add image'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create product'));
    await tester.tap(find.text('Create product'));
    await pumpUntil(tester, find.text('Product saved'));
    await pumpUntil(tester, find.text(created));

    // Edit.
    await tester.tap(find.text(created));
    await pumpUntil(tester, find.byTooltip('Edit'));
    await tester.tap(find.byTooltip('Edit'));
    await pumpUntil(tester, find.text('Edit product'));
    await tester.enterText(field('Title'), edited);
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    // The title is also in the form's own text field, so wait for the save
    // to finish and the detail page to be back before asserting on it.
    await pumpUntil(tester, find.text('Product saved'));
    await pumpUntil(tester, find.byTooltip('Delete'));
    expect(find.text(edited), findsOneWidget);

    // Delete (cleanup), back on the list without it.
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await pumpUntil(tester, find.text('Product deleted'));
    await pumpUntil(tester, find.text('Add product'));
    expect(find.text(edited), findsNothing);
    expect(find.text(created), findsNothing);
  });
}
