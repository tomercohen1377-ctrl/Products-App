import 'package:design_system/src/theme/app_theme.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:l10n/l10n.dart';

/// Annotate every preview function with `@AppPreviews('WidgetName')`.
///
/// One annotation renders the widget in light, dark, Hebrew (RTL) and
/// 1.5x text, so no preview repeats theme or localization setup.
final class AppPreviews extends MultiPreview {
  const AppPreviews(this.group);

  /// Groups the four variants of one widget together in the previewer.
  final String group;

  @override
  List<Preview> get previews => const [
    Preview(
      name: 'Light',
      brightness: Brightness.light,
      theme: appPreviewTheme,
      localizations: englishPreviewLocalizations,
      size: Size.fromWidth(360),
      wrapper: appPreviewWrapper,
    ),
    Preview(
      name: 'Dark',
      brightness: Brightness.dark,
      theme: appPreviewTheme,
      localizations: englishPreviewLocalizations,
      size: Size.fromWidth(360),
      wrapper: appPreviewWrapper,
    ),
    Preview(
      name: 'Hebrew (RTL)',
      brightness: Brightness.light,
      theme: appPreviewTheme,
      localizations: hebrewPreviewLocalizations,
      size: Size.fromWidth(360),
      wrapper: appPreviewWrapper,
    ),
    Preview(
      name: 'Large text 1.5x',
      brightness: Brightness.light,
      textScaleFactor: 1.5,
      theme: appPreviewTheme,
      localizations: englishPreviewLocalizations,
      size: Size.fromWidth(360),
      wrapper: appPreviewWrapper,
    ),
  ];

  @override
  List<Preview> transform() => super.transform().map((preview) {
    final builder = preview.toBuilder()..group = group;
    return builder.build();
  }).toList();
}

PreviewThemeData appPreviewTheme() => const _AppPreviewThemeData();

PreviewLocalizationsData englishPreviewLocalizations() =>
    const PreviewLocalizationsData(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

PreviewLocalizationsData hebrewPreviewLocalizations() =>
    const PreviewLocalizationsData(
      locale: Locale('he'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );

/// Gives every preview the screen background and a little breathing room.
Widget appPreviewWrapper(Widget child) => Builder(
  builder: (context) => ColoredBox(
    color: context.dsColors.bgPrimary,
    child: Material(
      type: MaterialType.transparency,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

final class _AppPreviewThemeData extends PreviewThemeData {
  const _AppPreviewThemeData();

  @override
  Widget apply(BuildContext context, Widget child) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Theme(data: isDark ? AppTheme.dark : AppTheme.light, child: child);
  }
}
