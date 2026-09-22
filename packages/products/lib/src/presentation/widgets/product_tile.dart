import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/testing.dart';

/// A product row: thumbnail, category, title and price.
class ProductTile extends StatelessWidget {
  const ProductTile({required this.product, this.onTap, super.key});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final category = product.category?.name;

    return Material(
      color: colors.bgSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: DSCornerRadius.lAll,
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: DSPadding.card,
          child: Row(
            spacing: DSSpacing.m,
            children: [
              SizedBox.square(
                dimension: DSDimensions.thumbnail,
                child: AppNetworkImage(
                  url: product.coverImage,
                  borderRadius: DSCornerRadius.mAll,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DSSpacing.xxs,
                  children: [
                    if (category != null && category.isNotEmpty)
                      Text(
                        category,
                        style: typography.caption(color: colors.txtSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      product.title,
                      style: typography.bodyStrong(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    PriceLabel(product.price),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@AppPreviews('ProductTile')
Widget productTilePreview() => Column(
  spacing: DSSpacing.s,
  children: [
    ProductTile(product: productFixture, onTap: () {}),
    ProductTile(
      product: const Product(
        id: 1,
        title: 'A remarkably long product title that has to wrap onto a second line and then stop',
        price: 1234567,
        description: '',
        images: [],
      ),
      onTap: () {},
    ),
  ],
);
