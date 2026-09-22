import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:products/testing.dart';

/// A swipeable square gallery with page dots. Falls back to a single
/// placeholder when there are no images.
class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({required this.images, this.heroTag, super.key});

  final List<String> images;

  /// When set, wraps the cover image (page 0) in a [Hero] with this tag,
  /// e.g. to fly in from a matching tag in a list tile.
  final Object? heroTag;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final url = images.isEmpty ? null : images[index];
              final image = AppNetworkImage(url: url);
              final heroTag = widget.heroTag;
              return index == 0 && heroTag != null
                  ? Hero(
                      tag: heroTag,
                      // See product_tile.dart: avoids re-decode flicker
                      // during the flight.
                      flightShuttleBuilder: (_, _, _, _, _) =>
                          AppNetworkImage(url: url, sizeAware: false),
                      child: image,
                    )
                  : image;
            },
          ),
          if (images.length > 1)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: DSSpacing.s,
              child: _PageDots(count: images.length, current: _page),
            ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    return Semantics(
      container: true,
      label: context.l10n.productImageCounter(current + 1, count),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.txtPrimary.withValues(alpha: 0.35),
            borderRadius: DSCornerRadius.lAll,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DSSpacing.xs,
              vertical: DSSpacing.xxs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DSSpacing.xxs,
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: i == current ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == current
                          ? colors.bgSecondary
                          : colors.bgSecondary.withValues(alpha: 0.6),
                      borderRadius: DSCornerRadius.sAll,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@AppPreviews('ProductImageGallery')
Widget productImageGalleryPreview() =>
    ProductImageGallery(images: productFixture.images);

@AppPreviews('ProductImageGallery: no images')
Widget productImageGalleryEmptyPreview() =>
    const ProductImageGallery(images: []);
