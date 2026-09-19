import 'package:json_annotation/json_annotation.dart';

part 'product_request_dto.g.dart';

/// The body of `POST /products` and `PUT /products/{id}`.
@JsonSerializable(createFactory: false)
class ProductRequestDto {
  const ProductRequestDto({
    required this.title,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.images,
  });

  final String title;
  final num price;
  final String description;
  final int categoryId;
  final List<String> images;

  Map<String, dynamic> toJson() => _$ProductRequestDtoToJson(this);
}
