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
    VoidCallback? onUpload,
    bool isUploading = false,
    Failure? uploadFailure,
  }) => ProductImageEditor(
    images: images,
    onAdd: onAdd ?? (_) {},
    onRemove: onRemove ?? (_) {},
    urlError: urlError,
    showRequiredError: showRequiredError,
    onUpload: onUpload,
    isUploading: isUploading,
    uploadFailure: uploadFailure,
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

  group('photo upload', () {
    testWidgets('the button is only there when uploading is supported', (
      tester,
    ) async {
      await tester.pumpApp(editor());
      expect(find.text('Upload photo'), findsNothing);

      await tester.pumpApp(editor(onUpload: () {}));
      expect(find.text('Upload photo'), findsOneWidget);
    });

    testWidgets('tapping it asks to upload', (tester) async {
      var uploads = 0;
      await tester.pumpApp(editor(onUpload: () => uploads++));

      await tester.tap(find.text('Upload photo'));

      expect(uploads, 1);
    });

    testWidgets('shows progress and blocks another tap while uploading', (
      tester,
    ) async {
      var uploads = 0;
      await tester.pumpApp(
        editor(onUpload: () => uploads++, isUploading: true),
      );

      await tester.tap(find.text('Upload photo'), warnIfMissed: false);

      expect(uploads, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows why an upload failed', (tester) async {
      await tester.pumpApp(
        editor(onUpload: () {}, uploadFailure: const NetworkFailure()),
      );

      expect(
        find.text('No internet connection. Check your network and try again.'),
        findsOneWidget,
      );
    });
  });
}
