import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

enum ProductsPhase { loading, ready, failure }

/// How the same products are presented.
enum ProductsViewMode { list, deck }

class ProductsState extends Equatable {
  const ProductsState({
    this.phase = ProductsPhase.loading,
    this.items = const [],
    this.nextOffset = 0,
    this.failure,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.loadMoreFailure,
    this.viewMode = ProductsViewMode.list,
    this.likedIds = const {},
    this.dismissedIds = const {},
  });

  final ProductsPhase phase;
  final List<Product> items;

  /// How many products the **server** list has been consumed by, which is the
  /// `offset` of the next page. It is not `items.length`: a product created
  /// here is shown at the top but sits at the end of the server's order, so
  /// counting it would make the next page skip a real product.
  final int nextOffset;

  /// Why the first load failed (only meaningful in [ProductsPhase.failure]).
  final Failure? failure;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final Failure? loadMoreFailure;
  final ProductsViewMode viewMode;

  /// Products swiped right in the deck (kept for this session only).
  final Set<int> likedIds;

  /// Products the user has swiped away in the deck, either way.
  final Set<int> dismissedIds;

  /// The products still in the deck: loaded and not yet swiped away.
  List<Product> get deckItems => [
    for (final product in items)
      if (!dismissedIds.contains(product.id)) product,
  ];

  /// Every loaded product has been swiped and there are no more to load.
  bool get isDeckExhausted =>
      phase == ProductsPhase.ready &&
      items.isNotEmpty &&
      hasReachedEnd &&
      deckItems.isEmpty;

  bool get isInitialLoading => phase == ProductsPhase.loading;
  Failure? get blockingFailure =>
      phase == ProductsPhase.failure ? failure : null;
  bool get isEmpty => phase == ProductsPhase.ready && items.isEmpty;

  ProductsState copyWith({
    ProductsPhase? phase,
    List<Product>? items,
    int? nextOffset,
    Object? failure = keep,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    Object? loadMoreFailure = keep,
    ProductsViewMode? viewMode,
    Set<int>? likedIds,
    Set<int>? dismissedIds,
  }) => ProductsState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    nextOffset: nextOffset ?? this.nextOffset,
    failure: valueOrKeep(failure, this.failure),
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    loadMoreFailure: valueOrKeep(loadMoreFailure, this.loadMoreFailure),
    viewMode: viewMode ?? this.viewMode,
    likedIds: likedIds ?? this.likedIds,
    dismissedIds: dismissedIds ?? this.dismissedIds,
  );

  @override
  List<Object?> get props => [
    phase,
    items,
    nextOffset,
    failure,
    isRefreshing,
    isLoadingMore,
    hasReachedEnd,
    loadMoreFailure,
    viewMode,
    likedIds,
    dismissedIds,
  ];
}
