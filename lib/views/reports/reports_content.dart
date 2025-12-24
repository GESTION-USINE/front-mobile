import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Contenu des rapports (sans wrapper MainLayout)
class ReportsContent extends StatelessWidget {
  const ReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rapports et analyses',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Générez et consultez vos rapports',
          style: AppTheme.subtitleMedium,
        ),
        const SizedBox(height: 32),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rapports et statistiques',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cette fonctionnalité sera implémentée prochainement',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
