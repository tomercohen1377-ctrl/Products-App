import 'package:flutter/widgets.dart';
import 'package:l10n/src/generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
