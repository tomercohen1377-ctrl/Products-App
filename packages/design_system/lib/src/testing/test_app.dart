import 'package:design_system/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// A minimal themed, localized app shell for widget tests, so no package
/// re-creates the same `MaterialApp` boilerplate.
class TestApp extends StatelessWidget {
  const TestApp({
    required this.child,
    this.locale = const Locale('en'),
    this.brightness = Brightness.light,
    super.key,
  });

  final Widget child;
  final Locale locale;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
