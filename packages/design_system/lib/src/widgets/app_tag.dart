import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:design_system/src/tokens/ds_corner_radius.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';

/// A small pill label, e.g. a product's category.
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.brandSubtle,
        borderRadius: DSCornerRadius.lAll,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DSSpacing.s,
          vertical: DSSpacing.xxs,
        ),
        child: Text(
          label,
          style: context.dsTypography.caption(color: colors.brand),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

@AppPreviews('AppTag')
Widget appTagPreview() => const Wrap(
  spacing: DSSpacing.xs,
  children: [AppTag('Clothes'), AppTag('Electronics')],
);
