import 'package:core/core.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/presentation/detail/product_detail_content.dart';
import 'package:products/src/presentation/detail/product_detail_intent.dart';
import 'package:products/src/presentation/detail/product_detail_state.dart';
import 'package:products/testing.dart';

void main() {
  const ready = ProductDetailState(
    phase: ProductDetailPhase.ready,
    product: productFixture,
  );

  Future<List<ProductDetailIntent>> pump(
    WidgetTester tester,
    ProductDetailState state, {
    Locale locale = const Locale('en'),
  }) async {
    final intents = <ProductDetailIntent>[];
    await tester.pumpApp(
      ProductDetailContent(state: state, onIntent: intents.add),
      locale: locale,
    );
    await tester.pump(const Duration(milliseconds: 250));
    return intents;
  }

  testWidgets('shows the product', (tester) async {
    await pump(tester, ready);

    expect(find.text('Classic Red Pullover Hoodie'), findsOneWidget);
    expect(find.text('Clothes'), findsOneWidget);
    expect(find.text(r'$10'), findsOneWidget);
    expect(
      find.textContaining('Crafted with a soft cotton blend'),
      findsOneWidget,
    );
  });

  testWidgets('shows a loader while loading with nothing to show', (
    tester,
  ) async {
    await pump(tester, const ProductDetailState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a blocking failure offers a retry', (tester) async {
    final intents = await pump(
      tester,
      const ProductDetailState(
        phase: ProductDetailPhase.failure,
        failure: NetworkFailure(),
      ),
    );

    await tester.tap(find.text('Try again'));

    expect(intents, [const ProductDetailStarted()]);
  });

  testWidgets('shows progress while deleting', (tester) async {
    await pump(tester, ready.copyWith(isDeleting: true));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('renders in Hebrew', (tester) async {
    await pump(tester, ready, locale: const Locale('he'));

    expect(find.text('Classic Red Pullover Hoodie'), findsOneWidget);
  });

  group('actions', () {
    testWidgets('report edit and delete', (tester) async {
      final intents = <ProductDetailIntent>[];
      await tester.pumpApp(
        ProductDetailActions(state: ready, onIntent: intents.add),
      );

      await tester.tap(find.byTooltip('Edit'));
      await tester.tap(find.byTooltip('Delete'));

      expect(intents, [
        const ProductDetailEditTapped(),
        const ProductDetailDeleteTapped(),
      ]);
    });

    testWidgets('are disabled until there is a product, and while deleting', (
      tester,
    ) async {
      for (final state in [
        const ProductDetailState(),
        ready.copyWith(isDeleting: true),
      ]) {
        await tester.pumpApp(
          ProductDetailActions(state: state, onIntent: (_) {}),
        );
        final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
        expect(buttons.map((b) => b.onPressed), everyElement(isNull));
      }
    });
  });
}
