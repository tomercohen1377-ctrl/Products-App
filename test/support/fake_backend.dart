import 'package:network/testing.dart';

/// A tiny in-memory Platzi API: products and categories with real
/// create/update/delete semantics, so app tests exercise whole flows.
class FakeBackend {
  FakeBackend() {
    products = [
      _product(1, 'Fixture Hat', 10, 1),
      _product(2, 'Fixture Shoe', 25, 2),
    ];
  }

  static const categories = [
    {'id': 1, 'name': 'Clothes'},
    {'id': 2, 'name': 'Shoes'},
  ];

  late List<Map<String, dynamic>> products;
  int _nextId = 100;

  /// The next create/update/delete answers with this instead.
  FakeResponse? failNextMutation;

  /// Bodies received by mutations, for assertions.
  final List<Map<String, dynamic>> createdBodies = [];
  final List<Map<String, dynamic>> updatedBodies = [];
  final List<int> deletedIds = [];

  static Map<String, dynamic> _product(
    int id,
    String title,
    num price,
    int categoryId,
  ) => {
    'id': id,
    'title': title,
    'price': price,
    'description': '$title description',
    'images': ['https://i.imgur.com/1twoaDy.jpeg'],
    'category': categories.firstWhere((c) => c['id'] == categoryId),
  };

  void install(FakeHttpClientAdapter adapter) {
    final byId = RegExp(r'^/products/(\d+)$');
    int idOf(String path) => int.parse(byId.firstMatch(path)!.group(1)!);

    adapter
      ..on('GET', '/products', (options) {
        final offset = options.queryParameters['offset'] as int;
        final limit = options.queryParameters['limit'] as int;
        final start = offset.clamp(0, products.length);
        final end = (offset + limit).clamp(0, products.length);
        return FakeResponse.json(products.sublist(start, end));
      })
      ..on('GET', '/categories', (_) => const FakeResponse.json(categories))
      ..onMatching('GET', byId.hasMatch, (options) {
        final product = products.where((p) => p['id'] == idOf(options.path));
        return product.isEmpty
            ? const FakeResponse.json({'message': 'Not found'}, status: 400)
            : FakeResponse.json(product.first);
      })
      ..on('POST', '/products', (options) {
        final failure = _takeFailure();
        if (failure != null) return failure;
        final body = Map<String, dynamic>.from(options.data as Map);
        createdBodies.add(body);
        final product = {
          'id': _nextId++,
          'title': body['title'],
          'price': body['price'],
          'description': body['description'],
          'images': body['images'],
          'category': categories.firstWhere(
            (c) => c['id'] == body['categoryId'],
          ),
        };
        products.add(product);
        return FakeResponse.json(product, status: 201);
      })
      ..onMatching('PUT', byId.hasMatch, (options) {
        final failure = _takeFailure();
        if (failure != null) return failure;
        final body = Map<String, dynamic>.from(options.data as Map);
        updatedBodies.add(body);
        final product = products.firstWhere(
          (p) => p['id'] == idOf(options.path),
        );
        product
          ..['title'] = body['title']
          ..['price'] = body['price']
          ..['description'] = body['description']
          ..['images'] = body['images']
          ..['category'] = categories.firstWhere(
            (c) => c['id'] == body['categoryId'],
          );
        return FakeResponse.json(product);
      })
      ..onMatching('DELETE', byId.hasMatch, (options) {
        final failure = _takeFailure();
        if (failure != null) return failure;
        final id = idOf(options.path);
        deletedIds.add(id);
        products.removeWhere((p) => p['id'] == id);
        return const FakeResponse.json(true);
      });
  }

  FakeResponse? _takeFailure() {
    final failure = failNextMutation;
    failNextMutation = null;
    return failure;
  }
}
