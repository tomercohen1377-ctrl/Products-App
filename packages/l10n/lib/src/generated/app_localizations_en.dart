// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mylo Products';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String errorServer(int statusCode) {
    return 'The server had a problem (code $statusCode). Please try again later.';
  }

  @override
  String get errorValidation => 'Some of the information isn\'t valid.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get fieldInvalidEmail => 'Enter a valid email address';

  @override
  String get fieldInvalidNumber => 'Enter a valid number';

  @override
  String get fieldNotPositive => 'Must be greater than zero';

  @override
  String get fieldInvalidUrl => 'Enter a valid http(s) link';

  @override
  String get productsTitle => 'Products';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your products';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginInvalidCredentials => 'Incorrect email or password.';

  @override
  String get accountTooltip => 'Account';

  @override
  String get accountSignedInAs => 'Signed in as';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get refresh => 'Refresh';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyMessage => 'Products you add will show up here.';
}
