# AGENTS.md

## Commit Message Directives

- **Do not include co-author in commit messages**

## Code Quality Principles

- **BDD (Behavior-Driven Development)**: Write tests that describe expected behavior first
- **TDD (Test-Driven Development)**: Write failing tests before implementing features
- **SOLID principles**: Apply Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion
- **DRY (Don't Repeat Yourself)**: Eliminate code duplication through abstraction and reuse
- **UI separation**: The UI code should not include business logic. All behavior should be extracted into a separate file

### Localization

- **Do not write hard-coded English content on the UI code**
- Use the AppLocalization class to reference UI text content

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
