import 'package:design_system/src/theme/theme_context.dart';
import 'package:flutter/widgets.dart';

/// Shadows. Colors come from the theme so they stay visible in dark mode.
abstract final class DSElevation {
  static List<BoxShadow> card(BuildContext context) => [
    BoxShadow(
      color: context.dsColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> raised(BuildContext context) => [
    BoxShadow(
      color: context.dsColors.shadow,
      blurRadius: 32,
      offset: const Offset(0, 14),
    ),
  ];
}
