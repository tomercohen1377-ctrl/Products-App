import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// Shown while the stored session is being checked on cold start.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: SplashContent());
}

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: DSSpacing.l,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.brand,
              borderRadius: DSCornerRadius.xlAll,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(DSSpacing.l),
              child: Icon(
                Icons.storefront_rounded,
                size: DSDimensions.iconXl,
                color: colors.txtOnBrand,
              ),
            ),
          ),
          Text(context.l10n.appTitle, style: context.dsTypography.h2()),
          const AppLoader.small(),
        ],
      ),
    );
  }
}

@AppPreviews('SplashContent')
Widget splashContentPreview() =>
    const SizedBox(height: 360, child: SplashContent());
