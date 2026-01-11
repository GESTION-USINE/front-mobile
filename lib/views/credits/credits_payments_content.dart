import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/entities/credit_payment_item.dart';
import '../../viewmodels/credits_payments_viewmodel.dart';
import '../widgets/generic_data_table.dart';

class CreditsPaymentsContent extends StatefulWidget {
  const CreditsPaymentsContent({super.key});

  @override
  State<CreditsPaymentsContent> createState() => _CreditsPaymentsContentState();
}

class _CreditsPaymentsContentState extends State<CreditsPaymentsContent> {
  late final CreditsPaymentsViewModel _viewModel;
  late DateTime _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _moneyFormat = NumberFormat.decimalPattern('fr_FR');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CreditsPaymentsViewModel>();
    _selectedDate = _parseSelectedDate(_viewModel.selectedDate);
    _viewModel.loadCreditsPayments();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CreditsPaymentsViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(viewModel),
                const SizedBox(height: 12),
                _buildTotals(viewModel),
                const SizedBox(height: 12),
                _buildTable(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CreditsPaymentsViewModel viewModel) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Sélecteur de date
        SizedBox(
          width: 220,
          child: InkWell(
            onTap: () => _selectDate(context, viewModel),
            child: InputDecorator(
              decoration: AppTheme.industrialInputDecoration(
                hint: 'Date',
                prefixIcon: Icons.calendar_today,
              ),
              child: Text(
                _dateFormat.format(_selectedDate),
                style: const TextStyle(
                  color: AppColors.industrialText,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

      

        // Bouton refresh backend
        IconButton(
          onPressed: () => viewModel.refresh(),
          icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
          tooltip: 'Actualiser (fetch backend)',
        ),
      
      ],
    );
  }

  Widget _buildTotals(CreditsPaymentsViewModel viewModel) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _totalCard(
          title: 'Montant total',
          value: '${_moneyFormat.format(viewModel.totalAmount)} DZD',
          icon: Icons.payments_outlined,
          color: AppColors.industrialPrimary,
        ),
        _totalCard(
          title: 'Encaissements',
          value: '${viewModel.count} paiement${viewModel.count > 1 ? 's' : ''}',
          icon: Icons.receipt_long,
          color: AppColors.info,
        ),
        _totalCard(
          title: 'Cash',
          value: '${_moneyFormat.format(viewModel.cashTotal)} DZD',
          icon: Icons.attach_money,
          color: AppColors.success,
        ),
        _totalCard(
          title: 'Chèques',
          value: '${_moneyFormat.format(viewModel.checkTotal)} DZD',
          icon: Icons.fact_check_outlined,
          color: AppColors.warning,
        ),
        // _totalCard(
        //   title: 'Ch. garantie',
        //   value: '${_moneyFormat.format(viewModel.guaranteeCheckTotal)} DZD',
        //   icon: Icons.verified_outlined,
        //   color: AppColors.danger,
        // ),
      ],
    );
  }

  Widget _totalCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.industrialTextLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.industrialText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(CreditsPaymentsViewModel viewModel) {
    final columns = <DataTableColumn<CreditPaymentItem>>[
      DataTableColumn<CreditPaymentItem>(
        label: 'Bon',
        value: (p) => p.slipNumber,
      ),
      DataTableColumn<CreditPaymentItem>(
        label: 'Client',
        value: (p) => '${p.clientName} (${p.clientType})',
      ),
      DataTableColumn<CreditPaymentItem>(
        label: 'Type',
        value: (p) => _formatPaymentType(p.paymentType),
      ),
      DataTableColumn<CreditPaymentItem>(
        label: 'Montant',
        value: (p) => '${_moneyFormat.format(p.amountPaid)} DZD',
      ),
      DataTableColumn<CreditPaymentItem>(
        label: 'Par',
        value: (p) => p.createdBy,
      ),
      DataTableColumn<CreditPaymentItem>(
        label: 'Date',
        value: (p) => _dateFormat.format(p.createdAt.toLocal()),
      ),
    ];

    return GenericDataTable<CreditPaymentItem>(
      items: viewModel.payments,
      columns: columns,
      showActions: false,
      onEdit: (_) {},
      onDelete: (_) {},
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasError,
      errorMessage: viewModel.errorMessage,
      emptyMessage: 'Aucun encaissement pour cette date',
      total: viewModel.payments.length,
      currentPage: 1,
      totalPages: 1,
      onPreviousPage: null,
      onNextPage: null,
      enableCustomWindow: false,
      showCustomActionButton: false,
    );
  }

  String _formatPaymentType(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'check':
        return 'Chèque';
      case 'guarantee_check':
        return 'Chèque garantie';
      default:
        return type;
    }
  }

  DateTime _parseSelectedDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    CreditsPaymentsViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      await viewModel.changeDate(picked);
    }
  }
}
