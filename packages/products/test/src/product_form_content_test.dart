import 'package:core/core.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/presentation/form/product_form_content.dart';
import 'package:products/src/presentation/form/product_form_intent.dart';
import 'package:products/src/presentation/form/product_form_state.dart';
import 'package:products/testing.dart';

void main() {
  const loaded = CategoriesLoaded(categoryFixtures);

  Future<List<ProductFormIntent>> pump(
    WidgetTester tester,
    ProductFormState state, {
    Locale locale = const Locale('en'),
  }) async {
    final intents = <ProductFormIntent>[];
    await tester.pumpApp(
      ProductFormContent(state: state, onIntent: intents.add),
      locale: locale,
    );
    await tester.pump();
    return intents;
  }

  testWidgets('typing reports each field as an intent', (tester) async {
    final intents = await pump(
      tester,
      const ProductFormState(categories: loaded),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Hat');
    await tester.enterText(find.byType(TextField).at(1), '12.5');
    await tester.enterText(find.byType(TextField).at(2), 'Warm.');

    expect(intents, [
      const ProductFormTitleChanged('Hat'),
      const ProductFormPriceChanged('12.5'),
      const ProductFormDescriptionChanged('Warm.'),
    ]);
  });

  testWidgets('the price field only accepts digits and a dot', (tester) async {
    final intents = await pump(
      tester,
      const ProductFormState(categories: loaded),
    );

    await tester.enterText(find.byType(TextField).at(1), 'a1b2.5,c');

    expect(intents, [const ProductFormPriceChanged('12.5')]);
  });

  testWidgets('choosing a category reports it', (tester) async {
    final intents = await pump(
      tester,
      const ProductFormState(categories: loaded),
    );

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Electronics').last);
    await tester.pumpAndSettle();

    expect(intents, [const ProductFormCategorySelected(2)]);
  });

  testWidgets('shows validation errors in each field', (tester) async {
    await pump(
      tester,
      const ProductFormState(
        price: 'abc',
        showErrors: true,
        categories: loaded,
      ),
    );

    expect(find.text('This field is required'), findsWidgets);
    expect(find.text('Enter a valid number'), findsOneWidget);
    expect(find.text('Add at least one image'), findsOneWidget);
  });

  testWidgets('the primary button says create or save, and reports a submit', (
    tester,
  ) async {
    var intents = await pump(
      tester,
      const ProductFormState(categories: loaded),
    );
    expect(find.text('Create product'), findsOneWidget);
    await tester.ensureVisible(find.text('Create product'));
    await tester.tap(find.text('Create product'));
    expect(intents, [const ProductFormSubmitted()]);

    intents = await pump(
      tester,
      ProductFormState.editing(productFixture).copyWith(categories: loaded),
    );
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('editing pre-fills the fields', (tester) async {
    await pump(
      tester,
      ProductFormState.editing(productFixture).copyWith(categories: loaded),
    );

    expect(find.text('Classic Red Pullover Hoodie'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Clothes'), findsOneWidget);
  });

  testWidgets('submitting disables the form and shows progress', (
    tester,
  ) async {
    await pump(
      tester,
      const ProductFormState(categories: loaded, submit: SubmitInProgress()),
    );

    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a server rejection is shown with its messages', (tester) async {
    await pump(
      tester,
      const ProductFormState(
        categories: loaded,
        submit: SubmitFailed(
          ValidationFailure(messages: ['images must be URLs']),
        ),
      ),
    );

    expect(find.text('images must be URLs'), findsOneWidget);
  });

  group('categories', () {
    testWidgets('a failure to load them can be retried', (tester) async {
      final intents = await pump(
        tester,
        const ProductFormState(categories: CategoriesFailed(NetworkFailure())),
      );

      await tester.tap(find.text('Try again'));

      expect(intents, [const ProductFormStarted()]);
    });

    testWidgets('none at all explains why the product cannot be created', (
      tester,
    ) async {
      await pump(
        tester,
        const ProductFormState(categories: CategoriesLoaded([])),
      );

      expect(
        find.text(
          "There are no categories yet, so a product can't be created right now.",
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Create product'));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('while loading the button is disabled', (tester) async {
      await pump(tester, const ProductFormState());

      await tester.ensureVisible(find.text('Create product'));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  testWidgets('the upload photo button reports an upload request', (
    tester,
  ) async {
    final intents = await pump(
      tester,
      const ProductFormState(categories: loaded),
    );

    await tester.ensureVisible(find.text('Upload photo'));
    await tester.tap(find.text('Upload photo'));

    expect(intents, [const ProductFormPhotoUploadRequested()]);
  });

  testWidgets('renders in Hebrew', (tester) async {
    await pump(
      tester,
      const ProductFormState(categories: loaded),
      locale: const Locale('he'),
    );

    expect(find.text('יצירת מוצר'), findsOneWidget);
  });
}
