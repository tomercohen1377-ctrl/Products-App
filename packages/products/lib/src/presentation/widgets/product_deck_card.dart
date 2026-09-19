import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/testing.dart';

/// A product as a full-bleed card: image, with the category, title and price
/// over a scrim.
class ProductDeckCard extends StatelessWidget {
  const ProductDeckCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    final category = product.category?.name;
    final radius = DSCornerRadius.xlAll.resolve(Directionality.of(context));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.dsColors.bgTertiary,
        borderRadius: radius,
        boxShadow: DSElevation.card(context),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: product.coverImage),
            // A fixed dark scrim: the text on it must be readable on any
            // image, in light and dark themes alike.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    DSColors.gray900.withValues(alpha: 0),
                    DSColors.gray900.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: DSSpacing.m,
              end: DSSpacing.m,
              bottom: DSSpacing.m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: DSSpacing.xs,
                children: [
                  if (category != null && category.isNotEmpty) AppTag(category),
                  Text(
                    product.title,
                    style: typography.h2(color: DSColors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  PriceLabel(
                    product.price,
                    style: typography.h1(color: DSColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@AppPreviews('ProductDeckCard')
Widget productDeckCardPreview() => const SizedBox(
  height: 420,
  child: ProductDeckCard(product: productFixture),
);
