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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Breadcrumb ou titre de la page (optionnel)
                const Expanded(
                  child: Text(
                    '', // Peut être rempli dynamiquement selon la route
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.industrialPrimary,
                    ),
                  ),
                ),

                // Informations utilisateur
                if (user != null) ...[
              // Rôle badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
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
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_outlined,
                                size: 10,
                                color: AppColors.grey500,
                              ),
                              const SizedBox(width: 4),
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
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.grey600,
                    ),
                  ],
                ),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 20),
                        const SizedBox(width: 12),
                        const Text('Mon profil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined, size: 20),
                        const SizedBox(width: 12),
                        const Text('Paramètres'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: AppColors.errorText),
                        const SizedBox(width: 12),
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
        // TODO: Implémenter la page profil
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
