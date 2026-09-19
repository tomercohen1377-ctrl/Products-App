import 'package:products/src/data/dto/category_dto.dart';
import 'package:products/src/data/dto/product_dto.dart';
import 'package:products/src/data/dto/product_request_dto.dart';
import 'package:products/src/data/mappers/image_url_sanitizer.dart';
import 'package:products/src/domain/entities/category.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_draft.dart';

extension CategoryDtoMapper on CategoryDto {
  Category toEntity() => Category(
    id: id,
    name: name.trim(),
    imageUrl: ImageUrlSanitizer.clean([?image]).firstOrNull,
  );
}

extension ProductDtoMapper on ProductDto {
  Product toEntity() => Product(
    id: id,
    title: title.trim(),
    price: price.toDouble(),
    description: description.trim(),
    images: ImageUrlSanitizer.clean(images),
    category: category?.toEntity(),
  );
}

extension ProductDraftMapper on ProductDraft {
  ProductRequestDto toRequest() => ProductRequestDto(
    title: title.trim(),
    price: price,
    description: description.trim(),
    categoryId: categoryId,
    images: images,
  );
}
