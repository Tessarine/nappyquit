import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toot_n_tinkle/l10n/app_localizations.dart';
import 'package:toot_n_tinkle/repositories/markdown_potty_training_log_item_repository.dart';
import 'package:toot_n_tinkle/repositories/migration_tool.dart';
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
  String _markdownDirectory = '';
  bool _isLoadingDirectory = true;

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

    // Load markdown directory preference
    final String? directory = prefs.getString('markdown_directory');
    if (directory != null && directory.isNotEmpty) {
      setState(() {
        _markdownDirectory = directory;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoadingDirectory = false;
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

  Future<void> _saveMarkdownDirectory(String directory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('markdown_directory', directory);

    if (mounted) {
      setState(() {
        _markdownDirectory = directory;
      });
    }

    // Notify parent of repository change (since directory affects the repository)
    _notifyRepositoryChange();
  }

  Future<String> _getDefaultMarkdownDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/potty_training_logs';
  }

  Future<void> _ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> _notifyRepositoryChange() async {
    if (_isLoading || _isLoadingDirectory) return;

    // Create the appropriate repository based on selection
    PottyTrainingLogItemRepository repository;

    if (_selectedRepository == 'markdown') {
      final String directoryPath = _markdownDirectory.isNotEmpty
          ? _markdownDirectory
          : await _getDefaultMarkdownDirectory();

      // Ensure the directory exists
      await _ensureDirectoryExists(directoryPath);

      repository = MarkdownPottyTrainingLogItemRepository(directoryPath);

      // Migrate data from shared preferences to markdown if switching to markdown
      final prefs = await SharedPreferences.getInstance();
      final sourceRepository = SharedPrefsPottyTrainingLogItemRepository(prefs);
      final migrationTool = MigrationTool();
      await migrationTool.migrateRepositories(sourceRepository, repository);
    } else {
      final prefs = await SharedPreferences.getInstance();
      repository = SharedPrefsPottyTrainingLogItemRepository(prefs);
    }

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
                DropdownMenuItem(value: 'markdown', child: Text('Markdown Files')),
              ],
            ),
          ),
          if (_selectedRepository == 'markdown')
            ListTile(
              leading: const Icon(Icons.folder),
              title: Text(l10n.markdownDirectory),
              subtitle: FutureBuilder<String>(
                future: _markdownDirectory.isNotEmpty
                    ? Future.value(_markdownDirectory)
                    : _getDefaultMarkdownDirectory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final String directory = snapshot.data ?? '';
                  return Text(
                    _markdownDirectory.isNotEmpty
                        ? _markdownDirectory
                        : 'Using default directory: $directory',
                  );
                },
              ),
              trailing: IconButton(icon: const Icon(Icons.edit), onPressed: _showDirectoryDialog),
            ),
        ],
      ),
    );
  }

  Future<void> _showDirectoryDialog() async {
    final TextEditingController controller = TextEditingController(text: _markdownDirectory);

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Markdown Directory'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter directory path for markdown files'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _saveMarkdownDirectory(result);
      // Ensure the directory exists
      await _ensureDirectoryExists(result);
      // Notify parent of repository change
      await _notifyRepositoryChange();
    }
  }
}
