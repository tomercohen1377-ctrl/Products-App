import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/data/dto/category_dto.dart';
import 'package:products/src/data/dto/product_dto.dart';
import 'package:products/src/data/mappers/product_mappers.dart';
import 'package:products/products.dart';
import 'package:products/testing.dart';

import '../support/json.dart';

void main() {
  test('maps a live product payload to an entity', () {
    final product = ProductDto.fromJson(productJson()).toEntity();

    expect(product.id, 7);
    expect(product.title, 'Classic Blue Baseball Cap');
    expect(product.price, 79.0);
    expect(product.images, ['https://i.imgur.com/mp3rUty.jpeg']);
    expect(product.category?.id, 1);
    expect(product.category?.name, 'Clothes');
    expect(product.coverImage, 'https://i.imgur.com/mp3rUty.jpeg');
  });

  test('accepts fractional and integer prices', () {
    expect(
      ProductDto.fromJson(productJson(price: 79.5)).toEntity().price,
      79.5,
    );
    expect(
      ProductDto.fromJson(productJson(price: 1234567)).toEntity().price,
      1234567.0,
    );
  });

  test('is tolerant of missing optional fields', () {
    final product = ProductDto.fromJson({'id': 1, 'price': 5}).toEntity();

    expect(product.title, '');
    expect(product.description, '');
    expect(product.images, isEmpty);
    expect(product.category, isNull);
    expect(product.coverImage, isNull);
  });

  test('cleans junk image values and trims text', () {
    final product = ProductDto.fromJson(
      productJson(
        title: '  Hat  ',
        images: ['["https://i.imgur.com/a.jpeg"]', 'garbage', ''],
      ),
    ).toEntity();

    expect(product.title, 'Hat');
    expect(product.images, ['https://i.imgur.com/a.jpeg']);
  });

  test('a category with a junk image loses only the image', () {
    final category = const CategoryDto(
      id: 4,
      name: ' Shoes ',
      image: 'x',
    ).toEntity();

    expect(category.name, 'Shoes');
    expect(category.imageUrl, isNull);
  });

  test('a draft becomes the request body the API expects', () {
    final json = draftFixture.toRequest().toJson();

    expect(json, {
      'title': 'Classic Red Pullover Hoodie',
      'price': 10.0,
      'description': 'A comfy hoodie.',
      'categoryId': 1,
      'images': ['https://i.imgur.com/1twoaDy.jpeg'],
    });
  });

  test('the request trims title and description', () {
    const padded = ProductDraft(
      title: '  Hat  ',
      price: 5,
      description: '  Warm.  ',
      categoryId: 1,
      images: ['https://i.imgur.com/a.jpeg'],
    );

    final json = padded.toRequest().toJson();

    expect(json['title'], 'Hat');
    expect(json['description'], 'Warm.');
  });
}
