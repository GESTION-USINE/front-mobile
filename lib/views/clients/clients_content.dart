import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/client_viewmodel.dart';

/// Contenu de la liste des clients (sans wrapper)
class ClientsContent extends StatefulWidget {
  const ClientsContent({super.key});

  @override
  State<ClientsContent> createState() => _ClientsContentState();
}

class _ClientsContentState extends State<ClientsContent> {
  late final ClientViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientViewModel>();
    _viewModel.loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ClientViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête - Titre et bouton sur des lignes séparées
                Text(
                  'Gestion des clients',
                  style: AppTheme.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez vos clients particuliers et entreprises',
                  style: AppTheme.subtitleMedium,
                ),
                const SizedBox(height: 16),
                
                // Bouton Nouveau client - aligné à gauche, pas dans un Row
                ElevatedButton.icon(
                  onPressed: () => context.go('/clients/create'),
                  style: AppTheme.industrialPrimaryButton,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nouveau client'),
                ),
                const SizedBox(height: 24),

                // Barre de recherche et filtres
                _buildFilters(viewModel),
                const SizedBox(height: 24),

                // Liste des clients
                _buildClientsList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(ClientViewModel viewModel) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Recherche
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.industrialText),
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Rechercher par nom, téléphone, email...',
              prefixIcon: Icons.search,
            ).copyWith(
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.searchClients('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              viewModel.searchClients(value);
            },
          ),
        ),

        // Filtre Type
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String?>(
            value: viewModel.typeFilter,
            style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Type',
              prefixIcon: Icons.category,
            ).copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(
                  value: null,
                  child: Text('Tous les types',
                      style: TextStyle(color: AppColors.industrialText))),
              DropdownMenuItem(
                  value: 'particulier',
                  child: Text('Particulier',
                      style: TextStyle(color: AppColors.industrialText))),
              DropdownMenuItem(
                  value: 'entreprise',
                  child: Text('Entreprise',
                      style: TextStyle(color: AppColors.industrialText))),
            ],
            onChanged: (value) => viewModel.filterByType(value),
          ),
        ),

        // Filtre Statut
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<bool?>(
            value: viewModel.isActiveFilter,
            style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Statut',
              prefixIcon: Icons.toggle_on,
            ).copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(
                  value: null,
                  child: Text('Tous',
                      style: TextStyle(color: AppColors.industrialText))),
              DropdownMenuItem(
                  value: true,
                  child: Text('Actif',
                      style: TextStyle(color: AppColors.industrialText))),
              DropdownMenuItem(
                  value: false,
                  child: Text('Inactif',
                      style: TextStyle(color: AppColors.industrialText))),
            ],
            onChanged: (value) => viewModel.filterByIsActive(value),
          ),
        ),

        // Bouton reset filtres
        IconButton(
          onPressed: () {
            _searchController.clear();
            viewModel.resetFilters();
          },
          icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
          tooltip: 'Réinitialiser les filtres',
        ),
      ],
    );
  }

  Widget _buildClientsList(ClientViewModel viewModel) {
    if (viewModel.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasError) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(viewModel.errorMessage ?? 'Erreur lors du chargement'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.loadClients,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (!viewModel.hasClients) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun client trouvé',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Commencez par ajouter un nouveau client',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table des clients
        Container(
          width: double.infinity,
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.industrialBackground,
              ),
              columns: const [
                DataColumn(
                    label: Text('Nom',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
                DataColumn(
                    label: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
                DataColumn(
                    label: Text('Téléphone',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
                DataColumn(
                    label: Text('Email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
                DataColumn(
                    label: Text('NIF/Taxe',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
                DataColumn(
                    label: Text('Paiement chèque',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
                DataColumn(
                    label: Text('Statut',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText))),
              ],
              rows: viewModel.clients.map((client) {
                return DataRow(
                  cells: [
                    DataCell(Text(client.name,
                        style:
                            const TextStyle(color: AppColors.industrialText))),
                    DataCell(_buildTypeBadge(client.type)),
                    DataCell(Text(client.phone,
                        style:
                            const TextStyle(color: AppColors.industrialText))),
                    DataCell(Text(client.email ?? '-',
                        style:
                            const TextStyle(color: AppColors.industrialText))),
                    DataCell(Text(client.taxId ?? '-',
                        style:
                            const TextStyle(color: AppColors.industrialText))),
                    DataCell(
                      Icon(
                        client.canPayByCheck
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: client.canPayByCheck
                            ? AppColors.success
                            : AppColors.grey400,
                        size: 20,
                      ),
                    ),
                    DataCell(_buildStatusBadge(client.isActive)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Pagination
        _buildPagination(viewModel),
      ],
    );
  }

  Widget _buildTypeBadge(String type) {
    final isEnterprise = type == 'entreprise';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnterprise
            ? AppColors.info.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEnterprise ? 'Entreprise' : 'Particulier',
        style: TextStyle(
          fontSize: 12,
          color: isEnterprise ? AppColors.info : AppColors.warning,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.errorBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? AppColors.success : AppColors.errorText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPagination(ClientViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${viewModel.total} clients',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: viewModel.hasPreviousPage
                    ? () => viewModel.previousPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Page ${viewModel.currentPage} / ${viewModel.totalPages}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed:
                    viewModel.hasNextPage ? () => viewModel.nextPage() : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
