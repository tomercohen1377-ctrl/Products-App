import 'dart:ui';

/// Raw palette. Widgets never use these directly; they read semantic tokens
/// from `DSColorsExtension` so light and dark stay in sync.
abstract final class DSColors {
  // Neutrals (light)
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF7F7FA);
  static const Color gray100 = Color(0xFFEEF0F5);
  static const Color gray200 = Color(0xFFE1E4EC);
  static const Color gray400 = Color(0xFF8B90A0);
  static const Color gray600 = Color(0xFF5C6070);
  static const Color gray900 = Color(0xFF14151A);

  // Neutrals (dark)
  static const Color ink900 = Color(0xFF0E0F13);
  static const Color ink800 = Color(0xFF17181D);
  static const Color ink700 = Color(0xFF22242B);
  static const Color ink600 = Color(0xFF2C2F3A);
  static const Color ink100 = Color(0xFFF3F4F7);
  static const Color ink300 = Color(0xFFA6ABBA);
  static const Color ink500 = Color(0xFF7A8092);

  // Brand
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo900 = Color(0xFF24264A);

  // Status
  static const Color green600 = Color(0xFF16A34A);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red400 = Color(0xFFF87171);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red900 = Color(0xFF3A1D1F);

  static const Color shadowLight = Color(0x1F14151A);
  static const Color shadowDark = Color(0x66000000);
}
