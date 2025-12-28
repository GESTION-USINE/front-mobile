import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../providers/user_provider.dart';
import '../widgets/generic_data_table.dart';

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
          final String? role = context.select<UserProvider, String?>(
            (p) => p.currentUser?.role,
          );
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête - Titre et bouton sur des lignes séparées
                const Text(
                  'Gestion des clients',
                  style: AppTheme.headingLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gérez vos clients particuliers et entreprises',
                  style: AppTheme.subtitleMedium,
                ),
                const SizedBox(height: 10),
                
                // Bouton Nouveau client - aligné à gauche, pas dans un Row
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRouter.clientsCreate),
                  style: AppTheme.industrialPrimaryButton,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nouveau client'),
                ),
                const SizedBox(height: 12),

                // Barre de recherche et filtres
                _buildFilters(viewModel, role),
                const SizedBox(height: 12),
                // Liste des clients
                _buildClientsList(viewModel, role),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(ClientViewModel viewModel, String? role) {
    final bool isEmployee = role?.toLowerCase() == 'employe';
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Recherche
        SizedBox(
          width: 320,
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
            isExpanded: true,
            style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Type',
              prefixIcon: Icons.category,
            ).copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 2,
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

        // Filtre Paiement par chèque
        SizedBox(
          width: 125,
          child: DropdownButtonFormField<bool?>(
            value: viewModel.canPayByCheckFilter,
            isExpanded: true,
            style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Paiement chèque',
              prefixIcon: Icons.payment,
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
                  child: Text('Oui',
                      style: TextStyle(color: AppColors.industrialText))),
              DropdownMenuItem(
                  value: false,
                  child: Text('Non',
                      style: TextStyle(color: AppColors.industrialText))),
            ],
            onChanged: (value) => viewModel.filterByCanPayByCheck(value),
          ),
        ),

        // Filtre Statut (masqué pour les employés)
        if (!isEmployee)
          SizedBox(
          width: 125,
          child: DropdownButtonFormField<bool?>(
            value: viewModel.isActiveFilter,
            isExpanded: true,
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

  Widget _buildClientsList(ClientViewModel viewModel, String? role) {
    final bool isEmployee = role?.toLowerCase() == 'employe';
    
    // Filtrer les clients actifs pour les employés
    final displayedClients = isEmployee
        ? viewModel.clients.where((c) => c.isActive).toList()
        : viewModel.clients;

    // Colonnes à afficher
    final columnsToDisplay = <DataTableColumn<dynamic>>[
      DataTableColumn<dynamic>(
        label: 'Nom',
        value: (client) => client?.name ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Type',
        value: (client) => _buildTypeBadge(client?.type ?? 'N/A'),
        isWidget: true,
      ),
      DataTableColumn<dynamic>(
        label: 'Téléphone',
        value: (client) => client?.phone ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Crédit',
        value: (client) {
          final dynamic c = client?.credit;
          final double d = c is num ? c.toDouble() : 0.0;
          return d.toStringAsFixed(2);
        },
      ),
      DataTableColumn<dynamic>(
        label: ' Chèque',
        value: (client) => (client?.canPayByCheck ?? false) ? '✓' : '✗',
      ),
      // Colonne Statut uniquement si pas employé
      if (!isEmployee)
        DataTableColumn<dynamic>(
          label: 'Statut',
          value: (client) => (client?.isActive ?? false) ? 'Actif' : 'Inactif',
        ),
    ];

    return GenericDataTable<dynamic>(
      items: displayedClients,
      columns: columnsToDisplay,
      showActions: !isEmployee,
      showEditAction: true,
      showDeleteAction: false,
      onEdit: (client) {
        context.go('/clients/${client.id}/edit', extra: client);
      },
      onDelete: (client) {
        // Delete action disabled
      },
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasError,
      errorMessage: viewModel.errorMessage,
      emptyMessage: 'Aucun client trouvé',
      total: viewModel.total,
      currentPage: viewModel.currentPage,
      totalPages: viewModel.totalPages,
      onPreviousPage: viewModel.hasPreviousPage
          ? () => viewModel.previousPage()
          : null,
      onNextPage:
          viewModel.hasNextPage ? () => viewModel.nextPage() : null,
    );
  }

  Widget _buildTypeBadge(String type) {
    final isEnterprise = type == 'entreprise';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnterprise
            // ignore: deprecated_member_use
            ? AppColors.info.withOpacity(0.1)
            // ignore: deprecated_member_use
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

}

