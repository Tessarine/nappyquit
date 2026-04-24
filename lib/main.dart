import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';

import 'package:toot_n_tinkle/repositories/markdown_potty_training_log_item_repository.dart';
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

    // Load repository preference
    final String? repositoryType = prefs.getString('repository_type');
    final String? markdownDirectory = prefs.getString('markdown_directory');

    // Initialize repository based on preference
    PottyTrainingLogItemRepository repository;
    if (repositoryType == 'markdown') {
      final String dirPath = markdownDirectory?.isNotEmpty == true
          ? markdownDirectory!
          : '${(await getApplicationDocumentsDirectory()).path}/potty_training_logs';

      // Ensure directory exists
      await Directory(dirPath).create(recursive: true);

      repository = MarkdownPottyTrainingLogItemRepository(dirPath);
    } else {
      // Default to shared preferences
      repository = SharedPrefsPottyTrainingLogItemRepository(prefs);
    }

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
