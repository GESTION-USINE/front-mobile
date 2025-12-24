import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

/// Provider pour gérer le thème (clair/sombre)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Initialiser depuis le stockage local
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(AppConstants.themeKey);

    if (themeString != null) {
      _themeMode = _themeModeFromString(themeString);
    }

    notifyListeners();
  }

  /// Changer le thème
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, _themeModeToString(mode));

    notifyListeners();
  }

  /// Basculer entre clair et sombre
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Passer en mode clair
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Passer en mode sombre
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Passer en mode système
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
