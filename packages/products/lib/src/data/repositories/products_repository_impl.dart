import 'dart:async';

import 'package:core/core.dart';
import 'package:network/network.dart';
import 'package:products/src/data/mappers/product_mappers.dart';
import 'package:products/src/data/sources/products_remote_source.dart';
import 'package:products/src/domain/entities/category.dart';
import 'package:products/src/domain/entities/picked_photo.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_change.dart';
import 'package:products/src/domain/entities/product_draft.dart';
import 'package:products/src/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);

  final ProductsRemoteSource _remote;
  final StreamController<ProductChange> _changes =
      StreamController<ProductChange>.broadcast();

  /// Categories rarely change, so they are fetched once per app run. A failed
  /// fetch is not cached.
  List<Category>? _categories;

  @override
  Stream<ProductChange> get changes => _changes.stream;

  @override
  Future<Result<List<Product>>> getProducts({
    required int offset,
    required int limit,
  }) async {
    final result = await guardApi(
      () => _remote.getProducts(offset: offset, limit: limit),
    );
    return result.map((dtos) => [for (final dto in dtos) dto.toEntity()]);
  }

  @override
  Future<Result<Product>> getProduct(int id) async {
    final result = await guardApi(() => _remote.getProduct(id));
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<Result<Product>> createProduct(ProductDraft draft) async {
    final result = await guardApi(
      () => _remote.createProduct(draft.toRequest()),
    );
    return _publish(result.map((dto) => dto.toEntity()), ProductCreated.new);
  }

  @override
  Future<Result<Product>> updateProduct(int id, ProductDraft draft) async {
    final result = await guardApi(
      () => _remote.updateProduct(id, draft.toRequest()),
    );
    return _publish(result.map((dto) => dto.toEntity()), ProductUpdated.new);
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    final result = await guardApi(() => _remote.deleteProduct(id));
    if (result.isSuccess) _publishChange(ProductDeleted(id));
    return result;
  }

  @override
  Future<Result<String>> uploadImage(PickedPhoto photo) =>
      guardApi(() => _remote.uploadImage(photo));

  @override
  Future<Result<List<Category>>> getCategories() async {
    final cached = _categories;
    if (cached != null) return Success(cached);

    final result = await guardApi(_remote.getCategories);
    final categories = result.map(
      (dtos) => [for (final dto in dtos) dto.toEntity()],
    );
    _categories = categories.valueOrNull;
    return categories;
  }

  Result<Product> _publish(
    Result<Product> result,
    ProductChange Function(Product) toChange,
  ) {
    final product = result.valueOrNull;
    if (product != null) _publishChange(toChange(product));
    return result;
  }

  void _publishChange(ProductChange change) {
    if (!_changes.isClosed) _changes.add(change);
  }

  Future<void> dispose() => _changes.close();
}
