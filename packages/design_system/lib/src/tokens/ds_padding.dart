import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/painting.dart';

/// Directional (RTL-safe) padding presets built from [DSSpacing].
abstract final class DSPadding {
  static const EdgeInsetsDirectional screen = EdgeInsetsDirectional.symmetric(
    horizontal: DSSpacing.m,
  );
  static const EdgeInsetsDirectional card = EdgeInsetsDirectional.all(
    DSSpacing.m,
  );
  static const EdgeInsetsDirectional content = EdgeInsetsDirectional.all(
    DSSpacing.l,
  );
  static const EdgeInsetsDirectional listItem = EdgeInsetsDirectional.symmetric(
    horizontal: DSSpacing.m,
    vertical: DSSpacing.xs,
  );
}
