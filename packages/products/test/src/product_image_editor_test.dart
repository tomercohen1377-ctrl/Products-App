import 'package:core/core.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/presentation/widgets/product_image_editor.dart';

void main() {
  const image = 'https://example.test/a.png';

  Widget editor({
    List<String> images = const [],
    ValueChanged<String>? onAdd,
    ValueChanged<String>? onRemove,
    FieldError? urlError,
    bool showRequiredError = false,
  }) => ProductImageEditor(
    images: images,
    onAdd: onAdd ?? (_) {},
    onRemove: onRemove ?? (_) {},
    urlError: urlError,
    showRequiredError: showRequiredError,
  );

  testWidgets('reports the typed url on the add button and on "done"', (
    tester,
  ) async {
    final added = <String>[];
    await tester.pumpApp(editor(onAdd: added.add));

    await tester.enterText(find.byType(TextField), image);
    await tester.tap(find.byTooltip('Add image'));
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(added, [image, image]);
  });

  testWidgets('removes a thumbnail', (tester) async {
    final removed = <String>[];
    await tester.pumpApp(editor(images: const [image], onRemove: removed.add));

    await tester.tap(find.byTooltip('Remove image'));

    expect(removed, [image]);
  });

  testWidgets(
    'clears the field once an image was added, not when it was rejected',
    (tester) async {
      await tester.pumpApp(editor());
      await tester.enterText(find.byType(TextField), 'bad');

      await tester.pumpApp(editor(urlError: FieldError.invalidUrl));
      expect(
        find.text('bad'),
        findsOneWidget,
        reason: 'kept so it can be fixed',
      );
      expect(find.text('Enter a valid http(s) link'), findsOneWidget);

      await tester.pumpApp(editor(images: const [image]));
      expect(find.text('bad'), findsNothing);
    },
  );

  testWidgets('shows the "at least one image" message', (tester) async {
    await tester.pumpApp(editor(showRequiredError: true));

    expect(find.text('Add at least one image'), findsOneWidget);
  });
}
