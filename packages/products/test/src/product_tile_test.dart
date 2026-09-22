import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:products/src/presentation/widgets/product_tile.dart';
import 'package:products/testing.dart';

void main() {
  testWidgets('shows category, title and price, and reports taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      ProductTile(product: productFixture, onTap: () => taps++),
    );

    expect(find.text('Clothes'), findsOneWidget);
    expect(find.text('Classic Red Pullover Hoodie'), findsOneWidget);
    expect(find.text(r'$10'), findsOneWidget);

    await tester.tap(find.byType(ProductTile));
    expect(taps, 1);
  });

  testWidgets('the thumbnail is tagged for a shared-element transition', (
    tester,
  ) async {
    await tester.pumpApp(const ProductTile(product: productFixture));

    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'product-image-${productFixture.id}');
    expect(
      hero.flightShuttleBuilder,
      isNotNull,
      reason:
          'a plain AppNetworkImage would flicker mid-flight as Hero '
          'resizes it frame to frame',
    );
  });

  testWidgets('a product without images or category still renders', (
    tester,
  ) async {
    await tester.pumpApp(
      const ProductTile(
        product: Product(
          id: 1,
          title: 'Bare',
          price: 5,
          description: '',
          images: [],
        ),
      ),
    );

    expect(find.text('Bare'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets(
    'a very long title and price do not overflow, even at 1.5x text',
    (tester) async {
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: ProductTile(
            product: Product(
              id: 1,
              title: 'A' * 200,
              price: 1234567,
              description: '',
              images: const [],
              category: Category(id: 1, name: 'B' * 100),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(r'$1,234,567'), findsOneWidget);
    },
  );
}
