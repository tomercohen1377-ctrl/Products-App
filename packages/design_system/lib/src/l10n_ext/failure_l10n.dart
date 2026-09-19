import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The single place a [Failure] becomes user-facing text and an icon.
extension FailureL10n on Failure {
  String localized(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    ValidationFailure(:final messages) =>
      messages.isEmpty ? l10n.errorValidation : messages.join('\n'),
    ServerFailure(:final statusCode) => l10n.errorServer(statusCode),
    UnknownFailure() => l10n.errorUnknown,
  };

  IconData get icon => switch (this) {
    NetworkFailure() || TimeoutFailure() => Icons.wifi_off_rounded,
    UnauthorizedFailure() => Icons.lock_outline_rounded,
    ValidationFailure() ||
    ServerFailure() ||
    UnknownFailure() => Icons.error_outline_rounded,
  };
}
