import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Emitter;
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_change.dart';
import 'package:products/src/domain/repositories/products_repository.dart';
import 'package:products/src/presentation/list/products_effect.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';

const int kProductsPageSize = 20;

class ProductsBloc
    extends MviBloc<ProductsIntent, ProductsState, ProductsEffect> {
  ProductsBloc(this._repository, {this.pageSize = kProductsPageSize})
    : super(const ProductsState()) {
    // Droppable: a load already in flight makes another request redundant.
    on<ProductsStarted>(_onStarted, transformer: droppable());
    on<ProductsNextPageRequested>(_onNextPage, transformer: droppable());
    // Restartable: a newer refresh supersedes an older one.
    on<ProductsRefreshed>(_onRefreshed, transformer: restartable());
    on<ProductsChangeReceived>(_onChange, transformer: sequential());
    on<ProductSelected>(
      (intent, _) => emitEffect(OpenProductDetail(intent.product)),
    );
    on<AddProductRequested>((intent, _) => emitEffect(const OpenProductForm()));

    _changes = _repository.changes.listen(
      (change) => add(ProductsChangeReceived(change)),
    );
  }

  final ProductsRepository _repository;
  final int pageSize;
  late final StreamSubscription<ProductChange> _changes;

  /// Bumped whenever the list is replaced from the start (first load, or a
  /// successful refresh), so a next-page response that was already in flight
  /// recognises it is stale. A failed refresh leaves the list, and so the
  /// epoch, unchanged.
  int _epoch = 0;

  Future<void> _onStarted(
    ProductsStarted intent,
    Emitter<ProductsState> emit,
  ) async {
    _epoch++;
    emit(const ProductsState());
    final result = await _repository.getProducts(offset: 0, limit: pageSize);
    switch (result) {
      case Success(:final value):
        emit(_firstPage(value));
      case Failed(:final failure):
        emit(ProductsState(phase: ProductsPhase.failure, failure: failure));
    }
  }

  Future<void> _onRefreshed(
    ProductsRefreshed intent,
    Emitter<ProductsState> emit,
  ) async {
    if (state.phase != ProductsPhase.ready) return;
    emit(state.copyWith(isRefreshing: true));
    final result = await _repository.getProducts(offset: 0, limit: pageSize);
    switch (result) {
      case Success(:final value):
        _epoch++;
        emit(_firstPage(value));
      case Failed(:final failure):
        emit(state.copyWith(isRefreshing: false));
        emitEffect(ProductsRefreshFailed(failure));
    }
  }

  Future<void> _onNextPage(
    ProductsNextPageRequested intent,
    Emitter<ProductsState> emit,
  ) async {
    if (state.phase != ProductsPhase.ready ||
        state.isLoadingMore ||
        state.isRefreshing ||
        state.hasReachedEnd) {
      return;
    }

    final epoch = _epoch;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailure: null));
    final result = await _repository.getProducts(
      offset: state.nextOffset,
      limit: pageSize,
    );
    if (epoch != _epoch) return;

    switch (result) {
      case Success(:final value):
        final known = {for (final product in state.items) product.id};
        emit(
          state.copyWith(
            items: [
              ...state.items,
              ...value.where((product) => !known.contains(product.id)),
            ],
            nextOffset: state.nextOffset + value.length,
            hasReachedEnd: value.length < pageSize,
            isLoadingMore: false,
          ),
        );
      case Failed(:final failure):
        emit(state.copyWith(isLoadingMore: false, loadMoreFailure: failure));
    }
  }

  void _onChange(ProductsChangeReceived intent, Emitter<ProductsState> emit) {
    if (state.phase != ProductsPhase.ready) return;
    switch (intent.change) {
      case ProductCreated(:final product):
        if (state.items.any((p) => p.id == product.id)) return;
        emit(state.copyWith(items: [product, ...state.items]));
      case ProductUpdated(:final product):
        emit(
          state.copyWith(
            items: [
              for (final p in state.items) p.id == product.id ? product : p,
            ],
          ),
        );
      case ProductDeleted(:final id):
        final remaining = state.items.where((p) => p.id != id).toList();
        if (remaining.length == state.items.length) return;
        emit(
          state.copyWith(
            items: remaining,
            nextOffset: state.nextOffset > 0 ? state.nextOffset - 1 : 0,
          ),
        );
    }
  }

  ProductsState _firstPage(List<Product> page) => ProductsState(
    phase: ProductsPhase.ready,
    items: page,
    nextOffset: page.length,
    hasReachedEnd: page.length < pageSize,
  );

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
