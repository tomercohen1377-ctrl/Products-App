import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

sealed class ProductsEffect extends Equatable {
  const ProductsEffect();

  @override
  List<Object?> get props => const [];
}

/// A pull-to-refresh failed; the list stays as it was.
final class ProductsRefreshFailed extends ProductsEffect {
  const ProductsRefreshFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class OpenProductDetail extends ProductsEffect {
  const OpenProductDetail(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class OpenProductForm extends ProductsEffect {
  const OpenProductForm();
}
