import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:design_system/src/tokens/ds_corner_radius.dart';
import 'package:design_system/src/tokens/ds_dimensions.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The only way the app shows a remote image: decoded at the size it is
/// displayed (not at full resolution), faded in over a placeholder, with a
/// fallback for the dead or missing URLs this API is known to return.
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
              return Stack(
                fit: StackFit.expand,
                children: [
                  const _ImageBox(),
                  Image.network(
                    url,
                    fit: fit,
                    cacheWidth: width,
                    frameBuilder: (context, child, frame, loadedSync) =>
                        loadedSync
                        ? child
                        : AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 150),
                            child: child,
                          ),
                    errorBuilder: (_, _, _) => const _ImageFallback(),
                  ),
                ],
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
