import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mylo Products'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem (code {statusCode}). Please try again later.'**
  String errorServer(int statusCode);

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some of the information isn\'t valid.'**
  String get errorValidation;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @fieldInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get fieldInvalidEmail;

  /// No description provided for @fieldInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get fieldInvalidNumber;

  /// No description provided for @fieldNotPositive.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than zero'**
  String get fieldNotPositive;

  /// No description provided for @fieldInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) link'**
  String get fieldInvalidUrl;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your products'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginInvalidCredentials;

  /// No description provided for @accountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTooltip;

  /// No description provided for @accountSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get accountSignedInAs;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Products you add will show up here.'**
  String get productsEmptyMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @productAdd.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get productAdd;

  /// No description provided for @productEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get productEdit;

  /// No description provided for @productDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get productDelete;

  /// No description provided for @productDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this product?'**
  String get productDeleteTitle;

  /// No description provided for @productDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed. This can\'t be undone.'**
  String productDeleteMessage(String title);

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productSaved;

  /// No description provided for @productCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get productCreateTitle;

  /// No description provided for @productEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get productEditTitle;

  /// No description provided for @productFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get productFieldTitle;

  /// No description provided for @productFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productFieldPrice;

  /// No description provided for @productFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productFieldDescription;

  /// No description provided for @productFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productFieldCategory;

  /// No description provided for @productImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get productImagesTitle;

  /// No description provided for @productImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get productImageUrlLabel;

  /// No description provided for @productImageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get productImageAdd;

  /// No description provided for @productImageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get productImageRemove;

  /// No description provided for @productImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one image'**
  String get productImagesRequired;

  /// No description provided for @productCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no categories yet, so a product can\'t be created right now.'**
  String get productCategoriesEmpty;

  /// No description provided for @productSubmitCreate.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get productSubmitCreate;

  /// No description provided for @productSubmitSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get productSubmitSave;

  /// No description provided for @productImageCounter.
  ///
  /// In en, this message translates to:
  /// **'Image {current} of {total}'**
  String productImageCounter(int current, int total);

  /// No description provided for @productsViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get productsViewList;

  /// No description provided for @productsViewDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get productsViewDeck;

  /// No description provided for @deckLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get deckLike;

  /// No description provided for @deckSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get deckSkip;

  /// No description provided for @deckLikedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No likes yet} =1{1 liked} other{{count} liked}}'**
  String deckLikedCount(int count);

  /// No description provided for @deckEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen everything'**
  String get deckEmptyTitle;

  /// No description provided for @deckEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'That was the last product. Start over to go through them again.'**
  String get deckEmptyMessage;

  /// No description provided for @deckStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get deckStartOver;

  /// No description provided for @productImageUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get productImageUpload;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
