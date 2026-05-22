import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';
import '../services/storage_service.dart';
import '../services/image_service.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Column(
                        children: languageService.supportedLocales.map((locale) {
                          final isSelected = languageService.locale?.languageCode == locale.languageCode ||
                              (languageService.locale == null && Localizations.localeOf(context).languageCode == locale.languageCode);

                          return RadioListTile<String>(
                            title: Text(languageService.getLanguageName(locale.languageCode)),
                            subtitle: Text(_getLanguageSubtitle(locale.languageCode, l10n)),
                            value: locale.languageCode,
                            groupValue: languageService.locale?.languageCode ?? Localizations.localeOf(context).languageCode,
                            onChanged: (value) {
                              if (value != null) {
                                languageService.setLocale(Locale(value));
                              }
                            },
                            secondary: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      context.read<LanguageService>().clearLocale();
                    },
                    icon: const Icon(Icons.phone_android),
                    label: Text(l10n.useSystemLanguage),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appearance,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return SwitchListTile(
                        title: Text(l10n.darkMode),
                        subtitle: Text(themeService.isDarkMode ? l10n.darkModeEnabled : l10n.lightModeEnabled),
                        value: themeService.isDarkMode,
                        onChanged: (value) {
                          themeService.toggleTheme();
                        },
                        secondary: Icon(
                          themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Data Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dataManagement,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(l10n.clearAllData),
                    subtitle: Text(l10n.clearAllDataSubtitle),
                    onTap: () => _showClearDataDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_delete, color: Colors.orange),
                    title: Text(l10n.clearImages),
                    subtitle: Text(l10n.clearImagesSubtitle),
                    onTap: () => _showClearImagesDialog(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.about),
                    onTap: () => _showAboutDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(l10n.help),
                    onTap: () => _showHelpDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageSubtitle(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.englishLanguage;
      case 'de':
        return l10n.germanLanguage;
      default:
        return '';
    }
  }

  void _showClearDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearAllDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clearData),
          ),
        ],
      ),
    );
  }

  void _showClearImagesDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearImages),
        content: Text(l10n.clearImagesConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearImages(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.clearImages),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Clear all storage data
      await StorageService.clearAll();

      // Clear all images
      await ImageService.clearAllImages();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.allDataCleared),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorClearingData),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearImages(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await ImageService.clearAllImages();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imagesCleared),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorClearingImages),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.aboutDescription,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('🎯 ${l10n.tasks}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.aboutTasks),
              const SizedBox(height: 12),
              Text('👥 ${l10n.groups}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.aboutGroups),
              const SizedBox(height: 12),
              Text('⚖️ ${l10n.fairMode}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.aboutFairMode),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('📱 ${l10n.appInfo}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.developedBy),
              Text('© 2025 ${l10n.allRightsReserved}',
                   style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.help),
        content: SingleChildScrollView(
          child: Text(l10n.helpContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}