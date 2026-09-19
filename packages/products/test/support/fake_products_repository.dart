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

  /// The next create/update/delete waits for this before answering.
  Completer<void>? holdNextMutation;

  Result<Product>? getProductResult;
  Result<Product>? createResult;
  Result<Product>? updateResult;
  Result<void> deleteResult = const Success(null);
  Result<List<Category>> categoriesResult = const Success([
    Category(id: 1, name: 'Clothes'),
    Category(id: 2, name: 'Shoes'),
  ]);

  final List<int> getProductCalls = [];
  final List<ProductDraft> created = [];
  final List<({int id, ProductDraft draft})> updated = [];
  final List<int> deleted = [];
  int categoriesCalls = 0;

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
  Future<Result<Product>> getProduct(int id) async {
    getProductCalls.add(id);
    await _hold(holdNext);
    holdNext = null;
    return getProductResult ??
        Success(
          server.firstWhere(
            (p) => p.id == id,
            orElse: () => makeProducts(1).first,
          ),
        );
  }

  @override
  Future<Result<Product>> createProduct(ProductDraft draft) async {
    created.add(draft);
    await _holdMutation();
    final result =
        createResult ??
        Success(
          Product(
            id: 1000 + created.length,
            title: draft.title,
            price: draft.price,
            description: draft.description,
            images: draft.images,
          ),
        );
    if (result case Success(:final value)) publish(ProductCreated(value));
    return result;
  }

  @override
  Future<Result<Product>> updateProduct(int id, ProductDraft draft) async {
    updated.add((id: id, draft: draft));
    await _holdMutation();
    final result =
        updateResult ??
        Success(
          Product(
            id: id,
            title: draft.title,
            price: draft.price,
            description: draft.description,
            images: draft.images,
          ),
        );
    if (result case Success(:final value)) publish(ProductUpdated(value));
    return result;
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    deleted.add(id);
    await _holdMutation();
    if (deleteResult.isSuccess) publish(ProductDeleted(id));
    return deleteResult;
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    categoriesCalls++;
    return categoriesResult;
  }

  Future<void> _hold(Completer<void>? hold) async {
    if (hold != null) await hold.future;
  }

  Future<void> _holdMutation() async {
    final hold = holdNextMutation;
    holdNextMutation = null;
    await _hold(hold);
  }

  Future<void> dispose() => _changes.close();
}
