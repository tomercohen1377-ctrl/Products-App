import 'dart:async';

import 'package:core/core.dart';
import 'package:products/products.dart';

/// `count` distinct products with ids `start..start+count-1`.
List<Product> makeProducts(int count, {int start = 1}) => [
  for (var id = start; id < start + count; id++)
    Product(
      id: id,
      title: 'Product $id',
      price: id.toDouble(),
      description: 'Description $id',
      images: const [],
    ),
];

/// A scriptable [ProductsRepository]: serves pages of [server] unless a
/// result has been queued, and can hold the next call to test races.
class FakeProductsRepository implements ProductsRepository {
  FakeProductsRepository([List<Product>? server]) : server = server ?? [];

  List<Product> server;
  final List<({int offset, int limit})> requests = [];
  final List<Result<List<Product>>> queued = [];
  final StreamController<ProductChange> _changes =
      StreamController<ProductChange>.broadcast();

  /// The next `getProducts` call waits for this before answering.
  Completer<void>? holdNext;

  void publish(ProductChange change) => _changes.add(change);

  @override
  Stream<ProductChange> get changes => _changes.stream;

  @override
  Future<Result<List<Product>>> getProducts({
    required int offset,
    required int limit,
  }) async {
    requests.add((offset: offset, limit: limit));

    // The answer is fixed when the request is made; a hold only delays its
    // delivery, like a slow network.
    final Result<List<Product>> result;
    if (queued.isNotEmpty) {
      result = queued.removeAt(0);
    } else {
      final end = (offset + limit).clamp(0, server.length);
      final start = offset.clamp(0, server.length);
      result = Success(server.sublist(start, end));
    }

    final hold = holdNext;
    holdNext = null;
    if (hold != null) await hold.future;
    return result;
  }

  @override
  Future<Result<Product>> getProduct(int id) async => Success(
    server.firstWhere((p) => p.id == id, orElse: () => makeProducts(1).first),
  );

  @override
  Future<Result<Product>> createProduct(ProductDraft draft) =>
      throw UnimplementedError();

  @override
  Future<Result<Product>> updateProduct(int id, ProductDraft draft) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deleteProduct(int id) => throw UnimplementedError();

  @override
  Future<Result<List<Category>>> getCategories() => throw UnimplementedError();

  Future<void> dispose() => _changes.close();
}
