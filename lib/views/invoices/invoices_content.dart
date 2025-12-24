import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Contenu de la gestion des factures (sans wrapper MainLayout)
class InvoicesContent extends StatelessWidget {
  const InvoicesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des factures',
                  style: AppTheme.headingLarge,
                ),
                SizedBox(height: 8),
                Text(
                  'Consultez et gérez vos factures',
                  style: AppTheme.subtitleMedium,
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              style: AppTheme.industrialPrimaryButton,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nouvelle facture'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Contenu placeholder
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Liste des factures',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
