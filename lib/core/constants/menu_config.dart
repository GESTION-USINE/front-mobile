import 'package:flutter/material.dart';
import '../../models/entities/menu_item.dart';

/// Configuration des menus de navigation de l'application
class MenuConfig {
  MenuConfig._();

  /// Liste complète des éléments de menu
  static List<MenuItem> get allMenuItems => [
        // Dashboard - Accessible à tous
        const MenuItem(
          id: 'dashboard',
          title: 'Tableau de bord',
          icon: Icons.dashboard_outlined,
          route: '/dashboard',
          allowedRoles: [], // Tous les rôles
        ),

        // Gestion des produits
        const MenuItem(
          id: 'products',
          title: 'Produits',
          icon: Icons.inventory_2_outlined,
          route: '/products',
          allowedRoles: ['super_admin', 'admin', 'gestionnaire'],
        ),

        // Gestion des clients
        const MenuItem(
          id: 'clients',
          title: 'Clients',
          icon: Icons.person_outline,
          route: '/clients',
          allowedRoles: [],
        ),

        // Gestion des matériaux - Super admin et associé seulement
        const MenuItem(
          id: 'materials',
          title: 'Matériaux',
          icon: Icons.inventory_2_outlined,
          route: '/materials',
          allowedRoles: ['super_admin', 'associe'],
        ),

        // Gestion des utilisateurs - Admin seulement
        const MenuItem(
          id: 'users',
          title: 'Utilisateurs',
          icon: Icons.people_outline,
          route: '/users',
          allowedRoles: ['super_admin', 'admin'],
        ),

        // Gestion des factures
        const MenuItem(
          id: 'invoices',
          title: 'Factures',
          icon: Icons.receipt_long_outlined,
          route: '/invoices',
          allowedRoles: ['super_admin', 'admin', 'gestionnaire', 'comptable'],
        ),

        // Rapports et analyses
        const MenuItem(
          id: 'reports',
          title: 'Rapports',
          icon: Icons.analytics_outlined,
          route: '/reports',
          allowedRoles: ['super_admin', 'admin', 'gestionnaire'],
        ),

        // Traçabilité complète - Permission spéciale requise
        const MenuItem(
          id: 'traceability',
          title: 'Traçabilité',
          icon: Icons.timeline_outlined,
          route: '/traceability',
          allowedRoles: ['super_admin', 'admin'],
        ),

        // Paramètres - Accessible à tous
        const MenuItem(
          id: 'settings',
          title: 'Paramètres',
          icon: Icons.settings_outlined,
          route: '/settings',
          allowedRoles: [],
        ),
      ];

  /// Filtre les menus selon le rôle de l'utilisateur
  static List<MenuItem> getMenuForRole(String userRole) {
    return allMenuItems
        .where((item) => item.isVisibleForRole(userRole))
        .toList();
  }

  /// Obtient un élément de menu par son ID
  static MenuItem? getMenuItemById(String id) {
    try {
      return allMenuItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
