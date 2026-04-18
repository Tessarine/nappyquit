// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Potty Training';

  @override
  String get recordActivity => 'Record Activity';

  @override
  String get triedThePotty => 'Tried the potty';

  @override
  String get usedThePotty => 'Used the potty';

  @override
  String get accident => 'Accident';

  @override
  String get drankWater => 'Drank water';

  @override
  String get drankSomeWater => 'Some water';

  @override
  String get drankLotsOfWater => 'Lots of water';

  @override
  String get ateFood => 'Ate food';

  @override
  String get nappy => 'Nappy';

  @override
  String get pee => 'Pee';

  @override
  String get poo => 'Poo';

  @override
  String get both => 'Both';

  @override
  String get none => 'None';

  @override
  String get toldParents => 'Told parents';

  @override
  String get wentByHimself => 'Went by himself';

  @override
  String get askedToSit => 'Asked to sit';

  @override
  String get selectBodilyFunction => 'What happened?';

  @override
  String get selectInitiative => 'How did it happen?';

  @override
  String get selectWaterAmount => 'How much water?';

  @override
  String get selectDateAndTime => 'Select date and time';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDelete => 'Are you sure you want to delete this entry?';

  @override
  String get noLogEntries => 'No activities recorded yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get help => 'Help';

  @override
  String get helpTitle => 'How to Use the Toot\'N\'Tinkle App';

  @override
  String get helpMainPage => 'Main Page';

  @override
  String get helpMainPageDescription =>
      'The main page shows your Toot\'N\'Tinkle log history. Each entry includes the time, activity type, and any relevant details. You can edit or delete entries using the buttons on the right.';

  @override
  String get helpButtons => 'Activity Buttons';

  @override
  String get helpButtonsDescription =>
      'Tap any of the six buttons at the bottom to record an activity. Tapping quickly records the activity with the current time. Holding a button longer allows you to select a specific date and time.';

  @override
  String get helpActivityTypes => 'Activity Types';

  @override
  String get helpTriedThePotty =>
      'Tried the potty: Indicates when your child attempted to use the potty';

  @override
  String get helpUsedThePotty =>
      'Used the potty: Indicates successful potty usage';

  @override
  String get helpAccident =>
      'Accident: Indicates when your child had an accident';

  @override
  String get helpDrankWater =>
      'Drank water: Records when your child drank water. You will be asked how much water they drank.';

  @override
  String get helpAteFood => 'Ate food: Records when your child ate food';

  @override
  String get helpNappy => 'Nappy: Records when your child\'s nappy was changed';

  @override
  String get helpSelections => 'Activity Selections';

  @override
  String get helpSelectionsDescription =>
      'After selecting an activity, you may be prompted to provide additional details about what happened and how it happened.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get needsClothingChange => 'Needs clothing change';
}
