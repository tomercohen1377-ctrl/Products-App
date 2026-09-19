import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/presentation/list/products_bloc.dart';
import 'package:products/src/presentation/list/products_content.dart';
import 'package:products/src/presentation/list/products_effect.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';
import 'package:products/src/presentation/products_routes.dart';

/// Container: needs a [ProductsBloc] above it. [actions] are app-bar actions
/// supplied by the app (e.g. the account button), so this feature does not
/// depend on another one.
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({this.actions = const [], super.key});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.productsTitle),
      actions: [
        Builder(
          builder: (context) => IconButton(
            tooltip: context.l10n.productAdd,
            icon: const Icon(Icons.add_rounded),
            onPressed: () =>
                context.read<ProductsBloc>().add(const AddProductRequested()),
          ),
        ),
        ...actions,
      ],
    ),
    body: MviView<ProductsBloc, ProductsState, ProductsEffect>(
      onEffect: (context, effect) => switch (effect) {
        ProductsRefreshFailed(:final failure) => _showSnackBar(
          context,
          failure.localized(context.l10n),
        ),
        OpenProductDetail(:final product) => context.push<void>(
          ProductsRoutes.detail(product.id),
          extra: product,
        ),
        OpenProductForm() => context.push<void>(ProductsRoutes.create),
      },
      builder: (context, state) {
        final bloc = context.read<ProductsBloc>();
        return ProductsContent(
          state: state,
          onIntent: bloc.add,
          onRefresh: () => _refresh(bloc),
        );
      },
    ),
  );

  Future<void> _refresh(ProductsBloc bloc) async {
    bloc.add(const ProductsRefreshed());
    // Completes when the refresh ends; the closed-bloc case is not an error.
    await bloc.stream
        .firstWhere((state) => !state.isRefreshing)
        .then<void>((_) {}, onError: (Object _) {});
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
