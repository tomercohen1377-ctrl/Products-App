import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/testing.dart';
import 'package:products/products.dart';
import 'package:products/testing.dart';

import '../support/json.dart';
import '../support/repository_harness.dart';

void main() {
  late RepositoryHarness h;

  setUp(() => h = RepositoryHarness());

  group('getProducts', () {
    test('sends offset and limit and maps the page', () async {
      h.adapter.on(
        'GET',
        '/products',
        (_) => FakeResponse.json([productJson(id: 1), productJson(id: 2)]),
      );

      final result = await h.repository.getProducts(offset: 40, limit: 20);

      expect(result.valueOrNull?.map((p) => p.id), [1, 2]);
      final query = h.adapter
          .requestsTo('GET', '/products')
          .single
          .queryParameters;
      expect(query, {'offset': 40, 'limit': 20});
    });

    test('an empty page is a success with no items', () async {
      h.adapter.on('GET', '/products', (_) => const FakeResponse.json([]));

      final result = await h.repository.getProducts(offset: 100, limit: 20);

      expect(result.valueOrNull, isEmpty);
    });

    test('maps transport and server failures', () async {
      h.adapter.onSequence('GET', '/products', [
        const FakeResponse.offline(),
        const FakeResponse.status(500),
      ]);

      expect(
        (await h.repository.getProducts(offset: 0, limit: 20)).failureOrNull,
        const NetworkFailure(),
      );
      expect(
        (await h.repository.getProducts(offset: 0, limit: 20)).failureOrNull,
        const ServerFailure(statusCode: 500),
      );
    });

    test('a malformed payload is an unknown failure, not a crash', () async {
      h.adapter.on(
        'GET',
        '/products',
        (_) => const FakeResponse.json({'unexpected': 'object'}),
      );

      final result = await h.repository.getProducts(offset: 0, limit: 20);

      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });

  test('getProduct fetches by id', () async {
    h.adapter.on(
      'GET',
      '/products/7',
      (_) => FakeResponse.json(productJson(id: 7)),
    );

    final result = await h.repository.getProduct(7);

    expect(result.valueOrNull?.id, 7);
  });

  group('createProduct', () {
    test(
      'posts the draft, returns the product and publishes a change',
      () async {
        h.adapter.on(
          'POST',
          '/products',
          (_) =>
              FakeResponse.json(productJson(id: 99, title: 'New'), status: 201),
        );

        final result = await h.repository.createProduct(draftFixture);
        await pumpEventQueue();

        expect(result.valueOrNull?.id, 99);
        expect(h.adapter.requestsTo('POST', '/products').single.data, {
          'title': 'Classic Red Pullover Hoodie',
          'price': 10.0,
          'description': 'A comfy hoodie.',
          'categoryId': 1,
          'images': ['https://i.imgur.com/1twoaDy.jpeg'],
        });
        expect(h.changes, [
          isA<ProductCreated>().having((c) => c.product.id, 'id', 99),
        ]);
      },
    );

    test(
      'a rejected draft surfaces the server messages and publishes nothing',
      () async {
        h.adapter.on(
          'POST',
          '/products',
          (_) => const FakeResponse.json({
            'message': ['images must contain at least 1 elements'],
          }, status: 400),
        );

        final result = await h.repository.createProduct(draftFixture);
        await pumpEventQueue();

        expect(
          result.failureOrNull,
          const ValidationFailure(
            messages: ['images must contain at least 1 elements'],
          ),
        );
        expect(h.changes, isEmpty);
      },
    );
  });

  test(
    'updateProduct puts to the id and publishes the updated product',
    () async {
      h.adapter.on(
        'PUT',
        '/products/7',
        (_) => FakeResponse.json(productJson(id: 7, title: 'Renamed')),
      );

      final result = await h.repository.updateProduct(7, draftFixture);
      await pumpEventQueue();

      expect(result.valueOrNull?.title, 'Renamed');
      expect(h.adapter.count('PUT', '/products/7'), 1);
      expect(h.changes.single, isA<ProductUpdated>());
    },
  );

  group('deleteProduct', () {
    test('deletes by id and publishes the id', () async {
      h.adapter.on(
        'DELETE',
        '/products/7',
        (_) => const FakeResponse.json(true),
      );

      final result = await h.repository.deleteProduct(7);
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      expect(h.changes, [const ProductDeleted(7)]);
    });

    test('a failed delete publishes nothing', () async {
      h.adapter.on(
        'DELETE',
        '/products/7',
        (_) => const FakeResponse.status(500),
      );

      final result = await h.repository.deleteProduct(7);
      await pumpEventQueue();

      expect(result.failureOrNull, isA<ServerFailure>());
      expect(h.changes, isEmpty);
    });
  });

  test('changes are published in the order they happen', () async {
    h.adapter
      ..on('POST', '/products', (_) => FakeResponse.json(productJson(id: 1)))
      ..on('PUT', '/products/1', (_) => FakeResponse.json(productJson(id: 1)))
      ..on('DELETE', '/products/1', (_) => const FakeResponse.json(true));

    await h.repository.createProduct(draftFixture);
    await h.repository.updateProduct(1, draftFixture);
    await h.repository.deleteProduct(1);
    await pumpEventQueue();

    expect(h.changes.map((c) => c.runtimeType), [
      ProductCreated,
      ProductUpdated,
      ProductDeleted,
    ]);
  });

  group('getCategories', () {
    final categoriesJson = [
      {'id': 1, 'name': 'Clothes', 'image': 'https://i.imgur.com/QkIa5tT.jpeg'},
      {'id': 4, 'name': 'Shoes', 'image': 'junk'},
    ];

    test('maps categories and fetches them only once', () async {
      h.adapter.on(
        'GET',
        '/categories',
        (_) => FakeResponse.json(categoriesJson),
      );

      final first = await h.repository.getCategories();
      final second = await h.repository.getCategories();

      expect(first.valueOrNull?.map((c) => c.name), ['Clothes', 'Shoes']);
      expect(second.valueOrNull, first.valueOrNull);
      expect(h.adapter.count('GET', '/categories'), 1);
    });

    test('a failure is not cached', () async {
      h.adapter.onSequence('GET', '/categories', [
        const FakeResponse.offline(),
        FakeResponse.json(categoriesJson),
      ]);

      final first = await h.repository.getCategories();
      final second = await h.repository.getCategories();

      expect(first.failureOrNull, const NetworkFailure());
      expect(second.isSuccess, isTrue);
      expect(h.adapter.count('GET', '/categories'), 2);
    });
  });
}
