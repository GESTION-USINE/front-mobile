import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/models/entities/material_price.dart';
import 'package:flutter_mvvm_template/viewmodels/material_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../providers/user_provider.dart';
import '../widgets/generic_data_table.dart';
import '../widgets/client_material_prices_drawer.dart';

/// Contenu de la liste des clients (sans wrapper)
class ClientsContent extends StatefulWidget {
  const ClientsContent({super.key});

  @override
  State<ClientsContent> createState() => _ClientsContentState();
}

class _ClientsContentState extends State<ClientsContent> {
  late final ClientViewModel _viewModel;
  late final MaterialViewModel _materialViewModel;
  final _searchController = TextEditingController();

  // Drawer state
  bool _isDrawerOpen = false;
  dynamic _selectedClient;

  // Controllers pour les prix par matériau
  final Map<int, TextEditingController> _priceControllers = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientViewModel>();
    _materialViewModel = getIt<MaterialViewModel>();
    _viewModel.loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    _viewModel.dispose();
    _materialViewModel.dispose();
    super.dispose();
  }

  void _openPricesForClient(dynamic client) {
    setState(() {
      _selectedClient = client;
      _isDrawerOpen = true;
      // Clear existing controllers
      for (final c in _priceControllers.values) {
        c.dispose();
      }
      _priceControllers.clear();
    });
print("--------------------------------") ;    
print("--------------------------------") ;    
print("--------------------------------") ;    
    print('----->'+client.id.toString())  ;
     _materialViewModel.loadClientMaterialPrices(clientId: client.id, refresh: true);
    // sleep(Duration(seconds:5));
    print("finally loaded")  ;
    print(_materialViewModel.materialPrices.length.toString());

     print("--------------------------------") ;    
print("--------------------------------") ;    
print("--------------------------------") ;    

  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
      _selectedClient = null;
    });
  }

  void _ensureControllers(List<MaterialPriceItem> items) {
    for (final item in items) {
      if (!_priceControllers.containsKey(item.materialId)) {
        final text = item.customPricePerTon != null ? item.customPricePerTon!.toString() : '';
        _priceControllers[item.materialId] = TextEditingController(text: text);
      }
    }
  }

  Future<void> _savePrices() async {
    if (_selectedClient == null) return;
    final clientId = _selectedClient.id;
    final List<Map<String, dynamic>> payload = [];
    for (final entry in _priceControllers.entries) {
      final materialId = entry.key;
      final txt = entry.value.text.trim();
      double? price;
      if (txt.isNotEmpty) {
        price = double.tryParse(txt.replaceAll(',', '.'));
      } else {
        price = null;
      }
      payload.add({
        'material_id': materialId,
        'custom_price_per_ton': price,
      });
    }

    setState(() => _saving = true);
    try {
      final ok = await _materialViewModel.saveClientMaterialPrices(clientId: clientId, prices: payload);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prix enregistrés')));
        // recharger
        _materialViewModel.loadClientMaterialPrices(clientId: clientId, refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la sauvegarde')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la sauvegarde')));
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _buildPricesDrawer(BuildContext ctx, dynamic client, VoidCallback close) {
    return ClientMaterialPricesDrawer(
      client: client,
      onClose: close,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel),
        ChangeNotifierProvider.value(value: _materialViewModel),
      ],
      child: Consumer2<ClientViewModel, MaterialViewModel>(
        builder: (context, viewModel, materialVm, child) {
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

                // Drawer custom is handled by GenericDataTable via customDrawerBuilder and controlled open state
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
            value:viewModel.isActiveFilter,
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
      // Active la fenêtre glissante personnalisée
      enableCustomWindow: true,
      customDrawerBuilder: (ctx, client, close) => _buildPricesDrawer(ctx, client, close),
      onOpenCustomWindow: (client) => _openPricesForClient(client),
      // Mode contrôlé depuis cette page
      isCustomWindowOpen: _isDrawerOpen,
      onToggleCustomWindow: (v) => setState(() => _isDrawerOpen = v),
      // Afficher un bouton supplémentaire dans la colonne Actions
      showCustomActionButton: true,
      customActionIcon: Icons.price_change,
      customActionTooltip: 'Prix matériaux',
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
