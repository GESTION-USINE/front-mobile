import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
class UsersContent extends StatelessWidget {
  const UsersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des utilisateurs',
                      style: AppTheme.headingLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gérez les utilisateurs et leurs permissions',
                      style: AppTheme.subtitleMedium,
                    ),
                  ],
                ),
               
              ],
            ),
            const SizedBox(height: 32),
            // Maintenant Expanded aura une taille définie
            // Expanded(
            //   child: Container(
            //     padding: const EdgeInsets.all(24),
            //     decoration: BoxDecoration(
            //       color: AppColors.white,
            //       borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            //       boxShadow: [
            //         BoxShadow(
            //           color: AppColors.shadowColor,
            //           blurRadius: 4,
            //           offset: const Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: Center(
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
            //           const SizedBox(height: 16),
            //           Text(
            //             'Liste des utilisateurs',
            //             style: TextStyle(
            //               fontSize: 18,
            //               fontWeight: FontWeight.w600,
            //               color: AppColors.grey600,
            //             ),
            //           ),
            //           const SizedBox(height: 8),
            //           Text(
            //             'Cette fonctionnalité sera implémentée prochainement',
            //             style: TextStyle(
            //               fontSize: 14,
            //               color: AppColors.grey500,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
