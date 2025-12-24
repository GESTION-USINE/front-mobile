import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_localizations.dart';

/// Provider pour gérer la langue de l'application
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr'); // Français par défaut

  Locale get locale => _locale;

  bool get isFrench => _locale.languageCode == 'fr';
  bool get isEnglish => _locale.languageCode == 'en';

  /// Initialiser depuis le stockage local
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(AppConstants.localeKey);

    if (localeCode != null) {
      final savedLocale = Locale(localeCode);
      if (AppLocalizations.supportedLocales.contains(savedLocale)) {
        _locale = savedLocale;
      }
    }

    notifyListeners();
  }

  /// Changer la langue
  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return;
    }

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.localeKey, locale.languageCode);

    notifyListeners();
  }

  /// Passer en français
  Future<void> setFrench() async {
    await setLocale(const Locale('fr'));
  }

  /// Passer en anglais
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  /// Basculer entre français et anglais
  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'fr') {
      await setEnglish();
    } else {
      await setFrench();
    }
  }
}
