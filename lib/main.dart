import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';

import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/repositories/shared_prefs_potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/ui/home/home_page.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

void main() {
  runApp(const PottyTrainApp());
}

class PottyTrainApp extends StatefulWidget {
  const PottyTrainApp({super.key});

  @override
  State<PottyTrainApp> createState() => _PottyTrainAppState();
}

class _PottyTrainAppState extends State<PottyTrainApp> {
  Locale _locale = const Locale('en');
  bool _isLoading = true;
  late final PottyTrainingLogItemRepository _repository;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('selected_language');
    if (languageCode != null && languageCode.isNotEmpty) {
      _locale = Locale(languageCode);
    }
    final repository = SharedPrefsPottyTrainingLogItemRepository(prefs);
    if (mounted) {
      setState(() {
        _repository = repository;
        _isLoading = false;
      });
    }
  }

  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Toot\'N\'Tinkle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(
        logic: HomePageLogic(repository: _repository),
        onLocaleChanged: _updateLocale,
      ),
    );
  }
}
