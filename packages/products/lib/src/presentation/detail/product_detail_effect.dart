import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

sealed class ProductDetailEffect extends Equatable {
  const ProductDetailEffect();

  @override
  List<Object?> get props => const [];
}

final class OpenProductEditor extends ProductDetailEffect {
  const OpenProductEditor(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

/// Ask the user before deleting; confirming sends `DeleteConfirmed`.
final class ConfirmProductDeletion extends ProductDetailEffect {
  const ConfirmProductDeletion(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

/// Leave the screen: the product was deleted here, or elsewhere.
final class CloseProductDetail extends ProductDetailEffect {
  const CloseProductDetail({required this.deletedByUser});

  final bool deletedByUser;

  @override
  List<Object?> get props => [deletedByUser];
}

final class ProductDeletionFailed extends ProductDetailEffect {
  const ProductDeletionFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
