import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/presentation/form/product_form_bloc.dart';
import 'package:products/src/presentation/form/product_form_content.dart';
import 'package:products/src/presentation/form/product_form_effect.dart';
import 'package:products/src/presentation/form/product_form_state.dart';

/// Container: needs a [ProductFormBloc] above it.
class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      MviView<ProductFormBloc, ProductFormState, ProductFormEffect>(
        onEffect: (context, effect) => switch (effect) {
          ProductSaved() => _saved(context),
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(
              state.isEditing
                  ? context.l10n.productEditTitle
                  : context.l10n.productCreateTitle,
            ),
          ),
          body: SafeArea(
            child: ProductFormContent(
              state: state,
              onIntent: context.read<ProductFormBloc>().add,
            ),
          ),
        ),
      );

  void _saved(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.productSaved)));
    context.pop();
  }
}
