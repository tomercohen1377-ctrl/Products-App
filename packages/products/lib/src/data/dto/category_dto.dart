import 'package:json_annotation/json_annotation.dart';

part 'category_dto.g.dart';

@JsonSerializable(createToJson: false)
class CategoryDto {
  const CategoryDto({required this.id, required this.name, this.image});

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? image;
}
