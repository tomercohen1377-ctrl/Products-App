import 'package:design_system/src/theme/ds_colors_extension.dart';
import 'package:design_system/src/theme/ds_typography_extension.dart';
import 'package:design_system/src/tokens/ds_corner_radius.dart';
import 'package:design_system/src/tokens/ds_dimensions.dart';
import 'package:flutter/material.dart';

/// The app's light and dark [ThemeData], built once from semantic tokens.
abstract final class AppTheme {
  static final ThemeData light = _build(
    DSColorsExtension.light,
    Brightness.light,
  );
  static final ThemeData dark = _build(DSColorsExtension.dark, Brightness.dark);

  static ThemeData _build(DSColorsExtension c, Brightness brightness) {
    const typography = DSTypographyExtension();
    final scheme =
        ColorScheme.fromSeed(
          seedColor: c.brand,
          brightness: brightness,
        ).copyWith(
          primary: c.brand,
          onPrimary: c.txtOnBrand,
          surface: c.bgSecondary,
          onSurface: c.txtPrimary,
          onSurfaceVariant: c.txtSecondary,
          error: c.error,
          outline: c.border,
          outlineVariant: c.border,
        );
    final base = ThemeData(brightness: brightness);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DSCornerRadius.m),
    );
    const buttonSize = Size(0, DSDimensions.buttonHeight);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSCornerRadius.m),
      borderSide: BorderSide(color: c.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bgPrimary,
      canvasColor: c.bgPrimary,
      extensions: [c, typography],
      textTheme: base.textTheme.apply(
        bodyColor: c.txtPrimary,
        displayColor: c.txtPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgPrimary,
        foregroundColor: c.txtPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: typography.h3(color: c.txtPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bgSecondary,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.brand, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.error, width: 2),
        ),
        labelStyle: typography.body(color: c.txtSecondary),
        errorStyle: typography.caption(color: c.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: typography.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          side: BorderSide(color: c.border),
          foregroundColor: c.txtPrimary,
          textStyle: typography.button(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: typography.button(),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: buttonShape,
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1),
    );
  }
}
