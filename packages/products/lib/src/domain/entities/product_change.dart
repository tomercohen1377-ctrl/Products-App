import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';

/// A change to the product collection, published by the repository so every
/// screen stays consistent without refetching or knowing about each other.
sealed class ProductChange extends Equatable {
  const ProductChange();

  @override
  List<Object?> get props => const [];
}

final class ProductCreated extends ProductChange {
  const ProductCreated(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductUpdated extends ProductChange {
  const ProductUpdated(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductDeleted extends ProductChange {
  const ProductDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
