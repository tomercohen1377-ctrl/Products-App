import 'package:core/core.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/presentation/list/products_content.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';
import 'package:products/src/presentation/widgets/product_tile.dart';

import '../support/fake_products_repository.dart';

void main() {
  ProductsState ready({
    int count = 3,
    bool hasReachedEnd = true,
    bool isLoadingMore = false,
    Failure? loadMoreFailure,
  }) => ProductsState(
    phase: ProductsPhase.ready,
    items: makeProducts(count),
    nextOffset: count,
    hasReachedEnd: hasReachedEnd,
    isLoadingMore: isLoadingMore,
    loadMoreFailure: loadMoreFailure,
  );

  Future<List<ProductsIntent>> pump(
    WidgetTester tester,
    ProductsState state, {
    Locale locale = const Locale('en'),
  }) async {
    final intents = <ProductsIntent>[];
    await tester.pumpApp(
      ProductsContent(state: state, onIntent: intents.add),
      locale: locale,
    );
    return intents;
  }

  testWidgets('shows a loader during the first load', (tester) async {
    await pump(tester, const ProductsState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ProductTile), findsNothing);
  });

  testWidgets('a failed first load offers a retry', (tester) async {
    final intents = await pump(
      tester,
      const ProductsState(
        phase: ProductsPhase.failure,
        failure: NetworkFailure(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    expect(intents, [const ProductsStarted()]);
  });

  testWidgets('an empty list explains itself and can be refreshed', (
    tester,
  ) async {
    final intents = await pump(tester, ready(count: 0));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('No products yet'), findsOneWidget);
    await tester.tap(find.text('Refresh'));
    expect(intents, [const ProductsStarted()]);
  });

  testWidgets('shows a tile per product', (tester) async {
    await pump(tester, ready());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(ProductTile), findsNWidgets(3));
    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('Product 3'), findsOneWidget);
  });

  testWidgets('shows a spinner footer while loading more', (tester) async {
    await pump(tester, ready(hasReachedEnd: false, isLoadingMore: true));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a failed next page shows a retry that asks for it again', (
    tester,
  ) async {
    final intents = await pump(
      tester,
      ready(hasReachedEnd: false, loadMoreFailure: const TimeoutFailure()),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('Try again'));
    expect(intents, [const ProductsNextPageRequested()]);
  });

  testWidgets('asks for the next page when the list is too short to scroll', (
    tester,
  ) async {
    final intents = await pump(tester, ready(hasReachedEnd: false));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(intents, contains(const ProductsNextPageRequested()));
  });

  testWidgets('asks for the next page near the end of a long list', (
    tester,
  ) async {
    final intents = await pump(tester, ready(count: 40, hasReachedEnd: false));
    await tester.pump(const Duration(milliseconds: 250));
    expect(intents, isEmpty);

    await tester.drag(find.byType(ListView), const Offset(0, -6000));
    await tester.pump();

    expect(intents, contains(const ProductsNextPageRequested()));
  });

  testWidgets('never asks for more once the end is reached', (tester) async {
    final intents = await pump(tester, ready());
    await tester.pump(const Duration(milliseconds: 250));

    expect(intents, isEmpty);
  });

  testWidgets('renders in Hebrew', (tester) async {
    await pump(tester, ready(count: 0), locale: const Locale('he'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('אין מוצרים עדיין'), findsOneWidget);
  });
}
