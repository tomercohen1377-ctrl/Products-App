import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:design_system/src/tokens/ds_corner_radius.dart';
import 'package:design_system/src/tokens/ds_dimensions.dart';
import 'package:design_system/src/tokens/ds_padding.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';

enum AppBannerTone { info, error }

/// An inline message strip for form-level feedback. Announced to screen
/// readers when it appears.
class AppBanner extends StatelessWidget {
  const AppBanner({
    required this.message,
    this.tone = AppBannerTone.info,
    super.key,
  });

  final String message;
  final AppBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final isError = tone == AppBannerTone.error;
    final foreground = isError ? colors.error : colors.brand;

    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isError ? colors.errorSubtle : colors.brandSubtle,
          borderRadius: DSCornerRadius.mAll,
        ),
        child: Padding(
          padding: DSPadding.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DSSpacing.s,
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                size: DSDimensions.iconM,
                color: foreground,
              ),
              Expanded(
                child: Text(
                  message,
                  style: context.dsTypography.small(color: colors.txtPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@AppPreviews('AppBanner')
Widget appBannerPreview() => const Column(
  spacing: DSSpacing.m,
  children: [
    AppBanner(message: 'Your session has expired. Please sign in again.'),
    AppBanner(
      message: 'Incorrect email or password.',
      tone: AppBannerTone.error,
    ),
  ],
);
