import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/presentation/detail/product_detail_bloc.dart';
import 'package:products/src/presentation/detail/product_detail_content.dart';
import 'package:products/src/presentation/detail/product_detail_effect.dart';
import 'package:products/src/presentation/detail/product_detail_intent.dart';
import 'package:products/src/presentation/detail/product_detail_state.dart';
import 'package:products/src/presentation/products_routes.dart';

/// Container: needs a [ProductDetailBloc] above it.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      MviView<ProductDetailBloc, ProductDetailState, ProductDetailEffect>(
        onEffect: _handleEffect,
        builder: (context, state) {
          final bloc = context.read<ProductDetailBloc>();
          return Scaffold(
            appBar: AppBar(
              actions: [ProductDetailActions(state: state, onIntent: bloc.add)],
            ),
            body: SafeArea(
              child: ProductDetailContent(state: state, onIntent: bloc.add),
            ),
          );
        },
      );

  Future<void> _handleEffect(
    BuildContext context,
    ProductDetailEffect effect,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    switch (effect) {
      case OpenProductEditor(:final product):
        await context.push<void>(
          ProductsRoutes.edit(product.id),
          extra: product,
        );
      case ConfirmProductDeletion(:final product):
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.productDeleteTitle,
          message: l10n.productDeleteMessage(product.title),
          confirmLabel: l10n.productDelete,
          cancelLabel: l10n.cancel,
          destructive: true,
        );
        if (confirmed && context.mounted) {
          context.read<ProductDetailBloc>().add(
            const ProductDetailDeleteConfirmed(),
          );
        }
      case CloseProductDetail(:final deletedByUser):
        if (deletedByUser) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.productDeleted)));
        }
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(ProductsRoutes.list);
        }
      case ProductDeletionFailed(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(failure.localized(l10n))),
        );
    }
  }
}
