import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/l10n/app_localizations_en.dart';
import 'package:toot_n_tinkle/ui/settings/settings_page.dart';

void main() {
  late AppLocalizationsEn l10n;

  setUp(() {
    // Use mock shared preferences to avoid plugin errors
    SharedPreferences.setMockInitialValues(<String, Object>{});
    l10n = AppLocalizationsEn();
  });

  Widget createTestWidget({ValueChanged<Locale>? onLocaleChanged}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SettingsPage(onLocaleChanged: onLocaleChanged),
    );
  }

  group('Settings Page Tests', () {
    testWidgets('Given the settings page loads, Then it displays the settings title', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Using English locale by default in test environment
      expect(find.text(l10n.settings), findsOneWidget);
    });

    testWidgets('Given the settings page loads, Then it displays the language option', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Using English locale by default in test environment
      expect(find.text(l10n.language), findsOneWidget);
    });

    testWidgets('Given the settings page loads, Then it has a language dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Just verify the dropdown exists, don't try to interact with localized content
      expect(find.byType(DropdownButton<Locale>), findsOneWidget);
    });
  });
}
