import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';

import 'support/app_harness.dart';

/// The product requirements, end to end through the real app: browse, view,
/// create, edit and delete, against an in-memory backend with real semantics.
void main() {
  Future<AppHarness> launch(WidgetTester tester) async {
    final h = AppHarness(signedIn: true);
    await h.launch(tester);
    return h;
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  Future<void> fillForm(
    WidgetTester tester, {
    String title = 'Brand new cap',
    String price = '42.5',
    String description = 'A very nice cap.',
    String category = 'Clothes',
    String image = 'https://i.imgur.com/mp3rUty.jpeg',
  }) async {
    await tester.enterText(field('Title'), title);
    await tester.enterText(field('Price'), price);
    await tester.enterText(field('Description'), description);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(category).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(field('Image URL'));
    await tester.enterText(field('Image URL'), image);
    await tester.tap(find.byTooltip('Add image'));
    await tester.settleApp();
  }

  Future<void> submit(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.settleApp();
  }

  testWidgets('the list shows the products and opens a detail page', (
    tester,
  ) async {
    await launch(tester);
    expect(find.text('Fixture Hat'), findsOneWidget);
    expect(find.text('Fixture Shoe'), findsOneWidget);

    await tester.tap(find.text('Fixture Hat'));
    await tester.settleApp();

    expect(find.text('Fixture Hat'), findsOneWidget);
    expect(find.text('Fixture Hat description'), findsOneWidget);
    expect(find.text(r'$10'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsOneWidget);

    await tester.pageBack();
    await tester.settleApp();
    expect(find.text('Fixture Shoe'), findsOneWidget);
  });

  group('create', () {
    testWidgets('creates a product and shows it at the top of the list', (
      tester,
    ) async {
      final h = await launch(tester);

      await tester.tap(find.byTooltip('Add product'));
      await tester.settleApp();
      expect(find.text('New product'), findsOneWidget);

      await fillForm(tester);
      await submit(tester, 'Create product');

      expect(find.text('Product saved'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Brand new cap'), findsOneWidget);
      expect(h.backend.createdBodies.single, {
        'title': 'Brand new cap',
        'price': 42.5,
        'description': 'A very nice cap.',
        'categoryId': 1,
        'images': ['https://i.imgur.com/mp3rUty.jpeg'],
      });
      final titles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .toList();
      expect(
        titles.indexOf('Brand new cap'),
        lessThan(titles.indexOf('Fixture Hat')),
        reason: 'new products appear first',
      );
    });

    testWidgets('an incomplete form shows errors and creates nothing', (
      tester,
    ) async {
      final h = await launch(tester);
      await tester.tap(find.byTooltip('Add product'));
      await tester.settleApp();

      await submit(tester, 'Create product');

      expect(find.text('This field is required'), findsWidgets);
      expect(find.text('Add at least one image'), findsOneWidget);
      expect(h.backend.createdBodies, isEmpty);
      expect(find.text('New product'), findsOneWidget);
    });

    testWidgets('a server rejection keeps the form and explains why', (
      tester,
    ) async {
      final h = await launch(tester);
      h.backend.failNextMutation = const FakeResponse.json({
        'message': ['images must be valid URLs'],
      }, status: 400);
      await tester.tap(find.byTooltip('Add product'));
      await tester.settleApp();
      await fillForm(tester);

      await submit(tester, 'Create product');

      expect(find.text('images must be valid URLs'), findsOneWidget);
      expect(find.text('New product'), findsOneWidget);
      expect(find.text('Brand new cap'), findsOneWidget, reason: 'input kept');
    });
  });

  group('edit', () {
    testWidgets(
      'edits a product and both the detail page and the list update',
      (tester) async {
        final h = await launch(tester);
        await tester.tap(find.text('Fixture Hat'));
        await tester.settleApp();

        await tester.tap(find.byTooltip('Edit'));
        await tester.settleApp();
        expect(find.text('Edit product'), findsOneWidget);
        expect(find.text('Fixture Hat'), findsOneWidget, reason: 'pre-filled');
        await tester.enterText(field('Title'), 'Better Hat');
        await submit(tester, 'Save changes');

        expect(find.text('Product saved'), findsOneWidget);
        expect(
          find.text('Better Hat'),
          findsOneWidget,
          reason: 'detail refreshed',
        );
        expect(h.backend.updatedBodies.single['title'], 'Better Hat');

        await tester.pageBack();
        await tester.settleApp();
        expect(find.text('Better Hat'), findsOneWidget);
        expect(find.text('Fixture Hat'), findsNothing);
      },
    );
  });

  group('delete', () {
    testWidgets(
      'deletes a product after confirmation and returns to the list',
      (tester) async {
        final h = await launch(tester);
        await tester.tap(find.text('Fixture Hat'));
        await tester.settleApp();

        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();
        expect(find.text('Delete this product?'), findsOneWidget);
        await tester.tap(find.text('Delete').last);
        await tester.settleApp();

        expect(h.backend.deletedIds, [1]);
        expect(find.text('Product deleted'), findsOneWidget);
        expect(find.text('Fixture Hat'), findsNothing);
        expect(find.text('Fixture Shoe'), findsOneWidget);
      },
    );

    testWidgets('cancelling the confirmation deletes nothing', (tester) async {
      final h = await launch(tester);
      await tester.tap(find.text('Fixture Hat'));
      await tester.settleApp();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.settleApp();

      expect(h.backend.deletedIds, isEmpty);
      expect(find.byTooltip('Edit'), findsOneWidget, reason: 'still on detail');
    });

    testWidgets('a failed delete stays on the page and tells the user', (
      tester,
    ) async {
      final h = await launch(tester);
      h.backend.failNextMutation = const FakeResponse.status(500);
      await tester.tap(find.text('Fixture Hat'));
      await tester.settleApp();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.settleApp();

      expect(find.textContaining('server had a problem'), findsOneWidget);
      expect(find.byTooltip('Edit'), findsOneWidget, reason: 'still on detail');
      expect(h.backend.products.any((p) => p['id'] == 1), isTrue);
    });
  });

  testWidgets('the account button signs out from the products screen', (
    tester,
  ) async {
    await launch(tester);

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.settleApp();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  group('deck', () {
    Future<void> openDeck(WidgetTester tester) async {
      await tester.tap(find.text('Deck'));
      await tester.settleApp();
    }

    testWidgets('switching to the deck shows the products as cards', (
      tester,
    ) async {
      await launch(tester);

      await openDeck(tester);

      expect(find.text('Fixture Hat'), findsOneWidget);
      expect(find.text('No likes yet'), findsOneWidget);
      expect(find.byTooltip('Like'), findsOneWidget);

      await tester.tap(find.text('List'));
      await tester.settleApp();
      expect(find.byTooltip('Like'), findsNothing);
      expect(find.text('Fixture Shoe'), findsOneWidget);
    });

    testWidgets('liking and skipping advance the deck and count the likes', (
      tester,
    ) async {
      await launch(tester);
      await openDeck(tester);

      await tester.tap(find.byTooltip('Like'));
      await tester.settleApp();
      expect(find.text('1 liked'), findsOneWidget);
      expect(
        find.text('Fixture Shoe'),
        findsOneWidget,
        reason: 'next card is on top',
      );

      await tester.tap(find.byTooltip('Skip'));
      await tester.settleApp();
      expect(find.text("You've seen everything"), findsOneWidget);
      expect(
        find.text('Fixture Shoe'),
        findsNothing,
        reason: 'the skipped card is gone',
      );
    });

    testWidgets('a real drag gesture throws a card', (tester) async {
      await launch(tester);
      await openDeck(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Fixture Hat')),
      );
      await gesture.moveBy(const Offset(250, 0));
      await gesture.up();
      await tester.settleApp();

      expect(find.text('1 liked'), findsOneWidget);
    });

    testWidgets('seeing every card offers to start over', (tester) async {
      await launch(tester);
      await openDeck(tester);

      await tester.tap(find.byTooltip('Like'));
      await tester.settleApp();
      await tester.tap(find.byTooltip('Skip'));
      await tester.settleApp();

      expect(find.text("You've seen everything"), findsOneWidget);
      await tester.tap(find.text('Start over'));
      await tester.settleApp();
      expect(find.text('Fixture Hat'), findsOneWidget);
      expect(find.text('1 liked'), findsOneWidget, reason: 'likes are kept');
    });

    testWidgets(
      'tapping a card opens the product, and back returns to the deck',
      (tester) async {
        await launch(tester);
        await openDeck(tester);

        await tester.tap(find.text('Fixture Hat'));
        await tester.settleApp();
        expect(find.byTooltip('Edit'), findsOneWidget);

        await tester.pageBack();
        await tester.settleApp();
        expect(
          find.byTooltip('Like'),
          findsOneWidget,
          reason: 'still in deck mode',
        );
      },
    );

    testWidgets('a product created while in the deck lands on top of it', (
      tester,
    ) async {
      await launch(tester);
      await openDeck(tester);

      await tester.tap(find.byTooltip('Add product'));
      await tester.settleApp();
      await fillForm(tester);
      await submit(tester, 'Create product');

      expect(find.text('Brand new cap'), findsOneWidget);
      expect(find.byTooltip('Like'), findsOneWidget);
    });

    testWidgets('a product deleted from the deck is gone from it', (
      tester,
    ) async {
      await launch(tester);
      await openDeck(tester);

      await tester.tap(find.text('Fixture Hat'));
      await tester.settleApp();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.settleApp();

      expect(find.text('Fixture Hat'), findsNothing);
      expect(find.text('Fixture Shoe'), findsOneWidget);
      expect(find.byTooltip('Like'), findsOneWidget);
    });
  });
}
