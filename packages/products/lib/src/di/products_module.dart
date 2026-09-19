import 'package:get_it/get_it.dart';
import 'package:network/network.dart';
import 'package:products/src/data/repositories/products_repository_impl.dart';
import 'package:products/src/data/sources/products_remote_source.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/repositories/products_repository.dart';
import 'package:products/src/presentation/detail/product_detail_bloc.dart';
import 'package:products/src/presentation/form/product_form_bloc.dart';
import 'package:products/src/presentation/list/products_bloc.dart';

/// Registers the products feature. Needs the authenticated [Dio] client
/// (registered by the auth module) to already be available.
void registerProductsModule(GetIt getIt) {
  getIt
    ..registerLazySingleton(() => ProductsRemoteSource(getIt<Dio>()))
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(getIt()),
    )
    ..registerFactory(() => ProductsBloc(getIt()))
    ..registerFactoryParam<ProductDetailBloc, int, Product?>(
      (id, seed) => ProductDetailBloc(getIt(), productId: id, seed: seed),
    )
    ..registerFactoryParam<ProductFormBloc, Product?, void>(
      (editing, _) => ProductFormBloc(getIt(), editing: editing),
    );
}
