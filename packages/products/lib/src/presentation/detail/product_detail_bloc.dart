import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Emitter;
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_change.dart';
import 'package:products/src/domain/repositories/products_repository.dart';
import 'package:products/src/presentation/detail/product_detail_effect.dart';
import 'package:products/src/presentation/detail/product_detail_intent.dart';
import 'package:products/src/presentation/detail/product_detail_state.dart';

class ProductDetailBloc
    extends
        MviBloc<ProductDetailIntent, ProductDetailState, ProductDetailEffect> {
  ProductDetailBloc(this._repository, {required this.productId, Product? seed})
    : super(
        ProductDetailState(
          phase: seed == null
              ? ProductDetailPhase.loading
              : ProductDetailPhase.ready,
          product: seed,
        ),
      ) {
    on<ProductDetailStarted>(_onStarted, transformer: droppable());
    on<ProductDetailEditTapped>(_onEditTapped);
    on<ProductDetailDeleteTapped>(_onDeleteTapped);
    on<ProductDetailDeleteConfirmed>(
      _onDeleteConfirmed,
      transformer: droppable(),
    );
    on<ProductDetailChangeReceived>(_onChange, transformer: sequential());

    _changes = _repository.changes.listen(
      (change) => add(ProductDetailChangeReceived(change)),
    );
  }

  final ProductsRepository _repository;
  final int productId;
  late final StreamSubscription<ProductChange> _changes;

  Future<void> _onStarted(
    ProductDetailStarted intent,
    Emitter<ProductDetailState> emit,
  ) async {
    final hadProduct = state.product != null;
    if (state.phase == ProductDetailPhase.failure) {
      emit(state.copyWith(phase: ProductDetailPhase.loading, failure: null));
    }

    final result = await _repository.getProduct(productId);
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            phase: ProductDetailPhase.ready,
            product: value,
            failure: null,
          ),
        );
      case Failed(:final failure):
        // A failed background refresh must not replace what is on screen.
        if (!hadProduct) {
          emit(
            state.copyWith(phase: ProductDetailPhase.failure, failure: failure),
          );
        }
    }
  }

  void _onEditTapped(
    ProductDetailEditTapped intent,
    Emitter<ProductDetailState> emit,
  ) {
    final product = state.product;
    if (product != null && !state.isDeleting) {
      emitEffect(OpenProductEditor(product));
    }
  }

  void _onDeleteTapped(
    ProductDetailDeleteTapped intent,
    Emitter<ProductDetailState> emit,
  ) {
    final product = state.product;
    if (product != null && !state.isDeleting) {
      emitEffect(ConfirmProductDeletion(product));
    }
  }

  Future<void> _onDeleteConfirmed(
    ProductDetailDeleteConfirmed intent,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true));
    final result = await _repository.deleteProduct(productId);
    switch (result) {
      case Success():
        // Stay in "deleting" until the screen has closed.
        emitEffect(const CloseProductDetail(deletedByUser: true));
      case Failed(:final failure):
        emit(state.copyWith(isDeleting: false));
        emitEffect(ProductDeletionFailed(failure));
    }
  }

  void _onChange(
    ProductDetailChangeReceived intent,
    Emitter<ProductDetailState> emit,
  ) {
    switch (intent.change) {
      case ProductUpdated(:final product) when product.id == productId:
        emit(state.copyWith(product: product));
      case ProductDeleted(:final id) when id == productId:
        if (!state.isDeleting) {
          emitEffect(const CloseProductDetail(deletedByUser: false));
        }
      default:
        break;
    }
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
