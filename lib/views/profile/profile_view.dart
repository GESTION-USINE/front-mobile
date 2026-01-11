import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _viewModel.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.industrialBackground,
        // appBar: AppBar(
        //   backgroundColor: AppColors.white,
        //   elevation: 2,
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back, color: AppColors.industrialPrimary),
        //     onPressed: () => context.go('/dashboard'),
        //   ),
        //   title: const Text(
        //     'Mon Profil',
        //     style: TextStyle(
        //       color: AppColors.industrialPrimary,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
        //       onPressed: _loadProfile,
        //       tooltip: 'Actualiser',
        //     ),
        //     const SizedBox(width: 16),
        //   ],
        // ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadProfile,
                      style: AppTheme.industrialPrimaryButton,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final profile = viewModel.profile;
            if (profile == null) {
              return const Center(child: Text('Aucun profil disponible'));
            }

            final hasCredit = profile.role == 'associe' || profile.role == 'employe';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    children: [
                      // Première ligne : Infos personnelles + Crédit
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Informations du compte (gauche)
                          Expanded(
                            flex: 1,
                            child: _buildInfoCard(
                              title: 'Informations du compte',
                              icon: Icons.account_circle,
                              children: [
                                _buildInfoRow('Nom d\'utilisateur', profile.username),
                                _buildInfoRow('Email', profile.email ?? 'Non renseigné'),
                                _buildInfoRow('Téléphone', profile.phone ?? 'Non renseigné'),
                                _buildInfoRow('Rôle', _getRoleDisplayName(profile.role)),
                                _buildInfoRow(
                                  'Statut',
                                  profile.isActive ? 'Actif' : 'Inactif',
                                  valueColor: profile.isActive ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          
                          // Crédit (droite) - si applicable
                          if (hasCredit)
                            Expanded(
                              flex: 1,
                              child: _buildCreditCard(profile),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Deuxième ligne : Accès + Infos système
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Accès et permissions (gauche)
                          Expanded(
                            flex: 1,
                            child: _buildInfoCard(
                              title: 'Accès et permissions',
                              icon: Icons.security,
                              children: [
                                _buildInfoRow(
                                  'Accès à distance',
                                  profile.canAccessRemotely ? 'Autorisé' : 'Non autorisé',
                                  valueColor: profile.canAccessRemotely ? Colors.green : Colors.orange,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          
                          // Informations système (droite)
                          Expanded(
                            flex: 1,
                            child: _buildInfoCard(
                              title: 'Informations système',
                              icon: Icons.info_outline,
                              children: [
                                _buildInfoRow(
                                  'Créé le',
                                  _formatDate(profile.createdAt),
                                ),
                                _buildInfoRow(
                                  'Dernière mise à jour',
                                  _formatDate(profile.updatedAt),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreditCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.industrialPrimary, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Gestion du crédit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.industrialText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCreditInfo(profile),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.industrialPrimary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.industrialText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.industrialText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditInfo(dynamic profile) {
    final creditLimit = profile.creditLimit ?? 0.0;
    final currentCreditUsed = profile.currentCreditUsed ?? 0.0;
    final creditAvailable = creditLimit - currentCreditUsed;
    final usagePercent = creditLimit > 0 ? (currentCreditUsed / creditLimit * 100) : 0.0;

    Color getUsageColor() {
      if (usagePercent >= 95) return Colors.red;
      if (usagePercent >= 80) return Colors.orange;
      return Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestion du crédit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.industrialText,
          ),
        ),
        const SizedBox(height: 16),
        
        // Credit Progress Bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Utilisation',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  '${usagePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getUsageColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usagePercent / 100,
                minHeight: 10,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(getUsageColor()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Credit Details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.industrialPrimary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildCreditRow('Limite de crédit', creditLimit),
              const SizedBox(height: 12),
              _buildCreditRow('Crédit utilisé', currentCreditUsed, color: Colors.orange),
              const SizedBox(height: 12),
              _buildCreditRow('Crédit disponible', creditAvailable, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditRow(String label, double value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey700,
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} DZD',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.industrialText,
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Administrateur';
      case 'associe':
        return 'Associé';
      case 'employe':
        return 'Employé';
      default:
        return role;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
