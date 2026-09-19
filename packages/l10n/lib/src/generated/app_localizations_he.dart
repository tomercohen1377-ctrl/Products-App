// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מוצרי Mylo';

  @override
  String get retry => 'נסו שוב';

  @override
  String get loading => 'טוען';

  @override
  String get emptyTitle => 'אין כאן עדיין כלום';

  @override
  String get imageUnavailable => 'התמונה אינה זמינה';

  @override
  String get showPassword => 'הצגת סיסמה';

  @override
  String get hidePassword => 'הסתרת סיסמה';

  @override
  String get errorNetwork => 'אין חיבור לאינטרנט. בדקו את הרשת ונסו שוב.';

  @override
  String get errorTimeout => 'הבקשה נמשכה יותר מדי זמן. נסו שוב.';

  @override
  String get errorUnauthorized => 'פג תוקף ההתחברות. יש להתחבר מחדש.';

  @override
  String errorServer(int statusCode) {
    return 'אירעה תקלה בשרת (קוד $statusCode). נסו שוב מאוחר יותר.';
  }

  @override
  String get errorValidation => 'חלק מהפרטים אינם תקינים.';

  @override
  String get errorUnknown => 'משהו השתבש. נסו שוב.';

  @override
  String get fieldRequired => 'שדה חובה';

  @override
  String get fieldInvalidEmail => 'הזינו כתובת אימייל תקינה';

  @override
  String get fieldInvalidNumber => 'הזינו מספר תקין';

  @override
  String get fieldNotPositive => 'הערך חייב להיות גדול מאפס';

  @override
  String get fieldInvalidUrl => 'הזינו קישור http(s) תקין';

  @override
  String get productsTitle => 'מוצרים';

  @override
  String get loginTitle => 'ברוכים השבים';

  @override
  String get loginSubtitle => 'התחברו כדי לנהל את המוצרים שלכם';

  @override
  String get loginEmailLabel => 'אימייל';

  @override
  String get loginPasswordLabel => 'סיסמה';

  @override
  String get loginSubmit => 'התחברות';

  @override
  String get loginInvalidCredentials => 'אימייל או סיסמה שגויים.';

  @override
  String get accountTooltip => 'חשבון';

  @override
  String get accountSignedInAs => 'מחובר בתור';

  @override
  String get accountSignOut => 'התנתקות';

  @override
  String get refresh => 'רענון';

  @override
  String get productsEmptyTitle => 'אין מוצרים עדיין';

  @override
  String get productsEmptyMessage => 'מוצרים שתוסיפו יופיעו כאן.';

  @override
  String get cancel => 'ביטול';

  @override
  String get productAdd => 'הוספת מוצר';

  @override
  String get productEdit => 'עריכה';

  @override
  String get productDelete => 'מחיקה';

  @override
  String get productDeleteTitle => 'למחוק את המוצר?';

  @override
  String productDeleteMessage(String title) {
    return '\"$title\" יוסר. אי אפשר לבטל פעולה זו.';
  }

  @override
  String get productDeleted => 'המוצר נמחק';

  @override
  String get productSaved => 'המוצר נשמר';

  @override
  String get productCreateTitle => 'מוצר חדש';

  @override
  String get productEditTitle => 'עריכת מוצר';

  @override
  String get productFieldTitle => 'שם';

  @override
  String get productFieldPrice => 'מחיר';

  @override
  String get productFieldDescription => 'תיאור';

  @override
  String get productFieldCategory => 'קטגוריה';

  @override
  String get productImagesTitle => 'תמונות';

  @override
  String get productImageUrlLabel => 'כתובת תמונה';

  @override
  String get productImageAdd => 'הוספת תמונה';

  @override
  String get productImageRemove => 'הסרת תמונה';

  @override
  String get productImagesRequired => 'יש להוסיף לפחות תמונה אחת';

  @override
  String get productCategoriesEmpty =>
      'אין קטגוריות עדיין, ולכן אי אפשר ליצור מוצר כרגע.';

  @override
  String get productSubmitCreate => 'יצירת מוצר';

  @override
  String get productSubmitSave => 'שמירת שינויים';

  @override
  String productImageCounter(int current, int total) {
    return 'תמונה $current מתוך $total';
  }

  @override
  String get productsViewList => 'רשימה';

  @override
  String get productsViewDeck => 'חפיסה';

  @override
  String get deckLike => 'אהבתי';

  @override
  String get deckSkip => 'דלג';

  @override
  String deckLikedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'אהבתם $count מוצרים',
      one: 'אהבתם מוצר אחד',
      zero: 'אין אהבתי עדיין',
    );
    return '$_temp0';
  }

  @override
  String get deckEmptyTitle => 'ראיתם הכול';

  @override
  String get deckEmptyMessage =>
      'זה היה המוצר האחרון. התחילו מחדש כדי לעבור עליהם שוב.';

  @override
  String get deckStartOver => 'התחלה מחדש';
}
