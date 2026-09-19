import 'package:auth/src/presentation/account/account_sheet.dart';
import 'package:auth/src/presentation/login/login_content.dart';
import 'package:auth/src/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

/// Guards the "every widget has a preview" rule: each preview function must
/// build and lay out without exceptions, in both directions.
void main() {
  final previews = <String, Widget Function()>{
    'LoginContent empty': loginContentEmptyPreview,
    'LoginContent errors': loginContentErrorsPreview,
    'LoginContent submitting': loginContentSubmittingPreview,
    'LoginContent wrong credentials': loginContentFailedPreview,
    'LoginContent offline': loginContentOfflinePreview,
    'LoginContent expired': loginContentExpiredPreview,
    'SplashContent': splashContentPreview,
    'AccountSheetContent': accountSheetContentPreview,
    'AccountSheetContent offline': accountSheetContentOfflinePreview,
  };

  for (final MapEntry(key: name, value: build) in previews.entries) {
    for (final locale in const [Locale('en'), Locale('he')]) {
      testWidgets('$name preview builds in ${locale.languageCode}', (
        tester,
      ) async {
        await tester.pumpApp(
          SingleChildScrollView(child: build()),
          locale: locale,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
