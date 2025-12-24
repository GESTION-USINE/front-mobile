import 'package:flutter/material.dart';

/// Modèle représentant un élément de menu de navigation
class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final List<String> allowedRoles; // Rôles autorisés à voir cet élément
  final List<MenuItem>? subItems; // Sous-menu optionnel

  const MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.allowedRoles = const [], // Vide = accessible à tous
    this.subItems,
  });

  /// Vérifie si l'utilisateur a la permission de voir cet élément
  bool isVisibleForRole(String userRole) {
    if (allowedRoles.isEmpty) return true; // Accessible à tous
    return allowedRoles.contains(userRole);
  }
}
