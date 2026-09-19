import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:products/src/presentation/deck/product_deck_view.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';
import 'package:products/src/presentation/widgets/product_deck_card.dart';

import '../support/fake_products_repository.dart';

void main() {
  final products = makeProducts(8);

  ProductsState deck({
    Set<int> liked = const {},
    Set<int> dismissed = const {},
    bool reachedEnd = false,
    Failure? loadMoreFailure,
    List<Product>? items,
  }) => ProductsState(
    phase: ProductsPhase.ready,
    items: items ?? products,
    hasReachedEnd: reachedEnd,
    viewMode: ProductsViewMode.deck,
    likedIds: liked,
    dismissedIds: dismissed,
    loadMoreFailure: loadMoreFailure,
  );

  Future<List<ProductsIntent>> pump(
    WidgetTester tester,
    ProductsState state, {
    Locale locale = const Locale('en'),
  }) async {
    final intents = <ProductsIntent>[];
    await tester.pumpApp(
      ProductDeckView(state: state, onIntent: intents.add),
      locale: locale,
    );
    await tester.pump();
    return intents;
  }

  testWidgets('shows the top products as cards, the first on top', (
    tester,
  ) async {
    await pump(tester, deck());

    expect(find.byType(ProductDeckCard), findsNWidgets(3));
    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('Product 4'), findsNothing);
  });

  testWidgets('cards already swiped away are not shown', (tester) async {
    await pump(tester, deck(dismissed: {1, 2}));

    expect(find.text('Product 1'), findsNothing);
    expect(find.text('Product 3'), findsOneWidget);
  });

  testWidgets('the Like button throws the top card right and reports it', (
    tester,
  ) async {
    final intents = await pump(tester, deck());

    await tester.tap(find.byTooltip('Like'));
    await tester.pumpAndSettle();

    expect(
      intents.whereType<ProductSwiped>().single,
      ProductSwiped(products[0], SwipeDirection.right),
    );
  });

  testWidgets('the Skip button throws the top card left', (tester) async {
    final intents = await pump(tester, deck());

    await tester.tap(find.byTooltip('Skip'));
    await tester.pumpAndSettle();

    expect(
      intents.whereType<ProductSwiped>().single,
      ProductSwiped(products[0], SwipeDirection.left),
    );
  });

  testWidgets('dragging the card past the threshold swipes it', (tester) async {
    final intents = await pump(tester, deck());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Product 1')),
    );
    await gesture.moveBy(const Offset(220, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      intents.whereType<ProductSwiped>().single.direction,
      SwipeDirection.right,
    );
  });

  testWidgets('tapping the card opens the product', (tester) async {
    final intents = await pump(tester, deck());

    await tester.tap(find.text('Product 1'));

    expect(intents, contains(ProductSelected(products[0])));
  });

  testWidgets('the like counter reflects the likes', (tester) async {
    await pump(tester, deck(liked: {1, 2}));
    expect(find.text('2 liked'), findsOneWidget);
  });

  testWidgets('with no likes it says so', (tester) async {
    await pump(tester, deck());
    expect(find.text('No likes yet'), findsOneWidget);
  });

  testWidgets('asks for the next page when few cards remain', (tester) async {
    final intents = await pump(tester, deck(dismissed: {1, 2, 3, 4}));
    await tester.pump();

    expect(intents, contains(const ProductsNextPageRequested()));
  });

  testWidgets('a failed next page shows a retry', (tester) async {
    final intents = await pump(
      tester,
      deck(loadMoreFailure: const NetworkFailure()),
    );

    await tester.tap(find.text('Try again'));

    expect(intents.last, const ProductsNextPageRequested());
  });

  testWidgets('having seen everything offers to start over', (tester) async {
    final intents = await pump(
      tester,
      deck(dismissed: {for (final p in products) p.id}, reachedEnd: true),
    );
    await tester.pump();

    expect(find.text("You've seen everything"), findsOneWidget);
    await tester.tap(find.text('Start over'));
    expect(intents.last, const ProductsDeckRestarted());
  });

  testWidgets('everything swiped but more coming shows a loader, not the end', (
    tester,
  ) async {
    await pump(tester, deck(dismissed: {for (final p in products) p.id}));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Start over'), findsNothing);
  });

  testWidgets('the buttons keep their physical order in Hebrew', (
    tester,
  ) async {
    await pump(tester, deck(), locale: const Locale('he'));

    final skip = tester.getCenter(find.byTooltip('דלג'));
    final like = tester.getCenter(find.byTooltip('אהבתי'));
    expect(skip.dx, lessThan(like.dx), reason: 'skip left, like right');
  });
}
