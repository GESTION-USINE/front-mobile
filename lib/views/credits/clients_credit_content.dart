import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/clients_credit_viewmodel.dart';
import '../../models/response/clients_credit_response.dart';
import '../../di/injection_container.dart';
import '../widgets/generic_data_table.dart';
import 'client_credit_details_page.dart';

class ClientsCreditContent extends StatefulWidget {
  const ClientsCreditContent({super.key});

  @override
  State<ClientsCreditContent> createState() => _ClientsCreditContentState();
}

class _ClientsCreditContentState extends State<ClientsCreditContent> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  ClientsCreditViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientsCreditViewModel>();
    _viewModel!.loadClientsWithCredit();
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
      child: Consumer<ClientsCreditViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Crédits par Client',
                                style: AppTheme.headingLarge,
                              ),
                              Text(
                                'Vue globale des crédits restants',
                                style: AppTheme.subtitleMedium.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                              _buildSummaryCard(viewModel),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Crédits par Client',
                                      style: AppTheme.headingLarge,
                                    ),
                                    Text(
                                      'Vue globale des crédits restants',
                                      style: AppTheme.subtitleMedium.copyWith(
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildSummaryCard(viewModel),
                            ],
                          ),
                    const SizedBox(height: 8),

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

  Widget _buildSummaryCard(ClientsCreditViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          AppTheme.borderRadiusMedium,
        ),
        border: Border.all(
          color: AppColors.warning,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Crédit Global',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _currencyFormat.format(viewModel.totalCredit),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
          Text(
            '${viewModel.totalRecords} client(s) | ${viewModel.totalSlipsWithCredit} bon(s)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(ClientsCreditViewModel viewModel) {
    final columns = <DataTableColumn<ClientCredit>>[
      DataTableColumn<ClientCredit>(
        label: 'Nom Client',
        value: (client) => client.name,
      ),
      DataTableColumn<ClientCredit>(
        label: 'Email',
        value: (client) => client.email ?? '-',
        hideOnMobile: false,
      ),
      DataTableColumn<ClientCredit>(
        label: 'Téléphone',
        value: (client) => client.phone ?? '-',
        hideOnMobile: false,
      ),
      DataTableColumn<ClientCredit>(
        label: 'Crédit Total',
        value: (client) => Text(
          _currencyFormat.format(client.totalRemainingCredit),
          style: const TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        isWidget: true,
      ),
      DataTableColumn<ClientCredit>(
        label: 'Nbre Bons',
        value: (client) => Text(
          '${client.slipsCount}',
          style: const TextStyle(
            color: AppColors.info,
            fontWeight: FontWeight.w600,
          ),
        ),
        isWidget: true,
      ),
    ];

    return GenericDataTable<ClientCredit>(
      items: viewModel.clients,
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
      emptyMessage: 'Aucun client avec crédit',
      total: viewModel.totalRecords,
      currentPage: viewModel.currentPage,
      totalPages: viewModel.totalPages,
      onPreviousPage: viewModel.currentPage > 1
          ? () => viewModel.loadClientsWithCredit(page: viewModel.currentPage - 1)
          : null,
      onNextPage: viewModel.currentPage < viewModel.totalPages
          ? () => viewModel.loadClientsWithCredit(page: viewModel.currentPage + 1)
          : null,
      onEdit: (_) {},
      onDelete: (_) {},
    );
  }
}
