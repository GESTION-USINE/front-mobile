import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../widgets/app_sidebar.dart';

/// Shell principal de l'application avec sidebar et navbar fixes
/// Le contenu (child) change selon la route - pattern similaire à <Outlet /> de React Router
class AppShell extends StatelessWidget {
  final String currentLocation;
  final Widget child;

  const AppShell({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    // Sécurité: si pas d'utilisateur, on ne devrait pas être ici
    // (la redirection du router devrait gérer ça)
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.industrialBackground,
      body: Row(
        children: [
          // Sidebar fixe
          AppSidebar(
            currentRoute: currentLocation,
            userRole: user.role,
            onMenuItemTap: (route) {
              if (route != currentLocation) {
                context.go(route); // Navigation avec go_router
              }
            },
          ),

          // Colonne principale avec navbar et contenu
          Expanded(
            child: Column(
              children: [
                // Zone de contenu dynamique (OUTLET)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: child, // 👈 C'est ici que le contenu change
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
