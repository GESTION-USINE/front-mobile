import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/response/user_response.dart';

/// Provider global pour gérer l'état de l'utilisateur
class UserProvider extends ChangeNotifier {
  UserResponse? _currentUser;
  String? _token;
  bool _isInitialized = false;

  UserResponse? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Initialiser depuis le stockage local au démarrage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString(AppConstants.tokenKey);

    final userData = prefs.getString(AppConstants.userKey);
    if (userData != null) {
      try {
        _currentUser = UserResponse.fromJsonString(userData);
      } catch (e) {
        // Données corrompues, on les supprime
        await prefs.remove(AppConstants.userKey);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Définir l'utilisateur après login/signup
  Future<void> setUser(UserResponse user, String token) async {
    _currentUser = user;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, user.toJsonString());

    notifyListeners();
  }

  /// Mettre à jour les infos utilisateur
  Future<void> updateUser(UserResponse user) async {
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, user.toJsonString());

    notifyListeners();
  }

  /// Mettre à jour le token
  Future<void> updateToken(String token) async {
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);

    notifyListeners();
  }

  /// Déconnexion - effacer toutes les données
  Future<void> clear() async {
    _currentUser = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);

    notifyListeners();
  }
}
