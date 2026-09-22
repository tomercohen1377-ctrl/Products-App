import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/presentation/detail/product_detail_intent.dart';
import 'package:products/src/presentation/detail/product_detail_state.dart';
import 'package:products/src/presentation/widgets/product_image_gallery.dart';
import 'package:products/testing.dart';

/// The product page. Pure: renders [state] and reports [onIntent].
class ProductDetailContent extends StatelessWidget {
  const ProductDetailContent({
    required this.state,
    required this.onIntent,
    super.key,
  });

  final ProductDetailState state;
  final void Function(ProductDetailIntent intent) onIntent;

  @override
  Widget build(BuildContext context) {
    final product = state.product;
    return AsyncContent(
      isLoading: state.isLoading,
      failure: state.blockingFailure,
      onRetry: () => onIntent(const ProductDetailStarted()),
      child: product == null
          ? const SizedBox.shrink()
          : _Body(product: product, isDeleting: state.isDeleting),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.product, required this.isDeleting});

  final Product product;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final category = product.category?.name;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductImageGallery(
            key: ValueKey(product.images),
            images: product.images,
            heroTag: 'product-image-${product.id}',
          ),
          if (isDeleting) const LinearProgressIndicator(),
          Padding(
            padding: DSPadding.content,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DSSpacing.s,
              children: [
                if (category != null && category.isNotEmpty) AppTag(category),
                Text(product.title, style: typography.h2()),
                PriceLabel(
                  product.price,
                  style: typography.h1(color: colors.brand),
                ),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: typography.body(color: colors.txtSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The app-bar actions for the product page.
class ProductDetailActions extends StatelessWidget {
  const ProductDetailActions({
    required this.state,
    required this.onIntent,
    super.key,
  });

  final ProductDetailState state;
  final void Function(ProductDetailIntent intent) onIntent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.productEdit,
          icon: const Icon(Icons.edit_outlined),
          onPressed: state.canAct
              ? () => onIntent(const ProductDetailEditTapped())
              : null,
        ),
        IconButton(
          tooltip: l10n.productDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: state.canAct
              ? () => onIntent(const ProductDetailDeleteTapped())
              : null,
        ),
      ],
    );
  }
}

Widget _content(ProductDetailState state) => SizedBox(
  height: 640,
  child: ProductDetailContent(state: state, onIntent: (_) {}),
);

@AppPreviews('ProductDetailContent: loaded')
Widget productDetailContentPreview() => _content(
  const ProductDetailState(
    phase: ProductDetailPhase.ready,
    product: productFixture,
  ),
);

@AppPreviews('ProductDetailContent: loading')
Widget productDetailContentLoadingPreview() =>
    _content(const ProductDetailState());

@AppPreviews('ProductDetailContent: failed')
Widget productDetailContentFailedPreview() => _content(
  const ProductDetailState(
    phase: ProductDetailPhase.failure,
    failure: NetworkFailure(),
  ),
);

@AppPreviews('ProductDetailContent: deleting')
Widget productDetailContentDeletingPreview() => _content(
  const ProductDetailState(
    phase: ProductDetailPhase.ready,
    product: productFixture,
    isDeleting: true,
  ),
);

@AppPreviews('ProductDetailActions')
Widget productDetailActionsPreview() => Column(
  children: [
    ProductDetailActions(
      state: const ProductDetailState(
        phase: ProductDetailPhase.ready,
        product: productFixture,
      ),
      onIntent: (_) {},
    ),
    ProductDetailActions(state: const ProductDetailState(), onIntent: (_) {}),
  ],
);
