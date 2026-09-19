import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:products/src/presentation/detail/product_detail_bloc.dart';
import 'package:products/src/presentation/detail/product_detail_effect.dart';
import 'package:products/src/presentation/detail/product_detail_intent.dart';
import 'package:products/src/presentation/detail/product_detail_state.dart';

import '../support/fake_products_repository.dart';

void main() {
  late FakeProductsRepository repository;
  final seed = makeProducts(1, start: 7).single;

  setUp(() => repository = FakeProductsRepository([seed]));
  tearDown(() => repository.dispose());

  ProductDetailBloc build({Product? withSeed}) {
    final bloc = ProductDetailBloc(repository, productId: 7, seed: withSeed);
    addTearDown(bloc.close);
    return bloc;
  }

  List<ProductDetailEffect> collect(ProductDetailBloc bloc) {
    final effects = <ProductDetailEffect>[];
    final subscription = bloc.effects.listen(effects.add);
    addTearDown(subscription.cancel);
    return effects;
  }

  group('loading', () {
    test('with a seed it is ready immediately and refreshes quietly', () async {
      const fresh = Product(
        id: 7,
        title: 'Fresh title',
        price: 7,
        description: '',
        images: [],
      );
      repository.getProductResult = const Success(fresh);
      final bloc = build(withSeed: seed);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.product, seed);

      bloc.add(const ProductDetailStarted());
      await pumpEventQueue();

      expect(bloc.state.product, fresh);
      expect(repository.getProductCalls, [7]);
    });

    test('a failed refresh keeps the seed and shows no error', () async {
      repository.getProductResult = const Failed(NetworkFailure());
      final bloc = build(withSeed: seed);

      bloc.add(const ProductDetailStarted());
      await pumpEventQueue();

      expect(bloc.state.product, seed);
      expect(bloc.state.blockingFailure, isNull);
    });

    test('without a seed it loads from the server', () async {
      final bloc = build();
      expect(bloc.state.isLoading, isTrue);

      bloc.add(const ProductDetailStarted());
      await pumpEventQueue();

      expect(bloc.state.phase, ProductDetailPhase.ready);
      expect(bloc.state.product?.id, 7);
    });

    test('without a seed a failure blocks, and retrying recovers', () async {
      repository.getProductResult = const Failed(TimeoutFailure());
      final bloc = build();

      bloc.add(const ProductDetailStarted());
      await pumpEventQueue();
      expect(bloc.state.blockingFailure, const TimeoutFailure());

      repository.getProductResult = null;
      bloc.add(const ProductDetailStarted());
      await pumpEventQueue();
      expect(bloc.state.blockingFailure, isNull);
      expect(bloc.state.product?.id, 7);
    });
  });

  group('actions', () {
    test('edit opens the editor with the current product', () async {
      final bloc = build(withSeed: seed);
      final effects = collect(bloc);

      bloc.add(const ProductDetailEditTapped());
      await pumpEventQueue();

      expect(effects, [OpenProductEditor(seed)]);
    });

    test('edit and delete do nothing before a product is loaded', () async {
      final bloc = build();
      final effects = collect(bloc);

      bloc
        ..add(const ProductDetailEditTapped())
        ..add(const ProductDetailDeleteTapped());
      await pumpEventQueue();

      expect(effects, isEmpty);
      expect(bloc.state.canAct, isFalse);
    });

    test(
      'delete first asks for confirmation and deletes nothing yet',
      () async {
        final bloc = build(withSeed: seed);
        final effects = collect(bloc);

        bloc.add(const ProductDetailDeleteTapped());
        await pumpEventQueue();

        expect(effects, [ConfirmProductDeletion(seed)]);
        expect(repository.deleted, isEmpty);
      },
    );
  });

  group('deleting', () {
    test('a confirmed delete closes the screen once', () async {
      final bloc = build(withSeed: seed);
      final effects = collect(bloc);

      bloc.add(const ProductDetailDeleteConfirmed());
      await pumpEventQueue();

      expect(repository.deleted, [7]);
      expect(effects, [
        const CloseProductDetail(deletedByUser: true),
      ], reason: 'the repository change for our own delete is ignored');
    });

    test('a failed delete stays on the screen and reports why', () async {
      repository.deleteResult = const Failed(NetworkFailure());
      final bloc = build(withSeed: seed);
      final effects = collect(bloc);

      bloc.add(const ProductDetailDeleteConfirmed());
      await pumpEventQueue();

      expect(bloc.state.isDeleting, isFalse);
      expect(effects, [const ProductDeletionFailed(NetworkFailure())]);
    });

    test(
      'is blocked while deleting, and a double confirm deletes once',
      () async {
        repository.holdNextMutation = Completer<void>();
        final hold = repository.holdNextMutation!;
        final bloc = build(withSeed: seed);

        bloc
          ..add(const ProductDetailDeleteConfirmed())
          ..add(const ProductDetailDeleteConfirmed());
        await pumpEventQueue();
        expect(bloc.state.isDeleting, isTrue);
        expect(bloc.state.canAct, isFalse);
        hold.complete();
        await pumpEventQueue();

        expect(repository.deleted, [7]);
      },
    );
  });

  group('changes from elsewhere', () {
    test('an update to this product replaces it', () async {
      final bloc = build(withSeed: seed);
      const renamed = Product(
        id: 7,
        title: 'Renamed',
        price: 1,
        description: '',
        images: [],
      );

      repository.publish(const ProductUpdated(renamed));
      await pumpEventQueue();

      expect(bloc.state.product, renamed);
    });

    test('updates and deletes of other products are ignored', () async {
      final bloc = build(withSeed: seed);
      final effects = collect(bloc);

      repository.publish(ProductUpdated(makeProducts(1, start: 8).single));
      repository.publish(const ProductDeleted(8));
      await pumpEventQueue();

      expect(bloc.state.product, seed);
      expect(effects, isEmpty);
    });

    test('this product deleted elsewhere closes the screen', () async {
      final bloc = build(withSeed: seed);
      final effects = collect(bloc);

      repository.publish(const ProductDeleted(7));
      await pumpEventQueue();

      expect(effects, [const CloseProductDetail(deletedByUser: false)]);
    });
  });
}
