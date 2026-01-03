import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/credit_payment_viewmodel.dart';
import '../../models/entities/weighing_slip.dart';
import '../../di/injection_container.dart';
import '../widgets/generic_data_table.dart';
import 'payment_form_dialog.dart';

class CreditsContent extends StatefulWidget {
  const CreditsContent({super.key});

  @override
  State<CreditsContent> createState() => _CreditsContentState();
}

class _CreditsContentState extends State<CreditsContent> {
  final TextEditingController _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  CreditPaymentViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CreditPaymentViewModel>();
    _viewModel!.loadSlipsWithCredit();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  void _openPaymentPage(WeighingSlip slip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _viewModel!,
          child: PaymentFormPage(slip: slip),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<CreditPaymentViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    isMobile 
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gestion des Crédits',
                              style: AppTheme.headingLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bons de pesée avec crédit restant',
                              style: AppTheme.subtitleMedium.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Summary Card
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
                                    'Gestion des Crédits',
                                    style: AppTheme.headingLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bons de pesée avec crédit restant',
                                    style: AppTheme.subtitleMedium.copyWith(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(viewModel),
                          ],
                        ),
                    const SizedBox(height: 24),

                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.grey500),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Rechercher par numéro de bon ou client...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) {
                                viewModel.loadSlipsWithCredit(search: value);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => viewModel.loadSlipsWithCredit(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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

  Widget _buildSummaryCard(CreditPaymentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
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
            'Crédit Total',
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
              _currencyFormat.format(viewModel.totalCreditAmount),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
          Text(
            '${viewModel.slipsWithCreditCount} bon(s)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(CreditPaymentViewModel viewModel) {
    final columns = <DataTableColumn<WeighingSlip>>[
      DataTableColumn<WeighingSlip>(
        label: 'N° Bon',
        value: (slip) => slip.slipNumber ?? '-',
      ),
      DataTableColumn<WeighingSlip>(
        label: 'Client',
        value: (slip) => slip.clientName ?? '-',
      ),
      DataTableColumn<WeighingSlip>(
        label: 'Date',
        value: (slip) => DateFormat('dd/MM/yyyy').format(slip.createdAt),
      ),
      DataTableColumn<WeighingSlip>(
        label: 'Montant Total',
        value: (slip) => _currencyFormat.format(slip.totalAmount),
      ),
      DataTableColumn<WeighingSlip>(
        label: 'Payé',
        value: (slip) => Text(
          _currencyFormat.format(slip.totalPaid ?? 0),
          style: const TextStyle(color: AppColors.success),
        ),
        isWidget: true,
        hideOnMobile: true,
      ),
      DataTableColumn<WeighingSlip>(
        label: 'Crédit Restant',
        value: (slip) => Text(
          _currencyFormat.format(slip.remainingCredit ?? 0),
          style: const TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        isWidget: true,
      ),
    ];

    return GenericDataTable<WeighingSlip>(
      items: viewModel.slipsWithCredit,
      columns: columns,
      showActions: true,
      showEditAction: false,
      showDeleteAction: false,
      isLoading: viewModel.isLoading,
      hasError: viewModel.error != null,
      errorMessage: viewModel.error,
      emptyMessage: 'Aucun bon avec crédit',
      total: viewModel.totalRecords,
      currentPage: viewModel.currentPage,
      totalPages: viewModel.totalPages,
      onPreviousPage: viewModel.currentPage > 1
          ? () => viewModel.loadSlipsWithCredit(page: viewModel.currentPage - 1)
          : null,
      onNextPage: viewModel.currentPage < viewModel.totalPages
          ? () => viewModel.loadSlipsWithCredit(page: viewModel.currentPage + 1)
          : null,
      showCustomActionButton: true,
      customActionIcon: Icons.payment,
      customActionTooltip: 'Payer',
      onCustomAction: (slip) => _openPaymentPage(slip),
      onEdit: (_) {},
      onDelete: (_) {},
    );
  }
}