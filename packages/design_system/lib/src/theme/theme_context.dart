import 'package:design_system/src/theme/ds_colors_extension.dart';
import 'package:design_system/src/theme/ds_typography_extension.dart';
import 'package:flutter/material.dart';

extension DSThemeContext on BuildContext {
  DSColorsExtension get dsColors =>
      Theme.of(this).extension<DSColorsExtension>()!;

  DSTypographyExtension get dsTypography =>
      Theme.of(this).extension<DSTypographyExtension>()!;
}
