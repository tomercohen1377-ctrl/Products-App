import 'package:json_annotation/json_annotation.dart';
import 'package:products/src/data/dto/category_dto.dart';

part 'product_dto.g.dart';

@JsonSerializable(createToJson: false)
class ProductDto {
  const ProductDto({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  final num price;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: <String>[])
  final List<String> images;
  final CategoryDto? category;
}
