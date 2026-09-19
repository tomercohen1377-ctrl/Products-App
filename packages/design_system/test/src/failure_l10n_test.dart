import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

void main() {
  late final Map<String, AppLocalizations> locales;
  late final AppLocalizations en;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    final he = await AppLocalizations.delegate.load(const Locale('he'));
    locales = {'en': en, 'he': he};
  });

  final failures = <Failure>[
    const NetworkFailure(),
    const TimeoutFailure(),
    const UnauthorizedFailure(),
    const ValidationFailure(),
    const ServerFailure(statusCode: 500),
    const UnknownFailure(),
  ];

  test('every failure has a non-empty message in each locale', () {
    for (final MapEntry(key: code, value: l10n) in locales.entries) {
      for (final failure in failures) {
        expect(failure.localized(l10n), isNotEmpty, reason: '$code $failure');
      }
    }
  });

  test('server status code is included in the message', () {
    expect(const ServerFailure(statusCode: 503).localized(en), contains('503'));
  });

  test('validation failure shows server messages when present', () {
    final l10n = en;
    expect(
      const ValidationFailure(messages: ['a', 'b']).localized(l10n),
      'a\nb',
    );
    expect(const ValidationFailure().localized(l10n), l10n.errorValidation);
  });

  test('connectivity failures share the offline icon', () {
    expect(const NetworkFailure().icon, Icons.wifi_off_rounded);
    expect(const TimeoutFailure().icon, Icons.wifi_off_rounded);
    expect(const UnauthorizedFailure().icon, Icons.lock_outline_rounded);
    expect(const UnknownFailure().icon, Icons.error_outline_rounded);
  });

  test('every field error has a message in each locale', () {
    for (final l10n in locales.values) {
      for (final error in FieldError.values) {
        expect(error.localized(l10n), isNotEmpty, reason: '$error');
      }
    }
  });
}
