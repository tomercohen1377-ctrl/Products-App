import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:design_system/src/tokens/ds_corner_radius.dart';
import 'package:design_system/src/tokens/ds_dimensions.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The only way the app shows a remote image: cached on disk, decoded at the
/// size it is displayed (not full resolution), with a fallback for the dead
/// or missing URLs this API is known to return.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final radius = borderRadius?.resolve(Directionality.of(context));

    final Widget image = (url == null || url.isEmpty)
        ? const _ImageFallback()
        : LayoutBuilder(
            builder: (context, constraints) {
              final pixelRatio = MediaQuery.devicePixelRatioOf(context);
              final width = constraints.hasBoundedWidth
                  ? (constraints.maxWidth * pixelRatio).round()
                  : null;
              return CachedNetworkImage(
                imageUrl: url,
                fit: fit,
                memCacheWidth: width,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, _) => const _ImageBox(),
                errorWidget: (_, _, _) => const _ImageFallback(),
              );
            },
          );

    return radius == null
        ? image
        : ClipRRect(borderRadius: radius, child: image);
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: context.dsColors.bgTertiary, child: child);
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.imageUnavailable,
    image: true,
    child: _ImageBox(
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: DSDimensions.iconL,
          color: context.dsColors.txtTertiary,
        ),
      ),
    ),
  );
}

@AppPreviews('AppNetworkImage')
Widget appNetworkImagePreview() => const Row(
  spacing: DSSpacing.m,
  children: [
    Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: AppNetworkImage(
          url: 'https://i.imgur.com/1twoaDy.jpeg',
          borderRadius: DSCornerRadius.mAll,
        ),
      ),
    ),
    Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: AppNetworkImage(url: null, borderRadius: DSCornerRadius.mAll),
      ),
    ),
  ],
);
