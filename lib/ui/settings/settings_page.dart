import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';

import 'package:toot_n_tinkle/repositories/potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/repositories/shared_prefs_potty_training_log_item_repository.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChanged;
  final ValueChanged<PottyTrainingLogItemRepository>? onRepositoryChanged;

  const SettingsPage({super.key, this.onLocaleChanged, this.onRepositoryChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _selectedLocale = const Locale('en');
  bool _isLoading = true;
  String _selectedRepository = 'shared_preferences';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load language preference
    final String? languageCode = prefs.getString('selected_language');
    if (languageCode != null && languageCode.isNotEmpty) {
      setState(() {
        _selectedLocale = Locale(languageCode);
      });
    }

    // Load repository preference
    final String? repositoryType = prefs.getString('repository_type');
    if (repositoryType != null && repositoryType.isNotEmpty) {
      setState(() {
        _selectedRepository = repositoryType;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Notify parent of repository change to ensure proper initialization
    _notifyRepositoryChange();
  }

  Future<void> _saveLocalePreference(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', locale.languageCode);

    // Update the app's locale
    if (mounted) {
      setState(() {
        _selectedLocale = locale;
      });

      // Notify parent of locale change
      widget.onLocaleChanged?.call(locale);
    }
  }

  Future<void> _saveRepositoryPreference(String repositoryType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('repository_type', repositoryType);

    if (mounted) {
      setState(() {
        _selectedRepository = repositoryType;
      });
    }

    // Notify parent of repository change
    _notifyRepositoryChange();
  }

  Future<void> _notifyRepositoryChange() async {
    if (_isLoading) return;

    // Always use shared preferences repository
    final prefs = await SharedPreferences.getInstance();
    final repository = SharedPrefsPottyTrainingLogItemRepository(prefs);

    // Notify parent of repository change
    if (mounted) {
      widget.onRepositoryChanged?.call(repository);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: _selectedLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  _saveLocalePreference(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('hu'), child: Text('Magyar')),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: Text(l10n.repositoryType),
            trailing: DropdownButton<String>(
              value: _selectedRepository,
              onChanged: (String? newValue) async {
                if (newValue != null && newValue != _selectedRepository) {
                  await _saveRepositoryPreference(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 'shared_preferences', child: Text('Shared Preferences')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
