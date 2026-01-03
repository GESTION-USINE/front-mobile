import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/menu_config.dart';
import '../../models/entities/menu_item.dart';
import '../../routes/app_router.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  final String userRole;
  final Function(String) onMenuItemTap;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.userRole,
    required this.onMenuItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseMenu = MenuConfig.getMenuForRole(userRole);
    // Inject "Bons de pesée" if missing
    const slipsItem = MenuItem(
      id: 'weighing_slips',
      title: 'Bons de pesée',
      icon: Icons.assignment_outlined,
      route: AppRouter.slips,
      allowedRoles: ['super_admin', 'associe', 'employe'],
    );
    const creditItem = MenuItem(
      id: 'clients_credit',
      title: 'Client Credit',
      icon: Icons.account_balance_wallet_outlined,
      route: AppRouter.clientsCredit,
      allowedRoles: ['super_admin', 'associe'],
    );
    final hasSlips = baseMenu.any((m) => m.id == 'weighing_slips');
    final hasClientsCredit = baseMenu.any((m) => m.id == 'clients_credit');
    final hasBonsClients = baseMenu.any((m) => m.id == 'clients_bons');
    const bonsClientsItem = MenuItem(
      id: 'clients_bons',
      title: 'Bons Clients',
      icon: Icons.people_outline,
      route: AppRouter.clientsBons,
      allowedRoles: ['super_admin', 'associe'],
    );
    final menuItems = [...baseMenu, if (!hasSlips) slipsItem, if (!hasClientsCredit) creditItem, if (!hasBonsClients) bonsClientsItem];

    return Container(
      width: 200,
      decoration: const BoxDecoration(
        gradient: AppTheme.industrialGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo et titre de l'application
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.whiteTransparent20,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.factory_outlined,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion Usine',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Production',
                        style: TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: AppColors.whiteTransparent20,
            height: 1,
            thickness: 1,
          ),

          // Liste des menus
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(menuItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final isSelected = currentRoute == item.route;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMenuItemTap(item.route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.whiteTransparent20
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
