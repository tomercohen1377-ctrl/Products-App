import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/tokens/ds_dimensions.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// A centered spinner, or a fixed-size inline one via [AppLoader.small].
class AppLoader extends StatelessWidget {
  const AppLoader({this.size, this.color, super.key});

  const AppLoader.small({Color? color, Key? key})
    : this(size: DSDimensions.loaderSmall, color: color, key: key);

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final indicator = CircularProgressIndicator(
      strokeWidth: size == null ? 4 : 2,
      color: color,
    );
    return Semantics(
      label: context.l10n.loading,
      child: size == null
          ? Center(child: indicator)
          : SizedBox.square(dimension: size, child: indicator),
    );
  }
}

@AppPreviews('AppLoader')
Widget appLoaderPreview() => const Row(
  spacing: DSSpacing.l,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    AppLoader.small(),
    SizedBox(height: 80, child: AppLoader()),
  ],
);
