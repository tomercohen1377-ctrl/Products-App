import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:products/src/presentation/form/product_form_bloc.dart';
import 'package:products/src/presentation/form/product_form_effect.dart';
import 'package:products/src/presentation/form/product_form_intent.dart';
import 'package:products/src/presentation/form/product_form_state.dart';

import '../support/fake_products_repository.dart';

void main() {
  late FakeProductsRepository repository;

  setUp(() => repository = FakeProductsRepository());
  tearDown(() => repository.dispose());

  ProductFormBloc build({Product? editing}) {
    final bloc = ProductFormBloc(repository, editing: editing);
    addTearDown(bloc.close);
    return bloc;
  }

  List<ProductFormEffect> collect(ProductFormBloc bloc) {
    final effects = <ProductFormEffect>[];
    final subscription = bloc.effects.listen(effects.add);
    addTearDown(subscription.cancel);
    return effects;
  }

  /// Fills every field with valid data (after categories have loaded).
  Future<ProductFormBloc> filled({Product? editing}) async {
    final bloc = build(editing: editing)..add(const ProductFormStarted());
    await pumpEventQueue();
    bloc
      ..add(const ProductFormTitleChanged('  Hat  '))
      ..add(const ProductFormPriceChanged('12.5'))
      ..add(const ProductFormDescriptionChanged('Warm.'))
      ..add(const ProductFormCategorySelected(2))
      ..add(const ProductFormImageAdded('https://i.imgur.com/a.jpeg'));
    await pumpEventQueue();
    return bloc;
  }

  group('initial state', () {
    test('creating starts empty, with categories loading', () {
      final state = build().state;

      expect(state.isEditing, isFalse);
      expect(state.title, isEmpty);
      expect(state.categories, isA<CategoriesLoading>());
    });

    test('editing is pre-filled from the product', () {
      const product = Product(
        id: 9,
        title: 'Cap',
        price: 79,
        description: 'A cap.',
        images: ['https://i.imgur.com/c.jpeg'],
        category: Category(id: 2, name: 'Shoes'),
      );

      final state = build(editing: product).state;

      expect(state.isEditing, isTrue);
      expect(state.editingId, 9);
      expect(state.title, 'Cap');
      expect(state.price, '79', reason: 'whole prices have no ".0"');
      expect(state.description, 'A cap.');
      expect(state.categoryId, 2);
      expect(state.images, ['https://i.imgur.com/c.jpeg']);
    });

    test('fractional prices keep their decimals', () {
      const product = Product(
        id: 1,
        title: 't',
        price: 79.5,
        description: 'd',
        images: [],
      );

      expect(build(editing: product).state.price, '79.5');
    });
  });

  group('categories', () {
    test('load into the form', () async {
      final bloc = build()..add(const ProductFormStarted());
      await pumpEventQueue();

      expect(bloc.state.categories, isA<CategoriesLoaded>());
      expect(bloc.state.hasCategories, isTrue);
    });

    test('a failure can be retried', () async {
      repository.categoriesResult = const Failed(NetworkFailure());
      final bloc = build()..add(const ProductFormStarted());
      await pumpEventQueue();
      expect(bloc.state.categories, const CategoriesFailed(NetworkFailure()));

      repository.categoriesResult = const Success([Category(id: 1, name: 'A')]);
      bloc.add(const ProductFormStarted());
      await pumpEventQueue();
      expect(bloc.state.hasCategories, isTrue);
    });

    test('none at all means the form cannot be submitted', () async {
      repository.categoriesResult = const Success([]);
      final bloc = build()..add(const ProductFormStarted());
      await pumpEventQueue();
      expect(bloc.state.hasCategories, isFalse);

      bloc.add(const ProductFormSubmitted());
      await pumpEventQueue();

      expect(repository.created, isEmpty);
      expect(bloc.state.showErrors, isFalse);
    });
  });

  group('validation', () {
    test('errors stay hidden until the first submit', () async {
      final bloc = build()..add(const ProductFormStarted());
      await pumpEventQueue();

      expect(bloc.state.titleError, isNull);
      expect(bloc.state.isValid, isFalse);
    });

    test(
      'submitting an empty form shows every error and sends nothing',
      () async {
        final bloc = build()..add(const ProductFormStarted());
        await pumpEventQueue();

        bloc.add(const ProductFormSubmitted());
        await pumpEventQueue();

        final state = bloc.state;
        expect(state.showErrors, isTrue);
        expect(state.titleError, FieldError.required);
        expect(state.priceError, FieldError.required);
        expect(state.descriptionError, FieldError.required);
        expect(state.categoryError, FieldError.required);
        expect(state.imagesError, FieldError.required);
        expect(repository.created, isEmpty);
      },
    );

    test('a bad price is reported once errors are visible', () async {
      final bloc = await filled();
      bloc.add(const ProductFormPriceChanged('-3'));
      bloc.add(const ProductFormSubmitted());
      await pumpEventQueue();

      expect(bloc.state.priceError, FieldError.notPositive);
      expect(repository.created, isEmpty);
    });
  });

  group('images', () {
    Future<ProductFormBloc> started() async {
      final bloc = build()..add(const ProductFormStarted());
      await pumpEventQueue();
      return bloc;
    }

    test('adds a valid url', () async {
      final bloc = await started();

      bloc.add(const ProductFormImageAdded('  https://i.imgur.com/a.jpeg  '));
      await pumpEventQueue();

      expect(bloc.state.images, ['https://i.imgur.com/a.jpeg']);
      expect(bloc.state.imageUrlError, isNull);
    });

    test('rejects something that is not an http(s) url', () async {
      final bloc = await started();

      bloc.add(const ProductFormImageAdded('not a url'));
      await pumpEventQueue();

      expect(bloc.state.images, isEmpty);
      expect(bloc.state.imageUrlError, FieldError.invalidUrl);

      bloc.add(const ProductFormImageAdded('https://i.imgur.com/a.jpeg'));
      await pumpEventQueue();
      expect(bloc.state.imageUrlError, isNull, reason: 'cleared by a good one');
    });

    test('ignores a duplicate', () async {
      final bloc = await started();

      bloc
        ..add(const ProductFormImageAdded('https://i.imgur.com/a.jpeg'))
        ..add(const ProductFormImageAdded('https://i.imgur.com/a.jpeg'));
      await pumpEventQueue();

      expect(bloc.state.images, hasLength(1));
    });

    test('removes an image', () async {
      final bloc = await started();
      bloc
        ..add(const ProductFormImageAdded('https://i.imgur.com/a.jpeg'))
        ..add(const ProductFormImageAdded('https://i.imgur.com/b.jpeg'));
      await pumpEventQueue();

      bloc.add(const ProductFormImageRemoved('https://i.imgur.com/a.jpeg'));
      await pumpEventQueue();

      expect(bloc.state.images, ['https://i.imgur.com/b.jpeg']);
    });
  });

  group('submitting', () {
    test(
      'creating sends the trimmed draft and reports the saved product',
      () async {
        final bloc = await filled();
        final effects = collect(bloc);

        bloc.add(const ProductFormSubmitted());
        await pumpEventQueue();

        expect(repository.created, [
          const ProductDraft(
            title: 'Hat',
            price: 12.5,
            description: 'Warm.',
            categoryId: 2,
            images: ['https://i.imgur.com/a.jpeg'],
          ),
        ]);
        expect(effects.single, isA<ProductSaved>());
        expect(bloc.state.isSubmitting, isFalse);
        expect(repository.updated, isEmpty);
      },
    );

    test('editing updates that product instead of creating one', () async {
      const editing = Product(
        id: 9,
        title: 'Cap',
        price: 79,
        description: 'A cap.',
        images: ['https://i.imgur.com/c.jpeg'],
        category: Category(id: 2, name: 'Shoes'),
      );
      final bloc = build(editing: editing)..add(const ProductFormStarted());
      await pumpEventQueue();
      final effects = collect(bloc);

      bloc
        ..add(const ProductFormTitleChanged('Better cap'))
        ..add(const ProductFormSubmitted());
      await pumpEventQueue();

      expect(repository.created, isEmpty);
      expect(repository.updated.single.id, 9);
      expect(repository.updated.single.draft.title, 'Better cap');
      expect(effects.single, isA<ProductSaved>());
    });

    test('a server rejection shows its messages and keeps the form', () async {
      repository.createResult = const Failed(
        ValidationFailure(messages: ['images must be URLs']),
      );
      final bloc = await filled();
      final effects = collect(bloc);

      bloc.add(const ProductFormSubmitted());
      await pumpEventQueue();

      expect(
        bloc.state.submitFailure,
        const ValidationFailure(messages: ['images must be URLs']),
      );
      expect(bloc.state.title, '  Hat  ');
      expect(effects, isEmpty);
    });

    test('editing a field hides the previous failure', () async {
      repository.createResult = const Failed(NetworkFailure());
      final bloc = await filled();
      bloc.add(const ProductFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.submitFailure, isNotNull);

      bloc.add(const ProductFormTitleChanged('Hat 2'));
      await pumpEventQueue();

      expect(bloc.state.submitFailure, isNull);
    });

    test('a double tap creates once', () async {
      repository.holdNextMutation = Completer<void>();
      final hold = repository.holdNextMutation!;
      final bloc = await filled();

      bloc
        ..add(const ProductFormSubmitted())
        ..add(const ProductFormSubmitted())
        ..add(const ProductFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.isSubmitting, isTrue);
      hold.complete();
      await pumpEventQueue();

      expect(repository.created, hasLength(1));
    });
  });
}
