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
          route: '/statistics/dashboard',
          allowedRoles: [], // Tous les rôles
        ),

        // Gestion des clients
        const MenuItem(
          id: 'clients',
          title: 'Clients',
          icon: Icons.person_outline,
          route: '/clients',
          allowedRoles: [],
        ),

        // Bons de pesée
        const MenuItem(
          id: 'weighing_slips',
          title: 'Bons de pesée',
          icon: Icons.assignment_outlined,
          route: '/weighing-slips',
          allowedRoles: ['super_admin', 'associe', 'employe'],
        ),

        // Crédits
        const MenuItem(
          id: 'credits',
          title: 'Crédits',
          icon: Icons.credit_card_outlined,
          route: '/credits',
          allowedRoles: ['super_admin', 'associe', 'employe'],
        ),

        // Encaissements du jour
        const MenuItem(
          id: 'credits_payments',
          title: 'Encaissements',
          icon: Icons.payments_outlined,
          route: '/credits-payments',
          allowedRoles: ['super_admin'],
        ),

        // Gestion des matériaux - Super admin et associé seulement
        const MenuItem(
          id: 'materials',
          title: 'Matériaux',
          icon: Icons.inventory_2_outlined,
          route: '/materials',
          allowedRoles: ['super_admin', 'associe'],
        ),

        const MenuItem(
          id: 'maintenance',
          title: 'Frais',
          icon: Icons.money_outlined,
          route: '/maintenance',
          allowedRoles: ['super_admin', 'associe'],
        ),

         const MenuItem(
          id: 'travailleurs',
          title: 'Travailleurs',
          icon: Icons.work_outline,
          route: '/workers',
          allowedRoles: ['super_admin', 'associe'],
        ),

        // Gestion des utilisateurs - Super admin seulement
        const MenuItem(
          id: 'users',
          title: 'Utilisateurs',
          icon: Icons.people_outline,
          route: '/users',
          allowedRoles: ['super_admin'],
        ),

        // Flux de trésorerie
        const MenuItem(
          id: 'cashflow',
          title: 'Flux de trésorerie',
          icon: Icons.account_balance_wallet_outlined,
          route: '/statistics/cashflow',
          allowedRoles: ['super_admin', 'associe'],
        ),

        // // Statistiques avec sous-menus
        // const MenuItem(
        //   id: 'statistiques',
        //   title: 'Statistiques',
        //   icon: Icons.analytics_outlined,
        //   route: '', // Pas de route directe, c'est un dropdown
        //   allowedRoles: ['super_admin', 'associe'],
        //   subItems: [
        //     MenuItem(
        //       id: 'stats_dashboard',
        //       title: 'Tableau de bord',
        //       icon: Icons.dashboard_outlined,
        //       route: '/statistics/dashboard',
        //       allowedRoles: ['super_admin', 'associe'],
        //     ),
        //     MenuItem(
        //       id: 'stats_sales',
        //       title: 'Ventes',
        //       icon: Icons.trending_up_outlined,
        //       route: '/statistics/sales',
        //       allowedRoles: ['super_admin', 'associe'],
        //     ),
        //     MenuItem(
        //       id: 'stats_purchases',
        //       title: 'Achats',
        //       icon: Icons.shopping_cart_outlined,
        //       route: '/statistics/purchases',
        //       allowedRoles: ['super_admin', 'associe'],
        //     ),
        //     MenuItem(
        //       id: 'stats_inventory',
        //       title: 'Inventaire',
        //       icon: Icons.inventory_2_outlined,
        //       route: '/statistics/inventory',
        //       allowedRoles: ['super_admin', 'associe'],
        //     ),
        //     MenuItem(
        //       id: 'stats_workers',
        //       title: 'Travailleurs',
        //       icon: Icons.people_outline,
        //       route: '/statistics/workers',
        //       allowedRoles: ['super_admin', 'associe'],
        //     ),
        //   ],
        // ),
      
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
