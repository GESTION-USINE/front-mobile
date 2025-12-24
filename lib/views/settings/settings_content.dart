import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Contenu des paramètres (sans wrapper MainLayout)
class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        const Text(
          'Paramètres',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Personnalisez votre expérience',
          style: AppTheme.subtitleMedium,
        ),
        const SizedBox(height: 32),

        // Contenu des paramètres
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              children: [
                const SizedBox(height: 8),

                // Section Apparence
                _buildSectionHeader(context, tr.appearance),

                // Thème
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(tr.theme),
                  subtitle: Text(_getThemeModeText(themeProvider.themeMode, tr)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, themeProvider, tr),
                ),

                const Divider(),

                // Section Langue
                _buildSectionHeader(context, tr.language),

                // Langue
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(tr.language),
                  subtitle: Text(localeProvider.isFrench ? tr.french : tr.english),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, localeProvider, tr),
                ),

                const Divider(),

                // Section À propos
                _buildSectionHeader(context, tr.about),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(tr.version),
                  subtitle: const Text(AppConstants.appVersion),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode, AppLocalizations tr) {
    switch (mode) {
      case ThemeMode.light:
        return tr.lightMode;
      case ThemeMode.dark:
        return tr.darkMode;
      case ThemeMode.system:
        return tr.systemMode;
    }
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeProvider themeProvider,
    AppLocalizations tr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  const Icon(Icons.light_mode_outlined),
                  const SizedBox(width: 12),
                  Text(tr.lightMode),
                ],
              ),
              value: ThemeMode.light,
              // ignore: deprecated_member_use
              groupValue: themeProvider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                themeProvider.setLightMode();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  const Icon(Icons.dark_mode_outlined),
                  const SizedBox(width: 12),
                  Text(tr.darkMode),
                ],
              ),
              value: ThemeMode.dark,
              // ignore: deprecated_member_use
              groupValue: themeProvider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                themeProvider.setDarkMode();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  const Icon(Icons.settings_suggest_outlined),
                  const SizedBox(width: 12),
                  Text(tr.systemMode),
                ],
              ),
              value: ThemeMode.system,
              // ignore: deprecated_member_use
              groupValue: themeProvider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                themeProvider.setSystemMode();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleProvider localeProvider,
    AppLocalizations tr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Row(
                children: [
                  const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(tr.french),
                ],
              ),
              value: 'fr',
              // ignore: deprecated_member_use
              groupValue: localeProvider.locale.languageCode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                localeProvider.setFrench();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: Row(
                children: [
                  const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(tr.english),
                ],
              ),
              value: 'en',
              // ignore: deprecated_member_use
              groupValue: localeProvider.locale.languageCode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                localeProvider.setEnglish();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
