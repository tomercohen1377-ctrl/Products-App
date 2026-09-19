import 'package:equatable/equatable.dart';

/// The editable fields of a product, used to create or update one.
class ProductDraft extends Equatable {
  const ProductDraft({
    required this.title,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.images,
  });

  final String title;
  final double price;
  final String description;
  final int categoryId;
  final List<String> images;

  @override
  List<Object?> get props => [title, price, description, categoryId, images];
}
