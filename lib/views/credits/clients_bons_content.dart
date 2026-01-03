import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/clients_with_slips_viewmodel.dart';
import '../../models/response/clients_with_slips_response.dart';
import '../../di/injection_container.dart';
import '../widgets/generic_data_table.dart';
import 'client_credit_details_page.dart';

class ClientsBonsContent extends StatefulWidget {
  const ClientsBonsContent({super.key});

  @override
  State<ClientsBonsContent> createState() => _ClientsBonsContentState();
}

class _ClientsBonsContentState extends State<ClientsBonsContent> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  ClientsWithSlipsViewModel? _viewModel;
  String _searchQuery = '';
  String _filterByStatus = 'all'; // all, active, inactive, with_credit

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientsWithSlipsViewModel>();
    _viewModel!.loadClientsWithSlips();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<ClientsWithSlipsViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Bons Clients',
                      style: AppTheme.headingLarge,
                    ),
                    Text(
                      'Liste des clients avec leurs bons de pesée et crédits',
                      style: AppTheme.subtitleMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Summary Card
                    _buildSummaryCard(viewModel),
                    const SizedBox(height: 16),

                    // Search and Filter
                    _buildSearchAndFilterBar(),
                    const SizedBox(height: 16),

                    // Table
                    _buildTable(viewModel),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ClientsWithSlipsViewModel viewModel) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildStatCard('Clients', '${viewModel.totalClients}', AppColors.info),
                  _buildStatCard('Total Bons', '${viewModel.totalSlips}', AppColors.primary),
                  _buildStatCard('Bons Crédit', '${viewModel.totalSlipsWithCredit}', AppColors.danger),
                  _buildStatCard(
                    'Crédit Restant',
                    _currencyFormat.format(viewModel.totalCredit),
                    AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un client...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey600, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _filterByStatus = value;
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.apps_outlined, size: 18, color: AppColors.grey700),
                      SizedBox(width: 10),
                      Text('Tous'),
                    ],
                  ),
                ),    
                const PopupMenuItem(
                  value: 'with_credit',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.warning),
                      SizedBox(width: 10),
                      Text('Avec crédit'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_outlined, size: 18, color: AppColors.grey700),
                    const SizedBox(width: 4),
                    Text(
                      _getFilterLabel(),
                      style: const TextStyle(fontSize: 12, color: AppColors.grey700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel() {
    switch (_filterByStatus) {
      case 'with_credit':
        return 'Crédit';
      default:
        return 'Tous';
    }
  }

  Widget _buildTable(ClientsWithSlipsViewModel viewModel) {
    // Apply filters and search
    List<ClientWithSlips> filteredClients = viewModel.clients.where((client) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (client.name.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (client.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (client.phone?.contains(_searchQuery) ?? false);

      // Apply status filter
      bool matchesStatus = true;
      switch (_filterByStatus) {
        case 'active':
          matchesStatus = client.slipsWithActiveCredit > 0;
          break;
        case 'inactive':
          matchesStatus = client.slipsWithActiveCredit == 0;
          break;
        case 'with_credit':
          matchesStatus = client.totalRemainingCredit > 0;
          break;
        default:
          matchesStatus = true;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    final columns = <DataTableColumn<ClientWithSlips>>[
      DataTableColumn<ClientWithSlips>(
        label: 'Nom Client',
        value: (client) => client.name,
      ),
      DataTableColumn<ClientWithSlips>(
        label: 'Email',
        value: (client) => client.email ?? '-',
        hideOnMobile: true,
      ),
      DataTableColumn<ClientWithSlips>(
        label: 'Téléphone',
        value: (client) => client.phone ?? '-',
        hideOnMobile: false,
      ),
      DataTableColumn<ClientWithSlips>(
        label: 'Bons Payés',
        value: (client) => Text(
          '${client.fullyPaidSlips}',
          style: const TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        isWidget: true,
      ),
      DataTableColumn<ClientWithSlips>(
        label: 'Bons Crédit',
        value: (client) => Text(
          '${client.slipsWithActiveCredit}',
          style: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.w600,
          ),
        ),
        isWidget: true,
      ),
      DataTableColumn<ClientWithSlips>(
        label: 'Crédit Total',
        value: (client) => Text(
          _currencyFormat.format(client.totalRemainingCredit),
          style: const TextStyle(
            color: AppColors.lightError,
            fontWeight: FontWeight.bold,
          ),
        ),
        isWidget: true,
      ),
    ];

    return GenericDataTable<ClientWithSlips>(
      items: filteredClients,
      columns: columns,
      showActions: true,
      showEditAction: false,
      showDeleteAction: false,
      showCustomActionButton: true,
      customActionIcon: Icons.info_outline,
      customActionTooltip: 'Voir détails',
      onCustomAction: (client) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientCreditDetailsPage(clientId: client.id),
          ),
        );
      },
      isLoading: viewModel.isLoading,
      hasError: viewModel.error != null,
      errorMessage: viewModel.error,
      emptyMessage: 'Aucun client correspondant aux critères',
      total: filteredClients.length,
      currentPage: 1,
      totalPages: 1,
      onEdit: (_) {},
      onDelete: (_) {},
    );
  }
}
