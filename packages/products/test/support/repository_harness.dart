import 'package:core/core.dart';
import 'package:network/network.dart';
import 'package:network/testing.dart';
import 'package:products/src/data/repositories/products_repository_impl.dart';
import 'package:products/src/data/sources/products_remote_source.dart';
import 'package:products/src/domain/entities/product_change.dart';

class _SilentLogger implements AppLogger {
  @override
  void debug(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

/// The real data layer over a [FakeHttpClientAdapter].
class RepositoryHarness {
  RepositoryHarness() {
    final dio = ApiClient.createBare(
      config: const ApiConfig(baseUrl: 'https://test.local/api'),
      logger: _SilentLogger(),
      adapter: adapter,
    );
    repository = ProductsRepositoryImpl(ProductsRemoteSource(dio));
    repository.changes.listen(changes.add);
  }

  final FakeHttpClientAdapter adapter = FakeHttpClientAdapter();
  late final ProductsRepositoryImpl repository;
  final List<ProductChange> changes = [];
}
