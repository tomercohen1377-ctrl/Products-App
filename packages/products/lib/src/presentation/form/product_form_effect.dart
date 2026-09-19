import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

sealed class ProductFormEffect extends Equatable {
  const ProductFormEffect();

  @override
  List<Object?> get props => const [];
}

/// The product was created or updated; leave the form.
final class ProductSaved extends ProductFormEffect {
  const ProductSaved(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}
