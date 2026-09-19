import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

enum ProductsPhase { loading, ready, failure }

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

  bool get isInitialLoading => phase == ProductsPhase.loading;
  Failure? get blockingFailure =>
      phase == ProductsPhase.failure ? failure : null;
  bool get isEmpty => phase == ProductsPhase.ready && items.isEmpty;

  static const Object _unset = Object();

  ProductsState copyWith({
    ProductsPhase? phase,
    List<Product>? items,
    int? nextOffset,
    Object? failure = _unset,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    Object? loadMoreFailure = _unset,
  }) => ProductsState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    nextOffset: nextOffset ?? this.nextOffset,
    failure: identical(failure, _unset) ? this.failure : failure as Failure?,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    loadMoreFailure: identical(loadMoreFailure, _unset)
        ? this.loadMoreFailure
        : loadMoreFailure as Failure?,
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
  ];
}
