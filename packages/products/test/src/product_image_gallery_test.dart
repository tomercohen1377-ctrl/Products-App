import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/presentation/widgets/product_image_gallery.dart';

void main() {
  const images = [
    'https://example.test/1.png',
    'https://example.test/2.png',
    'https://example.test/3.png',
  ];

  testWidgets('swiping moves between images and announces the position', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const ProductImageGallery(images: images));
    expect(find.bySemanticsLabel('Image 1 of 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-250, 0));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Image 2 of 3'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a single image shows no page dots', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(ProductImageGallery(images: [images.first]));

    expect(find.bySemanticsLabel(RegExp('Image 1 of')), findsNothing);
    handle.dispose();
  });

  testWidgets('no images shows the placeholder', (tester) async {
    await tester.pumpApp(const ProductImageGallery(images: []));

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('tags the cover image for a shared-element transition when '
      'given a heroTag', (tester) async {
    await tester.pumpApp(
      const ProductImageGallery(images: images, heroTag: 'tag-1'),
    );

    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'tag-1');
    expect(hero.flightShuttleBuilder, isNotNull);
  });

  testWidgets('does not wrap in a Hero without a heroTag', (tester) async {
    await tester.pumpApp(const ProductImageGallery(images: images));

    expect(find.byType(Hero), findsNothing);
  });
}
