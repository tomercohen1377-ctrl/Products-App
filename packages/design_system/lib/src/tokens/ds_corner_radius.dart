import 'package:flutter/painting.dart';

/// Corner radii. The `*All` values are [BorderRadiusDirectional] so they
/// mirror correctly in RTL when a side-specific variant is added.
abstract final class DSCornerRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;

  static const BorderRadiusDirectional sAll = BorderRadiusDirectional.all(
    Radius.circular(s),
  );
  static const BorderRadiusDirectional mAll = BorderRadiusDirectional.all(
    Radius.circular(m),
  );
  static const BorderRadiusDirectional lAll = BorderRadiusDirectional.all(
    Radius.circular(l),
  );
  static const BorderRadiusDirectional xlAll = BorderRadiusDirectional.all(
    Radius.circular(xl),
  );
}
