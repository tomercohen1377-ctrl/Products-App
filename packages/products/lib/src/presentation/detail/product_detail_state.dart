import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

enum ProductDetailPhase { loading, ready, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.phase = ProductDetailPhase.loading,
    this.product,
    this.failure,
    this.isDeleting = false,
  });

  final ProductDetailPhase phase;

  /// The product being shown: the one the user tapped (so there is no spinner
  /// flash), refreshed from the server.
  final Product? product;
  final Failure? failure;
  final bool isDeleting;

  bool get isLoading => phase == ProductDetailPhase.loading;
  Failure? get blockingFailure =>
      phase == ProductDetailPhase.failure ? failure : null;
  bool get canAct => product != null && !isDeleting;

  ProductDetailState copyWith({
    ProductDetailPhase? phase,
    Product? product,
    Object? failure = keep,
    bool? isDeleting,
  }) => ProductDetailState(
    phase: phase ?? this.phase,
    product: product ?? this.product,
    failure: valueOrKeep(failure, this.failure),
    isDeleting: isDeleting ?? this.isDeleting,
  );

  @override
  List<Object?> get props => [phase, product, failure, isDeleting];
}
