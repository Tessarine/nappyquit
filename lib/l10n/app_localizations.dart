import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('hu')];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Potty Training'**
  String get appTitle;

  /// Label for the activity recording section
  ///
  /// In en, this message translates to:
  /// **'Record Activity'**
  String get recordActivity;

  /// Activity type: tried to go to the potty
  ///
  /// In en, this message translates to:
  /// **'Tried the potty'**
  String get triedThePotty;

  /// Activity type: successfully used the potty
  ///
  /// In en, this message translates to:
  /// **'Used the potty'**
  String get usedThePotty;

  /// Activity type: had an accident
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get accident;

  /// Activity type: drank water
  ///
  /// In en, this message translates to:
  /// **'Drank water'**
  String get drankWater;

  /// Water amount: drank a small amount of water
  ///
  /// In en, this message translates to:
  /// **'Some water'**
  String get drankSomeWater;

  /// Water amount: drank a large amount of water
  ///
  /// In en, this message translates to:
  /// **'Lots of water'**
  String get drankLotsOfWater;

  /// Activity type: ate food
  ///
  /// In en, this message translates to:
  /// **'Ate food'**
  String get ateFood;

  /// Activity type: nappy was changed
  ///
  /// In en, this message translates to:
  /// **'Nappy'**
  String get nappy;

  /// Bodily function: pee
  ///
  /// In en, this message translates to:
  /// **'Pee'**
  String get pee;

  /// Bodily function: poo
  ///
  /// In en, this message translates to:
  /// **'Poo'**
  String get poo;

  /// Bodily function: both pee and poo
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// Bodily function: none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Initiative type: child told parents
  ///
  /// In en, this message translates to:
  /// **'Told parents'**
  String get toldParents;

  /// Initiative type: child went by himself
  ///
  /// In en, this message translates to:
  /// **'Went by himself'**
  String get wentByHimself;

  /// Initiative type: child asked to sit
  ///
  /// In en, this message translates to:
  /// **'Asked to sit'**
  String get askedToSit;

  /// Prompt to select the bodily function
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get selectBodilyFunction;

  /// Prompt to select the initiative type
  ///
  /// In en, this message translates to:
  /// **'How did it happen?'**
  String get selectInitiative;

  /// Prompt to select the water amount
  ///
  /// In en, this message translates to:
  /// **'How much water?'**
  String get selectWaterAmount;

  /// Title for the date/time picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateAndTime;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirmation message for deleting a log entry
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get confirmDelete;

  /// Message shown when there are no log entries
  ///
  /// In en, this message translates to:
  /// **'No activities recorded yet'**
  String get noLogEntries;

  /// Label for today's date
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for yesterday's date
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Help button tooltip
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Title of the help dialog
  ///
  /// In en, this message translates to:
  /// **'How to Use the Toot\'N\'Tinkle App'**
  String get helpTitle;

  /// Section title for main page instructions
  ///
  /// In en, this message translates to:
  /// **'Main Page'**
  String get helpMainPage;

  /// Description of the main page functionality
  ///
  /// In en, this message translates to:
  /// **'The main page shows your Toot\'N\'Tinkle log history. Each entry includes the time, activity type, and any relevant details. You can edit or delete entries using the buttons on the right.'**
  String get helpMainPageDescription;

  /// Section title for activity buttons instructions
  ///
  /// In en, this message translates to:
  /// **'Activity Buttons'**
  String get helpButtons;

  /// Description of how to use the activity buttons
  ///
  /// In en, this message translates to:
  /// **'Tap any of the six buttons at the bottom to record an activity. Tapping quickly records the activity with the current time. Holding a button longer allows you to select a specific date and time.'**
  String get helpButtonsDescription;

  /// Section title for activity types instructions
  ///
  /// In en, this message translates to:
  /// **'Activity Types'**
  String get helpActivityTypes;

  /// Explanation of the tried the potty activity
  ///
  /// In en, this message translates to:
  /// **'Tried the potty: Indicates when your child attempted to use the potty'**
  String get helpTriedThePotty;

  /// Explanation of the used the potty activity
  ///
  /// In en, this message translates to:
  /// **'Used the potty: Indicates successful potty usage'**
  String get helpUsedThePotty;

  /// Explanation of the accident activity
  ///
  /// In en, this message translates to:
  /// **'Accident: Indicates when your child had an accident'**
  String get helpAccident;

  /// Explanation of the drank water activity
  ///
  /// In en, this message translates to:
  /// **'Drank water: Records when your child drank water. You will be asked how much water they drank.'**
  String get helpDrankWater;

  /// Explanation of the ate food activity
  ///
  /// In en, this message translates to:
  /// **'Ate food: Records when your child ate food'**
  String get helpAteFood;

  /// Food amount: ate some food
  ///
  /// In en, this message translates to:
  /// **'Ate some food'**
  String get ateSomeFood;

  /// Food amount: ate lots of food
  ///
  /// In en, this message translates to:
  /// **'Ate lots of food'**
  String get ateLotsOfFood;

  /// Prompt to select the food amount
  ///
  /// In en, this message translates to:
  /// **'How much food?'**
  String get selectFoodAmount;

  /// Explanation of the nappy activity
  ///
  /// In en, this message translates to:
  /// **'Nappy: Records when your child\'s nappy was changed'**
  String get helpNappy;

  /// Section title for activity selections instructions
  ///
  /// In en, this message translates to:
  /// **'Activity Selections'**
  String get helpSelections;

  /// Description of the activity selection process
  ///
  /// In en, this message translates to:
  /// **'After selecting an activity, you may be prompted to provide additional details about what happened and how it happened.'**
  String get helpSelectionsDescription;

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for the checkbox indicating if clothing needs to be changed due to a small accident
  ///
  /// In en, this message translates to:
  /// **'Needs clothing change'**
  String get needsClothingChange;

  /// Label for repository type selection
  ///
  /// In en, this message translates to:
  /// **'Repository Type'**
  String get repositoryType;

  /// Label for markdown directory setting
  ///
  /// In en, this message translates to:
  /// **'Markdown Directory'**
  String get markdownDirectory;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
