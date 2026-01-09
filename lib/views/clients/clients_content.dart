import 'package:flutter/material.dart';
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
import '../../models/entities/material_price.dart';

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

  bool _showPricesPanel = false;
  dynamic _selectedClient;

  final Map<int, TextEditingController> _priceControllers = {};
  int? _priceClientId;
  bool _priceControllersReady = false;

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
    _viewModel.dispose();
    _materialViewModel.dispose();
    _clearPriceControllers();
    super.dispose();
  }

  void _clearPriceControllers() {
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    _priceControllers.clear();
    _priceClientId = null;
    _priceControllersReady = false;
  }

  void _initPriceControllers(List<MaterialPriceItem> items, int? clientId) {
    if (clientId == null) return;

    if (_priceClientId != clientId) {
      _clearPriceControllers();
      _priceClientId = clientId;
    }

    if (_priceControllersReady) return;

    for (final item in items) {
      final key = item.materialId;
      if (key == null) continue;
      _priceControllers.putIfAbsent(
        key,
        () => TextEditingController(text: item.customPricePerTon?.toString() ?? ''),
      );
    }

    if (items.isNotEmpty) {
      _priceControllersReady = true;
    }
  }

  Future<void> _openPricesForClient(dynamic client) async {
    // D'abord charger les données
    await _materialViewModel.loadClientMaterialPrices(clientId: client.id, refresh: true);
    _priceControllersReady = false;

    // Ensuite afficher le panneau avec les données fraîches
    if (mounted) {
      setState(() {
        _selectedClient = client;
        _showPricesPanel = true;
      });
    }
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
                // Barre de recherche, filtres et bouton d'ajout sur la même ligne (wrap responsive)
                _buildFilters(viewModel, role),
                const SizedBox(height: 12),
                // Liste des clients
                _buildClientsList(viewModel, role),

                const SizedBox(height: 16),
                _buildMaterialPricesPanel(materialVm, role),

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
          width: 180,
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
                  child: Text('Avec Chèque',
                      style: TextStyle(color: AppColors.industrialText))),
              DropdownMenuItem(
                  value: false,
                  child: Text('Sans Chèque',
                      style: TextStyle(color: AppColors.industrialText))),
            ],
            onChanged: (value) => viewModel.filterByCanPayByCheck(value),
          ),
        ),

        // Bouton reset filtres
        IconButton(
          onPressed: () {
            _searchController.clear();
            viewModel.refresh();
          },
          icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
          tooltip: 'Réinitialiser les filtres',
        ),

        // Bouton Nouveau client (placé en dernier)
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => context.go(AppRouter.clientsCreate),
            style: AppTheme.industrialPrimaryButton.copyWith(
              minimumSize: MaterialStateProperty.all(const Size(150, 44)),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nouveau client'),
          ),
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
        isWidget: true,
        value: (client) => Text(
          client?.name ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.industrialText),
        ),
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
        isWidget: true,
        value: (client) {
          final dynamic c = client?.credit;
          final double d = c is num ? c.toDouble() : 0.0;
          return Text(
            d.toStringAsFixed(2),
            style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
          );
        },
      ),
      DataTableColumn<dynamic>(
        label: ' Chèque',
        isWidget: true,
        value: (client) {
          final can = client?.canPayByCheck ?? false;
          return Icon(
            can ? Icons.check_circle : Icons.cancel,
            color: can ? AppColors.success : AppColors.danger,
            size: 18,
          );
        },
      ),
    ];

    return GenericDataTable<dynamic>(
      items: displayedClients,
      columns: columnsToDisplay,
      showActions: !isEmployee,
      showEditAction: true,
      showDeleteAction: false,
      enableCustomWindow: false,
      // Bouton prix matériaux
      showCustomActionButton: true,
      customActionIcon: Icons.price_change,
      customActionTooltip: 'Prix matériaux',
      onCustomAction: (client) => _openPricesForClient(client),
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

  Widget _buildMaterialPricesPanel(MaterialViewModel materialVm, String? role) {
    if (!_showPricesPanel || _selectedClient == null) {
      return const SizedBox.shrink();
    }

    final bool isSuperAdmin = role?.toLowerCase() == 'super_admin';
    final items = materialVm.materialPrices ?? const <MaterialPriceItem>[];
    final clientId = _selectedClient?.id as int?;
    _initPriceControllers(items, clientId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth * 0.5;

        return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: panelWidth),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prix matériaux - ${_selectedClient?.name ?? ''}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.industrialText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Liste des matériaux avec prix par défaut et prix client.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.industrialTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showPricesPanel = false;
                              _selectedClient = null;
                            });
                            _clearPriceControllers();
                          },
                          icon: const Icon(Icons.close, color: AppColors.industrialText),
                          tooltip: 'Fermer',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.grey200),
                  if (materialVm.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Aucun matériau disponible pour ce client.',
                        style: TextStyle(color: AppColors.industrialTextLight),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: GenericDataTable<MaterialPriceItem>(
                        items: items,
                        columns: [
                          DataTableColumn<MaterialPriceItem>(
                            label: 'Matériau',
                            value: (item) => item.materialName,
                          ),
                          DataTableColumn<MaterialPriceItem>(
                            label: 'Prix défaut',
                            value: (item) => '${item.defaultPricePerTon.toStringAsFixed(2)} DA',
                          ),
                          DataTableColumn<MaterialPriceItem>(
                            label: 'Prix spécial',
                            isWidget: true,
                            value: (item) {
                              final controller = _priceControllers[item.materialId] ??
                                  TextEditingController(text: item.customPricePerTon?.toString() ?? '');
                              _priceControllers[item.materialId ?? -1] = controller;
                              return SizedBox(
                                width: 110,
                                child: TextFormField(
                                  controller: controller,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Optionnel',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              );
                            },
                          ),
                        ],
                        showActions: isSuperAdmin,
                        showEditAction: true,
                        showDeleteAction: true,
                        showCustomActionButton: false,
                        onEdit: (item) {
                          final text = _priceControllers[item.materialId]?.text.trim() ?? '';
                          final value = text.isNotEmpty ? double.tryParse(text.replaceAll(',', '.')) : null;
                          if (value != null) {
                            materialVm.createClientMaterialPrice(
                              clientId: item.clientId,
                              materialId: item.materialId,
                              customPricePerTon: value,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Prix spécial enregistré')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez entrer un prix valide')),
                            );
                          }
                        },
                        onDelete: (item) {
                          if (item.materialPriceId != null) {
                            materialVm.deleteClientMaterialPrice(
                              priceId: item.materialPriceId!,
                              clientId: item.clientId,
                            );
                            _priceControllers[item.materialId]?.clear();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Prix spécial supprimé'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        isLoading: false,
                        hasError: false,
                        emptyMessage: 'Aucun matériau disponible',
                        showPagination: false,
                        total: items.length,
                        currentPage: 1,
                        totalPages: 1,
                        onPreviousPage: null,
                        onNextPage: null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeBadge(String type) {
    final isEnterprise = type == 'entreprise';
    final bgColor = isEnterprise ? AppColors.info.withOpacity(0.1) : AppColors.accent.withOpacity(0.12);
    final textColor = isEnterprise ? AppColors.info : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEnterprise ? 'Entreprise' : 'Particulier',
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
