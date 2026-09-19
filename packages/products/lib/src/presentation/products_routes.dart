import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/presentation/detail/product_detail_bloc.dart';
import 'package:products/src/presentation/detail/product_detail_intent.dart';
import 'package:products/src/presentation/detail/product_detail_screen.dart';
import 'package:products/src/presentation/form/product_form_bloc.dart';
import 'package:products/src/presentation/form/product_form_intent.dart';
import 'package:products/src/presentation/form/product_form_screen.dart';
import 'package:products/src/presentation/list/products_bloc.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_screen.dart';

abstract final class ProductsRoutes {
  static const String list = '/products';
  static const String create = '/products/new';

  static String detail(int id) => '/products/$id';
  static String edit(int id) => '/products/$id/edit';
}

/// The products feature's routes; the app composes them into its router and
/// injects [appBarActions] (such as the account button).
///
/// Detail and edit take the tapped [Product] as `extra` so they open without
/// a spinner; detail loads by id when opened without one.
List<RouteBase> productsRoutes(
  GetIt getIt, {
  List<Widget> appBarActions = const [],
}) => [
  GoRoute(
    path: ProductsRoutes.list,
    builder: (context, state) => BlocProvider<ProductsBloc>(
      create: (_) => getIt<ProductsBloc>()..add(const ProductsStarted()),
      child: ProductsScreen(actions: appBarActions),
    ),
    routes: [
      // Declared before ':id' so "new" is not read as an id.
      GoRoute(
        path: 'new',
        builder: (context, state) => BlocProvider<ProductFormBloc>(
          create: (_) =>
              getIt<ProductFormBloc>(param1: null)
                ..add(const ProductFormStarted()),
          child: const ProductFormScreen(),
        ),
      ),
      GoRoute(
        path: ':id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final seed = state.extra is Product ? state.extra! as Product : null;
          return BlocProvider<ProductDetailBloc>(
            create: (_) =>
                getIt<ProductDetailBloc>(param1: id, param2: seed)
                  ..add(const ProductDetailStarted()),
            child: const ProductDetailScreen(),
          );
        },
        routes: [
          GoRoute(
            path: 'edit',
            // Editing needs the product to pre-fill from; without it (a deep
            // link), go through the detail page, which can load it.
            redirect: (context, state) => state.extra is Product
                ? null
                : ProductsRoutes.detail(int.parse(state.pathParameters['id']!)),
            builder: (context, state) => BlocProvider<ProductFormBloc>(
              create: (_) =>
                  getIt<ProductFormBloc>(param1: state.extra! as Product)
                    ..add(const ProductFormStarted()),
              child: const ProductFormScreen(),
            ),
          ),
        ],
      ),
    ],
  ),
];
