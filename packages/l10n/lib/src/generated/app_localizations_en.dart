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

  @override
  String get cancel => 'Cancel';

  @override
  String get productAdd => 'Add product';

  @override
  String get productEdit => 'Edit';

  @override
  String get productDelete => 'Delete';

  @override
  String get productDeleteTitle => 'Delete this product?';

  @override
  String productDeleteMessage(String title) {
    return '\"$title\" will be removed. This can\'t be undone.';
  }

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get productSaved => 'Product saved';

  @override
  String get productCreateTitle => 'New product';

  @override
  String get productEditTitle => 'Edit product';

  @override
  String get productFieldTitle => 'Title';

  @override
  String get productFieldPrice => 'Price';

  @override
  String get productFieldDescription => 'Description';

  @override
  String get productFieldCategory => 'Category';

  @override
  String get productImagesTitle => 'Images';

  @override
  String get productImageUrlLabel => 'Image URL';

  @override
  String get productImageAdd => 'Add image';

  @override
  String get productImageRemove => 'Remove image';

  @override
  String get productImagesRequired => 'Add at least one image';

  @override
  String get productCategoriesEmpty =>
      'There are no categories yet, so a product can\'t be created right now.';

  @override
  String get productSubmitCreate => 'Create product';

  @override
  String get productSubmitSave => 'Save changes';

  @override
  String productImageCounter(int current, int total) {
    return 'Image $current of $total';
  }

  @override
  String get productsViewList => 'List';

  @override
  String get productsViewDeck => 'Deck';

  @override
  String get deckLike => 'Like';

  @override
  String get deckSkip => 'Skip';

  @override
  String deckLikedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count liked',
      one: '1 liked',
      zero: 'No likes yet',
    );
    return '$_temp0';
  }

  @override
  String get deckEmptyTitle => 'You\'ve seen everything';

  @override
  String get deckEmptyMessage =>
      'That was the last product. Start over to go through them again.';

  @override
  String get deckStartOver => 'Start over';

  @override
  String get productImageUpload => 'Upload photo';
}
