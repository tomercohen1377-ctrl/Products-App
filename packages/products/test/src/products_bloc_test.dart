import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart' show SwipeDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:products/src/presentation/list/products_bloc.dart';
import 'package:products/src/presentation/list/products_effect.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';

import '../support/fake_products_repository.dart';

void main() {
  const pageSize = 3;
  late FakeProductsRepository repository;

  setUp(() => repository = FakeProductsRepository());
  tearDown(() => repository.dispose());

  ProductsBloc build() => ProductsBloc(repository, pageSize: pageSize);

  ProductsState ready(
    List<Product> items, {
    required int nextOffset,
    bool hasReachedEnd = false,
    bool isLoadingMore = false,
    bool isRefreshing = false,
    Failure? loadMoreFailure,
  }) => ProductsState(
    phase: ProductsPhase.ready,
    items: items,
    nextOffset: nextOffset,
    hasReachedEnd: hasReachedEnd,
    isLoadingMore: isLoadingMore,
    isRefreshing: isRefreshing,
    loadMoreFailure: loadMoreFailure,
  );

  test('starts in the loading phase', () {
    final state = build().state;
    expect(state.isInitialLoading, isTrue);
    expect(state.items, isEmpty);
  });

  group('first load', () {
    blocTest<ProductsBloc, ProductsState>(
      'a full page means there may be more',
      setUp: () => repository.server = makeProducts(7),
      build: build,
      act: (bloc) => bloc.add(const ProductsStarted()),
      expect: () => [
        const ProductsState(),
        ready(makeProducts(3), nextOffset: 3),
      ],
      verify: (_) => expect(repository.requests, [(offset: 0, limit: 3)]),
    );

    blocTest<ProductsBloc, ProductsState>(
      'a short page is the end of the list',
      setUp: () => repository.server = makeProducts(2),
      build: build,
      act: (bloc) => bloc.add(const ProductsStarted()),
      expect: () => [
        const ProductsState(),
        ready(makeProducts(2), nextOffset: 2, hasReachedEnd: true),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'no products is a ready, empty list',
      build: build,
      act: (bloc) => bloc.add(const ProductsStarted()),
      expect: () => [
        const ProductsState(),
        ready(const [], nextOffset: 0, hasReachedEnd: true),
      ],
      verify: (bloc) => expect(bloc.state.isEmpty, isTrue),
    );

    blocTest<ProductsBloc, ProductsState>(
      'failure shows a blocking error, and retrying recovers',
      setUp: () {
        repository.server = makeProducts(2);
        repository.queued.add(const Failed(NetworkFailure()));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ProductsStarted());
        await pumpEventQueue();
        bloc.add(const ProductsStarted());
      },
      expect: () => [
        const ProductsState(),
        const ProductsState(
          phase: ProductsPhase.failure,
          failure: NetworkFailure(),
        ),
        // Retrying resets to loading first.
        const ProductsState(),
        ready(makeProducts(2), nextOffset: 2, hasReachedEnd: true),
      ],
    );
  });

  group('next page', () {
    Future<ProductsBloc> started({int serverSize = 8}) async {
      repository.server = makeProducts(serverSize);
      final bloc = build()..add(const ProductsStarted());
      await pumpEventQueue();
      repository.requests.clear();
      addTearDown(bloc.close);
      return bloc;
    }

    test('appends the next page at the right offset', () async {
      final bloc = await started();

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();

      expect(repository.requests, [(offset: 3, limit: 3)]);
      expect(bloc.state.items.map((p) => p.id), [1, 2, 3, 4, 5, 6]);
      expect(bloc.state.nextOffset, 6);
      expect(bloc.state.isLoadingMore, isFalse);
      expect(bloc.state.hasReachedEnd, isFalse);
    });

    test(
      'a short page ends the list, and no further page is requested',
      () async {
        final bloc = await started();

        bloc
          ..add(const ProductsNextPageRequested())
          ..add(const ProductsNextPageRequested());
        await pumpEventQueue();
        bloc.add(const ProductsNextPageRequested());
        await pumpEventQueue();

        expect(bloc.state.items, hasLength(8));
        expect(bloc.state.hasReachedEnd, isTrue);
        expect(repository.requests.map((r) => r.offset), [3, 6]);
      },
    );

    test('a second request while one is loading is dropped', () async {
      final bloc = await started();
      repository.holdNext = Completer<void>();
      final hold = repository.holdNext!;

      bloc
        ..add(const ProductsNextPageRequested())
        ..add(const ProductsNextPageRequested())
        ..add(const ProductsNextPageRequested());
      await pumpEventQueue();
      expect(bloc.state.isLoadingMore, isTrue);
      hold.complete();
      await pumpEventQueue();

      expect(repository.requests, hasLength(1));
      expect(bloc.state.items, hasLength(6));
    });

    test('skips products that are already in the list', () async {
      final bloc = await started();
      repository.publish(ProductCreated(makeProducts(1, start: 4).single));
      await pumpEventQueue();
      expect(bloc.state.items.map((p) => p.id), [4, 1, 2, 3]);

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();

      expect(bloc.state.items.map((p) => p.id), [4, 1, 2, 3, 5, 6]);
      expect(bloc.state.nextOffset, 6, reason: 'the server page still counts');
    });

    test('a failure keeps the list, and asking again retries', () async {
      final bloc = await started();
      repository.queued.add(const Failed(TimeoutFailure()));

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();
      expect(bloc.state.items, hasLength(3));
      expect(bloc.state.loadMoreFailure, const TimeoutFailure());
      expect(bloc.state.isLoadingMore, isFalse);

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();
      expect(bloc.state.items, hasLength(6));
      expect(bloc.state.loadMoreFailure, isNull);
    });

    test('is ignored before the first page has loaded', () async {
      final bloc = build();
      addTearDown(bloc.close);

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();

      expect(repository.requests, isEmpty);
    });
  });

  group('refresh', () {
    Future<ProductsBloc> started() async {
      repository.server = makeProducts(8);
      final bloc = build()..add(const ProductsStarted());
      await pumpEventQueue();
      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();
      repository.requests.clear();
      addTearDown(bloc.close);
      return bloc;
    }

    test('reloads from the start and resets paging', () async {
      final bloc = await started();
      repository.server = makeProducts(2, start: 100);

      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();

      expect(repository.requests, [(offset: 0, limit: 3)]);
      expect(bloc.state.items.map((p) => p.id), [100, 101]);
      expect(bloc.state.nextOffset, 2);
      expect(bloc.state.hasReachedEnd, isTrue);
      expect(bloc.state.isRefreshing, isFalse);
    });

    test('keeps the list on screen while refreshing', () async {
      final bloc = await started();
      repository.holdNext = Completer<void>();
      final hold = repository.holdNext!;

      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();

      expect(bloc.state.isRefreshing, isTrue);
      expect(bloc.state.items, hasLength(6));
      hold.complete();
      await pumpEventQueue();
    });

    test('a failed refresh keeps the list and reports an effect', () async {
      final bloc = await started();
      final effects = <ProductsEffect>[];
      final subscription = bloc.effects.listen(effects.add);
      addTearDown(subscription.cancel);
      repository.queued.add(const Failed(NetworkFailure()));

      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();

      expect(bloc.state.items, hasLength(6));
      expect(bloc.state.isRefreshing, isFalse);
      expect(effects, [const ProductsRefreshFailed(NetworkFailure())]);
    });

    test('a newer refresh supersedes an older one', () async {
      final bloc = await started();
      repository.holdNext = Completer<void>();
      final firstHold = repository.holdNext!;
      repository.queued.add(Success(makeProducts(1, start: 500)));

      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();
      repository.server = makeProducts(2, start: 900);
      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();
      firstHold.complete();
      await pumpEventQueue();

      expect(bloc.state.items.map((p) => p.id), [900, 901]);
    });

    test(
      'a next page still in flight when a refresh succeeds is discarded',
      () async {
        final bloc = await started();
        repository.server = makeProducts(20, start: 200);
        repository.holdNext = Completer<void>();
        final hold = repository.holdNext!;

        bloc.add(const ProductsNextPageRequested());
        await pumpEventQueue();
        bloc.add(const ProductsRefreshed());
        await pumpEventQueue();
        hold.complete();
        await pumpEventQueue();

        expect(bloc.state.items.map((p) => p.id), [200, 201, 202]);
        expect(bloc.state.isLoadingMore, isFalse);
      },
    );

    test('a next page in flight survives a refresh that fails', () async {
      final bloc = await started();
      repository.holdNext = Completer<void>();
      final hold = repository.holdNext!;

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();
      repository.queued.add(const Failed(NetworkFailure()));
      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();
      hold.complete();
      await pumpEventQueue();

      expect(bloc.state.items, hasLength(8));
      expect(bloc.state.isLoadingMore, isFalse);
    });
  });

  group('changes from elsewhere', () {
    Future<ProductsBloc> started() async {
      repository.server = makeProducts(8);
      final bloc = build()..add(const ProductsStarted());
      await pumpEventQueue();
      repository.requests.clear();
      addTearDown(bloc.close);
      return bloc;
    }

    test(
      'a created product appears at the top; a duplicate is ignored',
      () async {
        final bloc = await started();
        final created = makeProducts(1, start: 99).single;

        repository.publish(ProductCreated(created));
        repository.publish(ProductCreated(created));
        await pumpEventQueue();

        expect(bloc.state.items.map((p) => p.id), [99, 1, 2, 3]);
        expect(bloc.state.nextOffset, 3, reason: 'server offset is unchanged');
      },
    );

    test('an updated product is replaced in place', () async {
      final bloc = await started();
      const renamed = Product(
        id: 2,
        title: 'Renamed',
        price: 2,
        description: '',
        images: [],
      );

      repository.publish(const ProductUpdated(renamed));
      await pumpEventQueue();

      expect(bloc.state.items[1], renamed);
      expect(bloc.state.items, hasLength(3));
    });

    test('a deleted product disappears and shifts the server offset', () async {
      final bloc = await started();

      repository.publish(const ProductDeleted(2));
      await pumpEventQueue();

      expect(bloc.state.items.map((p) => p.id), [1, 3]);
      expect(bloc.state.nextOffset, 2);

      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();
      expect(
        repository.requests.single.offset,
        2,
        reason: 'no product skipped',
      );
    });

    test('deleting a product that is not loaded changes nothing', () async {
      final bloc = await started();

      repository.publish(const ProductDeleted(999));
      await pumpEventQueue();

      expect(bloc.state.items, hasLength(3));
      expect(bloc.state.nextOffset, 3);
    });

    test('paging after a create and a delete requests the right offset', () async {
      final bloc = await started();

      repository.publish(ProductCreated(makeProducts(1, start: 99).single));
      repository.publish(const ProductDeleted(1));
      await pumpEventQueue();
      bloc.add(const ProductsNextPageRequested());
      await pumpEventQueue();

      // Server list shrank by one (the delete) and gained nothing at the front.
      expect(repository.requests.single.offset, 2);
    });
  });

  group('navigation intents', () {
    test('selecting a product asks to open it', () async {
      final bloc = build();
      addTearDown(bloc.close);
      final effects = <ProductsEffect>[];
      final subscription = bloc.effects.listen(effects.add);
      addTearDown(subscription.cancel);
      final product = makeProducts(1).single;

      bloc.add(ProductSelected(product));
      await pumpEventQueue();

      expect(effects, [OpenProductDetail(product)]);
    });

    test('add asks to open the form', () async {
      final bloc = build();
      addTearDown(bloc.close);
      final effects = <ProductsEffect>[];
      final subscription = bloc.effects.listen(effects.add);
      addTearDown(subscription.cancel);

      bloc.add(const AddProductRequested());
      await pumpEventQueue();

      expect(effects, [const OpenProductForm()]);
    });
  });

  group('deck', () {
    Future<ProductsBloc> started({int serverSize = 8}) async {
      repository.server = makeProducts(serverSize);
      final bloc = build()..add(const ProductsStarted());
      await pumpEventQueue();
      addTearDown(bloc.close);
      return bloc;
    }

    test('starts in list mode and can switch to the deck and back', () async {
      final bloc = await started();
      expect(bloc.state.viewMode, ProductsViewMode.list);

      bloc.add(const ProductsViewModeChanged(ProductsViewMode.deck));
      await pumpEventQueue();
      expect(bloc.state.viewMode, ProductsViewMode.deck);

      bloc.add(const ProductsViewModeChanged(ProductsViewMode.list));
      await pumpEventQueue();
      expect(bloc.state.viewMode, ProductsViewMode.list);
    });

    test(
      'swiping right likes and dismisses, swiping left only dismisses',
      () async {
        final bloc = await started();
        final items = bloc.state.items;

        bloc.add(ProductSwiped(items[0], SwipeDirection.right));
        bloc.add(ProductSwiped(items[1], SwipeDirection.left));
        await pumpEventQueue();

        expect(bloc.state.likedIds, {items[0].id});
        expect(bloc.state.dismissedIds, {items[0].id, items[1].id});
        expect(bloc.state.deckItems.map((p) => p.id), [items[2].id]);
      },
    );

    test(
      'the deck is exhausted only when all is seen and nothing more can load',
      () async {
        final bloc = await started(serverSize: 2);
        expect(bloc.state.hasReachedEnd, isTrue);
        expect(bloc.state.isDeckExhausted, isFalse);

        for (final product in bloc.state.items) {
          bloc.add(ProductSwiped(product, SwipeDirection.left));
        }
        await pumpEventQueue();

        expect(bloc.state.isDeckExhausted, isTrue);
      },
    );

    test(
      'everything swiped while more can be loaded is not exhausted yet',
      () async {
        final bloc = await started(serverSize: 8);
        for (final product in bloc.state.items) {
          bloc.add(ProductSwiped(product, SwipeDirection.left));
        }
        await pumpEventQueue();

        expect(bloc.state.deckItems, isEmpty);
        expect(bloc.state.hasReachedEnd, isFalse);
        expect(
          bloc.state.isDeckExhausted,
          isFalse,
          reason: 'the next page is coming',
        );
      },
    );

    test('starting over brings the cards back and keeps the likes', () async {
      final bloc = await started(serverSize: 2);
      for (final product in bloc.state.items) {
        bloc.add(ProductSwiped(product, SwipeDirection.right));
      }
      await pumpEventQueue();

      bloc.add(const ProductsDeckRestarted());
      await pumpEventQueue();

      expect(bloc.state.deckItems, hasLength(2));
      expect(bloc.state.likedIds, hasLength(2));
    });

    test('the deck state survives refreshing the list', () async {
      final bloc = await started();
      final first = bloc.state.items.first;
      bloc
        ..add(const ProductsViewModeChanged(ProductsViewMode.deck))
        ..add(ProductSwiped(first, SwipeDirection.right));
      await pumpEventQueue();

      bloc.add(const ProductsRefreshed());
      await pumpEventQueue();

      expect(bloc.state.viewMode, ProductsViewMode.deck);
      expect(bloc.state.likedIds, {first.id});
      expect(bloc.state.dismissedIds, {first.id});
    });

    test('and survives retrying a failed first load', () async {
      repository.queued.add(const Failed(NetworkFailure()));
      final bloc = build()
        ..add(const ProductsViewModeChanged(ProductsViewMode.deck))
        ..add(const ProductsStarted());
      addTearDown(bloc.close);
      await pumpEventQueue();
      expect(bloc.state.blockingFailure, isNotNull);

      repository.server = makeProducts(3);
      bloc.add(const ProductsStarted());
      await pumpEventQueue();

      expect(bloc.state.viewMode, ProductsViewMode.deck);
      expect(bloc.state.items, hasLength(3));
    });

    test(
      'a deleted product leaves the deck, the likes and the dismissed set',
      () async {
        final bloc = await started();
        final liked = bloc.state.items.first;
        bloc.add(ProductSwiped(liked, SwipeDirection.right));
        await pumpEventQueue();

        repository.publish(ProductDeleted(liked.id));
        await pumpEventQueue();

        expect(bloc.state.likedIds, isEmpty);
        expect(bloc.state.dismissedIds, isEmpty);
        expect(bloc.state.items.any((p) => p.id == liked.id), isFalse);
      },
    );
  });
}
