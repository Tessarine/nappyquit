import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';

import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/repositories/shared_prefs_potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/ui/home/home_page.dart';
import 'package:toot_n_tinkle/ui/home/home_page_logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = SharedPrefsPottyTrainingLogItemRepository(prefs);

  runApp(PottyTrainApp(repository: repository));
}

class PottyTrainApp extends StatelessWidget {
  final PottyTrainingLogItemRepository repository;

  const PottyTrainApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toot\'N\'Tinkle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(logic: HomePageLogic(repository: repository)),
    );
  }
}
