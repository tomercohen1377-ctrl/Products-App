import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/category.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
  });

  final int id;
  final String title;
  final double price;
  final String description;

  /// Valid http(s) image URLs only; may be empty.
  final List<String> images;
  final Category? category;

  String? get coverImage => images.isEmpty ? null : images.first;

  @override
  List<Object?> get props => [id, title, price, description, images, category];
}
