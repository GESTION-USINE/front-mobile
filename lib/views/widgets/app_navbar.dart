import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_router.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key});

  /// Retourne le titre de la page selon la route courante
  String _getPageTitle(String location) {
    if (location.contains(AppRouter.clients)) return 'Gestion des Clients';
    if (location.contains(AppRouter.materials)) return 'Gestion des Matériaux';
    if (location.contains(AppRouter.workers)) return 'Gestion des Travailleurs';
    if (location.contains(AppRouter.slips)) return 'Bons de Pesée';
    if (location.contains(AppRouter.statisticsPath)) return 'Statistiques';
    if (location.contains(AppRouter.credits)) return 'Gestion des Crédits';
    if (location.contains(AppRouter.invoices)) return 'Factures';
    if (location.contains(AppRouter.products)) return 'Produits';
    if (location.contains(AppRouter.maintenance)) return 'Maintenance';
    if (location.contains(AppRouter.users)) return 'Gestion des Utilisateurs';
    if (location.contains(AppRouter.settings)) return 'Paramètres';
    if (location.contains(AppRouter.reports)) return 'Rapports';
    if (location.contains(AppRouter.traceability)) return 'Traçabilité';
    if (location.contains(AppRouter.dashboard)) return 'Tableau de Bord';
    return 'Accueil';
  }

  /// Retourne l'icône de la page selon la route courante
  IconData _getPageIcon(String location) {
    if (location.contains(AppRouter.clients)) return Icons.people;
    if (location.contains(AppRouter.materials)) return Icons.category;
    if (location.contains(AppRouter.workers)) return Icons.engineering;
    if (location.contains(AppRouter.slips)) return Icons.scale;
    if (location.contains(AppRouter.statisticsPath)) return Icons.bar_chart;
    if (location.contains(AppRouter.credits)) return Icons.credit_card;
    if (location.contains(AppRouter.invoices)) return Icons.receipt_long;
    if (location.contains(AppRouter.products)) return Icons.inventory_2;
    if (location.contains(AppRouter.maintenance)) return Icons.build;
    if (location.contains(AppRouter.users)) return Icons.admin_panel_settings;
    if (location.contains(AppRouter.settings)) return Icons.settings;
    if (location.contains(AppRouter.reports)) return Icons.assessment;
    if (location.contains(AppRouter.traceability)) return Icons.timeline;
    if (location.contains(AppRouter.dashboard)) return Icons.dashboard;
    return Icons.home;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;

        return Container(
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Titre de la page avec icône
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _getPageIcon(location),
                        color: AppColors.industrialPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getPageTitle(location),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.industrialPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Informations utilisateur
                if (user != null) ...[
              // Rôle badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.industrialPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRoleDisplayName(user.role),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.industrialPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Menu utilisateur
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.industrialPrimary,
                      child: Text(
                        user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.industrialText,
                          ),
                        ),
                        if (user.canAccessRemotely)
                          const Row(
                            children: [
                              Icon(
                                Icons.cloud_outlined,
                                size: 10,
                                color: AppColors.grey500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Accès distant',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.grey600,
                    ),
                  ],
                ),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Mon profil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: AppColors.errorText),
                        SizedBox(width: 12),
                        Text(
                          'Se déconnecter',
                          style: TextStyle(color: AppColors.errorText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
      },
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'admin':
        return 'Administrateur';
      case 'gestionnaire':
        return 'Gestionnaire';
      case 'comptable':
        return 'Comptable';
      case 'operateur':
        return 'Opérateur';
      default:
        return role;
    }
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'profile':

        break;
      case 'settings':
        context.go(AppRouter.settings);
        break;
      case 'logout':
        await _logout(context);
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authViewModel = getIt<AuthViewModel>();
    await authViewModel.logout();

    if (context.mounted) {
      context.go(AppRouter.login);
    }
  }
}
