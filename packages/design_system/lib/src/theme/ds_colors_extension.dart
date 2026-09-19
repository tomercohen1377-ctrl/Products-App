import 'package:design_system/src/theme/ds_colors.dart';
import 'package:flutter/material.dart';

/// Semantic colors, resolved from the theme so they follow light/dark.
///
/// Read with `context.dsColors`.
@immutable
class DSColorsExtension extends ThemeExtension<DSColorsExtension> {
  const DSColorsExtension({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.txtPrimary,
    required this.txtSecondary,
    required this.txtTertiary,
    required this.txtOnBrand,
    required this.brand,
    required this.brandSubtle,
    required this.border,
    required this.success,
    required this.error,
    required this.errorSubtle,
    required this.shadow,
  });

  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color txtPrimary;
  final Color txtSecondary;
  final Color txtTertiary;
  final Color txtOnBrand;
  final Color brand;
  final Color brandSubtle;
  final Color border;
  final Color success;
  final Color error;
  final Color errorSubtle;
  final Color shadow;

  static const DSColorsExtension light = DSColorsExtension(
    bgPrimary: DSColors.gray50,
    bgSecondary: DSColors.white,
    bgTertiary: DSColors.gray100,
    txtPrimary: DSColors.gray900,
    txtSecondary: DSColors.gray600,
    txtTertiary: DSColors.gray400,
    txtOnBrand: DSColors.white,
    brand: DSColors.indigo600,
    brandSubtle: DSColors.indigo100,
    border: DSColors.gray200,
    success: DSColors.green600,
    error: DSColors.red600,
    errorSubtle: DSColors.red100,
    shadow: DSColors.shadowLight,
  );

  static const DSColorsExtension dark = DSColorsExtension(
    bgPrimary: DSColors.ink900,
    bgSecondary: DSColors.ink800,
    bgTertiary: DSColors.ink700,
    txtPrimary: DSColors.ink100,
    txtSecondary: DSColors.ink300,
    txtTertiary: DSColors.ink500,
    txtOnBrand: DSColors.white,
    brand: DSColors.indigo400,
    brandSubtle: DSColors.indigo900,
    border: DSColors.ink600,
    success: DSColors.green400,
    error: DSColors.red400,
    errorSubtle: DSColors.red900,
    shadow: DSColors.shadowDark,
  );

  @override
  DSColorsExtension copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? txtPrimary,
    Color? txtSecondary,
    Color? txtTertiary,
    Color? txtOnBrand,
    Color? brand,
    Color? brandSubtle,
    Color? border,
    Color? success,
    Color? error,
    Color? errorSubtle,
    Color? shadow,
  }) => DSColorsExtension(
    bgPrimary: bgPrimary ?? this.bgPrimary,
    bgSecondary: bgSecondary ?? this.bgSecondary,
    bgTertiary: bgTertiary ?? this.bgTertiary,
    txtPrimary: txtPrimary ?? this.txtPrimary,
    txtSecondary: txtSecondary ?? this.txtSecondary,
    txtTertiary: txtTertiary ?? this.txtTertiary,
    txtOnBrand: txtOnBrand ?? this.txtOnBrand,
    brand: brand ?? this.brand,
    brandSubtle: brandSubtle ?? this.brandSubtle,
    border: border ?? this.border,
    success: success ?? this.success,
    error: error ?? this.error,
    errorSubtle: errorSubtle ?? this.errorSubtle,
    shadow: shadow ?? this.shadow,
  );

  @override
  DSColorsExtension lerp(DSColorsExtension? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DSColorsExtension(
      bgPrimary: mix(bgPrimary, other.bgPrimary),
      bgSecondary: mix(bgSecondary, other.bgSecondary),
      bgTertiary: mix(bgTertiary, other.bgTertiary),
      txtPrimary: mix(txtPrimary, other.txtPrimary),
      txtSecondary: mix(txtSecondary, other.txtSecondary),
      txtTertiary: mix(txtTertiary, other.txtTertiary),
      txtOnBrand: mix(txtOnBrand, other.txtOnBrand),
      brand: mix(brand, other.brand),
      brandSubtle: mix(brandSubtle, other.brandSubtle),
      border: mix(border, other.border),
      success: mix(success, other.success),
      error: mix(error, other.error),
      errorSubtle: mix(errorSubtle, other.errorSubtle),
      shadow: mix(shadow, other.shadow),
    );
  }
}
