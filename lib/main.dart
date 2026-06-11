import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nappyquit/l10n/app_localizations.dart';

import 'package:nappyquit/repositories/potty_training_log_item_repository.dart';
import 'package:nappyquit/repositories/shared_prefs_potty_training_log_item_repository.dart';
import 'package:nappyquit/ui/home/home_page.dart';
import 'package:nappyquit/ui/home/home_page_logic.dart';

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
  late final HomePageLogic _homePageLogic;

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

    // Initialize repository (always use shared preferences)
    final PottyTrainingLogItemRepository repository = SharedPrefsPottyTrainingLogItemRepository(
      prefs,
    );

    if (mounted) {
      setState(() {
        _repository = repository;
        _homePageLogic = HomePageLogic(repository: _repository);
        _isLoading = false;
      });
    }
  }

  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _updateRepository(PottyTrainingLogItemRepository repository) {
    setState(() {
      _repository = repository;
      _homePageLogic = HomePageLogic(repository: _repository);
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
        logic: _homePageLogic,
        onLocaleChanged: _updateLocale,
        onRepositoryChanged: _updateRepository,
      ),
    );
  }
}
