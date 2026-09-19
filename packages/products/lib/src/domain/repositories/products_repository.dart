import 'package:core/core.dart';
import 'package:products/src/domain/entities/category.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_change.dart';
import 'package:products/src/domain/entities/product_draft.dart';

abstract interface class ProductsRepository {
  /// Every successful create, update and delete, in order.
  Stream<ProductChange> get changes;

  /// One page. The API reports no total, so a page shorter than [limit]
  /// means the end of the list.
  Future<Result<List<Product>>> getProducts({
    required int offset,
    required int limit,
  });

  Future<Result<Product>> getProduct(int id);

  Future<Result<Product>> createProduct(ProductDraft draft);

  Future<Result<Product>> updateProduct(int id, ProductDraft draft);

  Future<Result<void>> deleteProduct(int id);

  /// Categories a product can belong to (`categoryId` must be one of these).
  Future<Result<List<Category>>> getCategories();
}
