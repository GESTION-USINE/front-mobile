import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Contenu de la traçabilité (sans wrapper MainLayout)
class TraceabilityContent extends StatelessWidget {
  const TraceabilityContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Traçabilité complète',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Suivez l\'historique complet de vos opérations',
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
                    Icons.timeline_outlined,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Système de traçabilité',
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
