import 'package:flutter/material.dart';

/// Text styles. Omit `color` to inherit the theme's text color; pass a
/// semantic color (`context.dsColors.txtSecondary`) to override.
///
/// Read with `context.dsTypography`.
@immutable
class DSTypographyExtension extends ThemeExtension<DSTypographyExtension> {
  const DSTypographyExtension();

  TextStyle h1({Color? color}) => _style(28, FontWeight.w700, 1.2, color);
  TextStyle h2({Color? color}) => _style(22, FontWeight.w700, 1.25, color);
  TextStyle h3({Color? color}) => _style(18, FontWeight.w600, 1.3, color);
  TextStyle body({Color? color}) => _style(16, FontWeight.w400, 1.4, color);
  TextStyle bodyStrong({Color? color}) =>
      _style(16, FontWeight.w600, 1.4, color);
  TextStyle small({Color? color}) => _style(14, FontWeight.w400, 1.4, color);
  TextStyle caption({Color? color}) => _style(12, FontWeight.w500, 1.3, color);
  TextStyle button({Color? color}) => _style(16, FontWeight.w600, 1.2, color);

  TextStyle _style(
    double size,
    FontWeight weight,
    double height,
    Color? color,
  ) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  @override
  DSTypographyExtension copyWith() => this;

  @override
  DSTypographyExtension lerp(DSTypographyExtension? other, double t) => this;
}
