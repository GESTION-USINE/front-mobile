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
    final slipsItem = const MenuItem(
      id: 'weighing_slips',
      title: 'Bons de pesée',
      icon: Icons.assignment_outlined,
      route: AppRouter.slips,
      allowedRoles: ['super_admin', 'associe', 'employe'],
    );
    final hasSlips = baseMenu.any((m) => m.id == 'weighing_slips');
    final menuItems = [...baseMenu, if (!hasSlips) slipsItem];

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
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    // Si l'item a des subItems, afficher un expandable, sinon naviguer directement
    if (hasSubItems) {
      return _buildExpandableMenuItem(item);
    }

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

  Widget _buildExpandableMenuItem(MenuItem item) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ExpansionTile(
          key: ValueKey(item.id),
          leading: Icon(
            item.icon,
            color: AppColors.white,
            size: 20,
          ),
          title: Text(
            item.title,
             maxLines: 1,
  overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          textColor: AppColors.white,
          collapsedTextColor: AppColors.white,
          iconColor: AppColors.white,
          collapsedIconColor: AppColors.white,
          backgroundColor: AppColors.whiteTransparent10,
          collapsedBackgroundColor: Colors.transparent,
          children: item.subItems!
              .map((subItem) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onMenuItemTap(subItem.route),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: currentRoute == subItem.route
                                  ? AppColors.whiteTransparent20
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  subItem.icon,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    subItem.title,
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight:
                                          currentRoute == subItem.route
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (currentRoute == subItem.route)
                                  Container(
                                    width: 3,
                                    height: 3,
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
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
