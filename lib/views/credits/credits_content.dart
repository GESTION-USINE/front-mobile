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
import 'payment_details_page.dart';

class CreditsContent extends StatefulWidget {
  const CreditsContent({super.key});

  @override
  State<CreditsContent> createState() => _CreditsContentState();
}

class _CreditsContentState extends State<CreditsContent> {
  final TextEditingController _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  CreditPaymentViewModel? _viewModel;
  DateTime? _startDate;
  DateTime? _endDate;

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

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _applyDateFilter();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _applyDateFilter();
    }
  }

  void _applyDateFilter() {
    if (_startDate != null || _endDate != null) {
      final dateFrom = _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null;
      final dateTo = _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;
      
      _viewModel!.loadSlipsWithCredit(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _viewModel!.loadSlipsWithCredit(
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
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

  void _openPaymentDetails(WeighingSlip slip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailsPage(weighingSlipId: slip.id),
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
                            Text(
                              'Bons de pesée avec crédit restant',
                              style: AppTheme.subtitleMedium.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
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
                                  Text(
                                    'Bons de pesée avec crédit restant',
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

                    // Search Bar and Date Filter
                    _buildSearchAndDateFilter(),
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

  Widget _buildSearchAndDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppColors.grey300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          
          if (isMobile) {
            return Column(
              children: [
                // Search field
                Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.grey500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          _applyDateFilter();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _viewModel!.loadSlipsWithCredit(),
                    ),
                  ],
                ),
                const Divider(height: 16),
                // Date filters
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactDateButton(
                        icon: Icons.date_range,
                        label: 'Début',
                        date: _startDate,
                        onPressed: _selectStartDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactDateButton(
                        icon: Icons.date_range,
                        label: 'Fin',
                        date: _endDate,
                        onPressed: _selectEndDate,
                      ),
                    ),
                    if (_startDate != null || _endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        color: AppColors.lightError,
                        tooltip: 'Effacer',
                        onPressed: _clearDateFilter,
                      ),
                  ],
                ),
              ],
            );
          }
          
          return Row(
            children: [
              // Search field
              const Icon(Icons.search, color: AppColors.grey500),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher par numéro de bon ou client...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    _applyDateFilter();
                  },
                ),
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, thickness: 1),
              const SizedBox(width: 16),
              // Date filters
              _buildCompactDateButton(
                icon: Icons.date_range,
                label: 'Début',
                date: _startDate,
                onPressed: _selectStartDate,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: AppColors.grey400, size: 16),
              const SizedBox(width: 8),
              _buildCompactDateButton(
                icon: Icons.date_range,
                label: 'Fin',
                date: _endDate,
                onPressed: _selectEndDate,
              ),
              if (_startDate != null || _endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: AppColors.lightError,
                  tooltip: 'Effacer filtre',
                  onPressed: _clearDateFilter,
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _viewModel!.loadSlipsWithCredit(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactDateButton({
    required IconData icon,
    required String label,
    required DateTime? date,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: date != null ? AppColors.primary.withOpacity(0.1) : AppColors.grey100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: date != null ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: date != null ? AppColors.primary : AppColors.grey500,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: date != null ? AppColors.primary : AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date != null ? DateFormat('dd/MM/yy').format(date) : '--/--/--',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                    color: date != null ? AppColors.primary : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CreditPaymentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
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
      showEditAction: true,
      showDeleteAction: false,
      editLabel: 'Détails',
      editIcon: Icons.info_outline,
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
      onEdit: (slip) => _openPaymentDetails(slip),
      onDelete: (_) {},
    );
  }
}