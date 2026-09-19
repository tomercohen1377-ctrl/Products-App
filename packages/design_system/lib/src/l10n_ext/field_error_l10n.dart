import 'package:core/core.dart';
import 'package:l10n/l10n.dart';

/// The single place a form [FieldError] becomes user-facing text.
extension FieldErrorL10n on FieldError {
  String localized(AppLocalizations l10n) => switch (this) {
    FieldError.required => l10n.fieldRequired,
    FieldError.invalidEmail => l10n.fieldInvalidEmail,
    FieldError.invalidNumber => l10n.fieldInvalidNumber,
    FieldError.notPositive => l10n.fieldNotPositive,
    FieldError.invalidUrl => l10n.fieldInvalidUrl,
  };
}
