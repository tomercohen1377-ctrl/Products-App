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
    this.sizeAware = true,
    super.key,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  /// When false, skips the layout-driven `cacheWidth` decode and decodes at
  /// native resolution instead. Needed wherever this widget's size changes
  /// continuously frame to frame (e.g. as the child of a [Hero]'s
  /// `flightShuttleBuilder`): a `cacheWidth` tied to the current constraints
  /// changes every frame there, and Flutter treats each distinct
  /// `cacheWidth` as a fresh image to decode, causing visible flicker mid
  /// flight.
  final bool sizeAware;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final radius = borderRadius?.resolve(Directionality.of(context));

    final Widget image = (url == null || url.isEmpty)
        ? const _ImageFallback()
        : !sizeAware
        ? _NetworkImage(url: url, fit: fit, cacheWidth: null)
        : LayoutBuilder(
            builder: (context, constraints) {
              final pixelRatio = MediaQuery.devicePixelRatioOf(context);
              final width = constraints.hasBoundedWidth
                  ? (constraints.maxWidth * pixelRatio).round()
                  : null;
              return _NetworkImage(url: url, fit: fit, cacheWidth: width);
            },
          );

    return radius == null
        ? image
        : ClipRRect(borderRadius: radius, child: image);
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({
    required this.url,
    required this.fit,
    required this.cacheWidth,
  });

  final String url;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const _ImageBox(),
      Image.network(
        url,
        fit: fit,
        cacheWidth: cacheWidth,
        frameBuilder: (context, child, frame, loadedSync) => loadedSync
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
