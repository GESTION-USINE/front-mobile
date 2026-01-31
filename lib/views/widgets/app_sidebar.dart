import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/menu_config.dart';
import '../../models/entities/menu_item.dart';
import '../../routes/app_router.dart';
import '../../providers/sidebar_provider.dart';

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
    return Consumer<SidebarProvider>(
      builder: (context, sidebarProvider, _) {
        final isCollapsed = sidebarProvider.isCollapsed;
        final width = isCollapsed ? 60.0 : 200.0;

        final baseMenu = MenuConfig.getMenuForRole(userRole);
        // Inject "Bons de pesée" if missing
        const slipsItem = MenuItem(
          id: 'weighing_slips',
          title: 'Bons de pesée',
          icon: Icons.assignment_outlined,
          route: AppRouter.slips,
          allowedRoles: ['super_admin', 'associe', 'employe'],
        );
        // const creditItem = MenuItem(
        //   id: 'clients_credit',
        //   title: 'Client Credit',
        //   icon: Icons.account_balance_wallet_outlined,
        //   route: AppRouter.clientsCredit,
        //   allowedRoles: ['super_admin', 'associe'],
        // );
        final hasSlips = baseMenu.any((m) => m.id == 'weighing_slips');
        final hasClientsCredit = baseMenu.any((m) => m.id == 'clients_credit');
        final hasBonsClients = baseMenu.any((m) => m.id == 'clients_bons');
        final hasInvoices = baseMenu.any((m) => m.id == 'invoices');
        const bonsClientsItem = MenuItem(
          id: 'clients_bons',
          title: 'Bons Clients',
          icon: Icons.people_outline,
          route: AppRouter.clientsBons,
          allowedRoles: ['super_admin', 'associe'],
        );
        const invoicesItem = MenuItem(
          id: 'invoices',
          title: 'Factures',
          icon: Icons.receipt_long_outlined,
          route: AppRouter.invoices,
          allowedRoles: ['super_admin', 'associe'],
        );
        final menuItems = [...baseMenu, if (!hasSlips) slipsItem,  if (!hasBonsClients) bonsClientsItem, if (!hasInvoices) invoicesItem];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: width,
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
              // Logo et titre de l'application avec bouton collapse
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: isCollapsed ? 4 : 12,
                ),
                child: isCollapsed
                    ? Center(
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: AppColors.white),
                          onPressed: () => sidebarProvider.toggleSidebar(),
                          tooltip: 'Afficher menu',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: const Row(
                              children: [
                                 Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rahma Usine',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Production',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Color(0xB3FFFFFF),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: AppColors.white),
                            onPressed: () => sidebarProvider.toggleSidebar(),
                            tooltip: 'Réduire menu',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 18,
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
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: isCollapsed ? 2 : 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(menuItems[index], isCollapsed);
              },
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildMenuItem(MenuItem item, bool isCollapsed) {
    final isSelected = currentRoute == item.route;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    // Si l'item a des subItems, afficher un expandable, sinon naviguer directement
    if (hasSubItems) {
      return _buildExpandableMenuItem(item, isCollapsed);
    }

    if (isCollapsed) {
      return Tooltip(
        message: item.title,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onMenuItemTap(item.route),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.whiteTransparent20
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMenuItemTap(item.route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildExpandableMenuItem(MenuItem item, bool isCollapsed) {
    // When collapsed, show only icon with tooltip (no ExpansionTile)
    if (isCollapsed) {
      return Tooltip(
        message: item.title,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to first sub-item or show message
                if (item.subItems != null && item.subItems!.isNotEmpty) {
                  onMenuItemTap(item.subItems!.first.route);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                    padding: const EdgeInsets.only(left: 8),
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
                              horizontal: 8,
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
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    subItem.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
