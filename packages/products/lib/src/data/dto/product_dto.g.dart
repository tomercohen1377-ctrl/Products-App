// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String? ?? '',
  price: json['price'] as num,
  description: json['description'] as String? ?? '',
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  category: json['category'] == null
      ? null
      : CategoryDto.fromJson(json['category'] as Map<String, dynamic>),
);
