import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a missing url shows the fallback, not a network image', (
    tester,
  ) async {
    await tester.pumpApp(
      const SizedBox.square(dimension: 100, child: AppNetworkImage(url: null)),
    );

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('an empty url is treated as missing', (tester) async {
    await tester.pumpApp(
      const SizedBox.square(dimension: 100, child: AppNetworkImage(url: '')),
    );

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('decodes at display size, not full resolution', (tester) async {
    await tester.pumpApp(
      const Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: AppNetworkImage(url: 'https://example.test/a.png'),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as ResizeImage;
    expect(provider.width, 120, reason: '120 logical px at devicePixelRatio 1');
  });

  testWidgets('a URL that fails to load falls back gracefully', (tester) async {
    await tester.pumpApp(
      const SizedBox.square(
        dimension: 100,
        child: AppNetworkImage(url: 'https://example.test/dead.png'),
      ),
    );
    await tester.settle();

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('rounds its corners when asked', (tester) async {
    await tester.pumpApp(
      const SizedBox.square(
        dimension: 100,
        child: AppNetworkImage(url: null, borderRadius: DSCornerRadius.mAll),
      ),
    );

    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
