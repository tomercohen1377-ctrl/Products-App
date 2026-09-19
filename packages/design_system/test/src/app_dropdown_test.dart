import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const items = [
    AppDropdownItem(value: 1, label: 'Clothes'),
    AppDropdownItem(value: 2, label: 'Electronics'),
  ];

  testWidgets('shows the selected item and reports a new selection', (
    tester,
  ) async {
    final selected = <int>[];
    await tester.pumpApp(
      AppDropdown<int>(
        label: 'Category',
        items: items,
        value: 1,
        onChanged: selected.add,
      ),
    );
    expect(find.text('Clothes'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Electronics').last);
    await tester.pumpAndSettle();

    expect(selected, [2]);
  });

  testWidgets('a value that is not among the items shows as unselected', (
    tester,
  ) async {
    await tester.pumpApp(
      AppDropdown<int>(
        label: 'Category',
        items: items,
        value: 99,
        onChanged: (_) {},
      ),
    );

    expect(find.text('Clothes'), findsNothing);
    expect(find.text('Category'), findsOneWidget);
  });

  testWidgets('shows an error and can be disabled', (tester) async {
    await tester.pumpApp(
      AppDropdown<int>(
        label: 'Category',
        items: items,
        value: null,
        errorText: 'This field is required',
        enabled: false,
        onChanged: (_) {},
      ),
    );

    expect(find.text('This field is required'), findsOneWidget);
    final field = tester.widget<DropdownButtonFormField<int>>(
      find.byType(DropdownButtonFormField<int>),
    );
    expect(field.onChanged, isNull);
  });
}
