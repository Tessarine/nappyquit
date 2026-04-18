# AGENTS.md

## Project description

This project is a potty training app, mainly for Linux & android.

### Main Page

The main page should have "Potty Training" on the top of the page, followed by the log history.
On the bottom of the page should be 6 buttons:

- Tried to go to the potty
- Used the potty
- Accident
- Drank water
- Ate food
- Nappy

#### Page layout

For illustrative purposes the following table shows the layout of the application

|                      | Potty Training          |                |
|----------------------|-------------------------|----------------|
| 10:00                | Used the potty          | :edit: :bin:   |
| 09:50                | Accident                | :edit: :bin:   |
| 09:00                | Ate food                | :edit: :bin:   |
| 09:00                | Drank water 💦          | :edit: :bin:   |
| 2026-04-08           | ----------------------- | -------------- |
| 18:00                | Used the potty          | :edit: :bin:   |
| 17:00                | Ate food                | :edit: :bin:   |
| 17:00                | Drank water 💧          | :edit: :bin:   |
| 2026-04-08           | ----------------------- | -------------- |
| -------------------- | ----------------------- | -------------- |
|                      | Record Activity         |                |
| -------------------- | ----------------------- | -------------- |
| :Tried the potty:    | :Used the potty:        | :Accident:     |
| :Nappy:              | :Drank water:           | :Ate food:     |

Where the buttons are representative pictures of the activity. For the moment they could be emojis.

### Record Activity Transitions
After the user tapped on one of the activity buttons the following events should happen:
* Provide selections if described below for each the activity
* If the button is tapped for longer, provide a way to change the date and time
* Save the training log

#### Tried the potty

Provide a selection of the following options:
- Told parents
- Went by himself
- Asked to sit

#### Used the potty

Provide a selection of the following options:
- Pee
- Poo
- Both

with a checkbox if the needed to change clothes due to a small accident

And then the following options:
- Told parents
- Went by himself
- Asked to sit

#### Accident

Provide a selection of the following options:
- Pee
- Poo
- Both

And then the following options:
- Told parents
- Went by himself
- Asked to sit

#### Nappy

Provide a selection of the following options:
- Pee
- Poo
- Both
- None

#### Drank water

Show a dialog with the following options:
- Some water
- Lots of water

#### Ate food

Provide a selection of the following options:
- Ate some food
- Ate lots of food
 
## Commit Message Directives

- **Do not include co-author in commit messages**

## Code Quality Principles

- **DDD (Domain-Driven Design)**: Dependencies of the application should point towards domain objects and not outwards
- **BDD (Behavior-Driven Development)**: Write tests that describe expected behavior first
- **TDD (Test-Driven Development)**: Write failing tests before implementing features
- **SOLID principles**: Apply Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion
- **DRY (Don't Repeat Yourself)**: Eliminate code duplication through abstraction and reuse
- **UI separation**: The UI code should not include business logic. All behavior should be extracted into a separate file

### Directory Structure
- `lib/domain`: This directory contains all domain objects that are related to the application
  - E.g.: The class describing the log items should be placed in this directory
- `lib/use_cases`: This directory should contain all the logic that will be invoked by the ui elements
- `lib/repositories`: All persistence should happen in this directory
  - E.g.: PottyTrainingLogItemRepository should be placed here
- `lib/ui`: UI elements are listed here grouped by page
  - E.g.: `lib/ui/add_activity/add_activity_page.dart` should be placed here with all its widgets

## Localization

### Using AppLocalizations

All user-facing text must use the `AppLocalizations` class. Access it via:

```dart
final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
```

Then use properties like `l10n.someKey`. Always provide a fallback (either the `??` operator or by using the pattern above).

### Adding New Strings

1. Add the key and English value to `lib/l10n/app_en.arb`
2. Add the key and Hungarian value to `lib/l10n/app_hu.arb`
3. Run `flutter gen-l10n` to generate the localization classes
4. The generated `app_localizations.dart` will include the new getter

Example in `app_en.arb`:
```json
"myNewString": "My new string text",
"@myNewString": {
  "description": "Description of what this string is for"
}
```

### Localizing Emotion Names

Emotion names should be localized using the `Emotion.localization` function:

```dart
Text(widget.emotion.localization(l10n))
```

The `Emotion` model already includes a `localization` function that maps to the correct l10n property (e.g., `l10n.fear`, `l10n.joy`).

### Technique Titles and Descriptions

Grounding technique titles and descriptions must be localized through `AppLocalizations`:

```dart
title: _l10n.deepBreathing,
description: _l10n.deepBreathingDesc,
```

### Handling Language Changes

When the language changes, widgets that cache localized strings must update them. Use `didChangeDependencies()` to refresh:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _logic.updateLocalizations();
}
```

In the logic class, `updateLocalizations()` should:
- Update the `_l10n` instance
- Rebuild any cached localized strings
- Update any currently displayed content (e.g., current technique)

### Fallback Strategy

Always have a fallback for localization. The standard pattern is:

```dart
final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
```

This ensures the app displays English if localization fails.

### Testing Localization

In widget tests, wrap the widget under test with `MaterialApp` that includes localization delegates:

```dart
await tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MyWidget(),
  ),
);
```

For unit tests that don't need actual localization, use `AppLocalizationsEn()` directly.

## Testing

Before prompting the user that the work is finished, run the following script to verify the project:

```bash
bash scripts/ci_cd_pipeline.sh
```
