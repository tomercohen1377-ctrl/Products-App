import 'package:equatable/equatable.dart';

sealed class ProductFormIntent extends Equatable {
  const ProductFormIntent();

  @override
  List<Object?> get props => const [];
}

/// Load (or retry loading) the categories the product can belong to.
final class ProductFormStarted extends ProductFormIntent {
  const ProductFormStarted();
}

final class ProductFormTitleChanged extends ProductFormIntent {
  const ProductFormTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class ProductFormPriceChanged extends ProductFormIntent {
  const ProductFormPriceChanged(this.price);

  final String price;

  @override
  List<Object?> get props => [price];
}

final class ProductFormDescriptionChanged extends ProductFormIntent {
  const ProductFormDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class ProductFormCategorySelected extends ProductFormIntent {
  const ProductFormCategorySelected(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class ProductFormImageAdded extends ProductFormIntent {
  const ProductFormImageAdded(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

final class ProductFormImageRemoved extends ProductFormIntent {
  const ProductFormImageRemoved(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

final class ProductFormSubmitted extends ProductFormIntent {
  const ProductFormSubmitted();
}
