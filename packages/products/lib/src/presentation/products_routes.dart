import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:products/src/presentation/list/products_bloc.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_screen.dart';

abstract final class ProductsRoutes {
  static const String list = '/products';
}

/// The products feature's routes; the app composes them into its router and
/// injects [appBarActions] (such as the account button).
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
  ),
];
