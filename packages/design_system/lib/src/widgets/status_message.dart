import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:design_system/src/tokens/ds_dimensions.dart';
import 'package:design_system/src/tokens/ds_padding.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';

/// Shared layout for full-screen and inline status content (errors, empty
/// states), so [ErrorView] and [EmptyView] don't duplicate it.
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// Single-row layout for list footers and other tight spaces.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;

    if (compact) {
      return Padding(
        padding: DSPadding.listItem,
        child: Row(
          spacing: DSSpacing.s,
          children: [
            Icon(icon, size: DSDimensions.iconM, color: colors.txtTertiary),
            Expanded(
              child: Text(
                title,
                style: typography.small(color: colors.txtSecondary),
              ),
            ),
            ?action,
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: DSPadding.content,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DSSpacing.s,
          children: [
            Icon(icon, size: DSDimensions.iconXl, color: colors.txtTertiary),
            Text(title, style: typography.h3(), textAlign: TextAlign.center),
            if (message != null)
              Text(
                message!,
                style: typography.body(color: colors.txtSecondary),
                textAlign: TextAlign.center,
              ),
            if (action != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: DSSpacing.s),
                child: action,
              ),
          ],
        ),
      ),
    );
  }
}

@AppPreviews('StatusMessage')
Widget statusMessagePreview() => const Column(
  spacing: DSSpacing.l,
  children: [
    StatusMessage(
      icon: Icons.inbox_outlined,
      title: 'Nothing here yet',
      message: 'Items you add will show up here.',
    ),
    StatusMessage(
      icon: Icons.cloud_off,
      title: 'Compact variant',
      compact: true,
    ),
  ],
);
