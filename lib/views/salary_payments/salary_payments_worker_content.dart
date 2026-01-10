import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/entities/salary_payment.dart';
import '../../models/entities/worker.dart';
import '../../viewmodels/salary_payement_viewmodel.dart';
import '../widgets/generic_data_table.dart';

/// Contenu des paiements de salaire (sans appbar) pour intégration dans d'autres vues
class SalaryPaymentsWorkerContent extends StatefulWidget {
  final Worker worker;
  final SalaryPaymentViewModel viewModel;

  const SalaryPaymentsWorkerContent({
    super.key,
    required this.worker,
    required this.viewModel,
  });

  @override
  State<SalaryPaymentsWorkerContent> createState() =>
      _SalaryPaymentsWorkerContentState();
}

class _SalaryPaymentsWorkerContentState
    extends State<SalaryPaymentsWorkerContent> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _currencyFormat = NumberFormat('#,##0.00', 'fr_FR');

  DateTime? _dateFromFilter;
  DateTime? _dateToFilter;
  final _paymentMonthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger après le premier build pour éviter les problèmes de state mutation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.filterByWorkerId(widget.worker.id);
    });
  }

  @override
  void dispose() {
    _paymentMonthController.dispose();
    super.dispose();
  }

  Future<void> _selectDateFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFromFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.industrialText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateFromFilter = picked;
      });
      _applyFilters();
    }
  }

  Future<void> _selectDateTo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateToFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.industrialText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateToFilter = picked;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    widget.viewModel.filterByDateRange(_dateFromFilter, _dateToFilter);
    if (_paymentMonthController.text.isNotEmpty) {
      widget.viewModel.filterByPaymentMonth(_paymentMonthController.text);
    }
  }

  void _resetFilters() {
    setState(() {
      _dateFromFilter = null;
      _dateToFilter = null;
      _paymentMonthController.clear();
    });
  }

  void _handleEdit(SalaryPayment payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition du paiement non disponible pour le moment'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleDelete(SalaryPayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce paiement de ${_currencyFormat.format(payment.amount)} DZD ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression non disponible pour le moment'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Consumer<SalaryPaymentViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres compacts
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtres',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Réinitialiser'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterField(
                            label: 'De',
                            value: _dateFromFilter != null
                                ? _dateFormat.format(_dateFromFilter!)
                                : 'Sélectionner',
                            onTap: _selectDateFrom,
                          ),
                          const SizedBox(height: 8),
                          _buildFilterField(
                            label: 'À',
                            value: _dateToFilter != null
                                ? _dateFormat.format(_dateToFilter!)
                                : 'Sélectionner',
                            onTap: _selectDateTo,
                          ),
                          const SizedBox(height: 8),
                          _buildFilterField(
                            label: 'Mois de paiement',
                            controller: _paymentMonthController,
                            onChanged: (_) => _applyFilters(),
                            isTextField: true,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterField(
                              label: 'De',
                              value: _dateFromFilter != null
                                  ? _dateFormat.format(_dateFromFilter!)
                                  : 'Sélectionner',
                              onTap: _selectDateFrom,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterField(
                              label: 'À',
                              value: _dateToFilter != null
                                  ? _dateFormat.format(_dateToFilter!)
                                  : 'Sélectionner',
                              onTap: _selectDateTo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterField(
                              label: 'Mois de paiement',
                              controller: _paymentMonthController,
                              onChanged: (_) => _applyFilters(),
                              isTextField: true,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Informations résumées
              if (viewModel.hasSalaryPayments)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.industrialBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Nombre de paiements',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${viewModel.total}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.industrialText,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Montant total',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currencyFormat.format(viewModel.totalAmount)} DZD',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.industrialPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Tableau de données
              GenericDataTable<SalaryPayment>(
                items: viewModel.salaryPayments,
                columns: [
                  DataTableColumn(
                    label: 'Mois de paiement',
                    value: (item) => item.paymentMonth,
                  ),
                  DataTableColumn(
                    label: 'Montant',
                    value: (item) =>
                        '${_currencyFormat.format(item.amount)} DZD',
                  ),
                  DataTableColumn(
                    label: 'Date de paiement',
                    value: (item) => _dateFormat.format(item.paymentDate),
                  ),
                  DataTableColumn(
                    label: 'Notes',
                    value: (item) => item.notes ?? '-',
                    hideOnMobile: true,
                  ),
                ],
                onEdit: _handleEdit,
                onDelete: _handleDelete,
                showDeleteAction: false,
                showEditAction: false,
                showActions: false,
                showPagination: true,
                total: viewModel.total,
                currentPage: viewModel.currentPage,
                totalPages: viewModel.totalPages,
                onPreviousPage: viewModel.hasPreviousPage
                    ? () => viewModel.previousPage()
                    : null,
                onNextPage: viewModel.hasNextPage
                    ? () => viewModel.nextPage()
                    : null,
                isLoading: viewModel.isLoading,
                hasError: viewModel.hasError,
                errorMessage: viewModel.errorMessage,
                emptyMessage: 'Aucun paiement de salaire trouvé',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterField({
    required String label,
    String? value,
    TextEditingController? controller,
    VoidCallback? onTap,
    Function(String)? onChanged,
    bool isTextField = false,
  }) {
    return GestureDetector(
      onTap: isTextField ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          if (isTextField)
            TextFormField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'yyyy-MM-dd',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? 'Sélectionner',
                    style: TextStyle(
                      fontSize: 12,
                      color: value != null
                          ? AppColors.industrialText
                          : AppColors.grey600,
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
