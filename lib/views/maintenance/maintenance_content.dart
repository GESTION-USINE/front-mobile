import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/machine_types.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../widgets/generic_data_table.dart';

/// Contenu de la liste des dépenses de maintenance (sans wrapper)
class MaintenanceContent extends StatefulWidget {
  const MaintenanceContent({super.key});

  @override
  State<MaintenanceContent> createState() => _MaintenanceContentState();
}

class _MaintenanceContentState extends State<MaintenanceContent> {
  late final MaintenanceViewModel _viewModel;
  String? _selectedMachineType;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<MaintenanceViewModel>();
    _viewModel.loadMaintenanceExpenses();
    _selectedDateFrom = _viewModel.dateFromFilter;
    _selectedDateTo = _viewModel.dateToFilter;
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
      child: Consumer<MaintenanceViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche et filtres
                _buildFilters(viewModel),
                const SizedBox(height: 12),

                // Affichage du coût total
                _buildTotalCostCard(viewModel),
                const SizedBox(height: 12),

                // Liste des dépenses de maintenance
                _buildMaintenanceList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(MaintenanceViewModel viewModel) {
    final Widget addButton = SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/maintenance/create'),
        style: AppTheme.industrialPrimaryButton.copyWith(
          minimumSize: MaterialStateProperty.all(const Size(170, 44)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Nouvelle dépense'),
      ),
    );

    final List<Widget> filters = [
      // Filtre Date début
      SizedBox(
          width: 180,
          child: InkWell(
            onTap: () => _selectDateFrom(context, viewModel),
            child: InputDecorator(
              decoration: AppTheme.industrialInputDecoration(
                hint: 'Date début',
                prefixIcon: Icons.calendar_today,
              ).copyWith(
                suffixIcon: _selectedDateFrom != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedDateFrom = null;
                          });
                          viewModel.filterByDateRange(null, _selectedDateTo);
                        },
                      )
                    : null,
              ),
              child: Text(
                _selectedDateFrom != null
                    ? _dateFormat.format(_selectedDateFrom!)
                    : 'Date début',
                style: TextStyle(
                  color: _selectedDateFrom != null
                      ? AppColors.industrialText
                      : AppColors.industrialTextLight,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

        // Filtre Date fin
        SizedBox(
          width: 180,
          child: InkWell(
            onTap: () => _selectDateTo(context, viewModel),
            child: InputDecorator(
              decoration: AppTheme.industrialInputDecoration(
                hint: 'Date fin',
                prefixIcon: Icons.calendar_today,
              ).copyWith(
                suffixIcon: _selectedDateTo != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedDateTo = null;
                          });
                          viewModel.filterByDateRange(_selectedDateFrom, null);
                        },
                      )
                    : null,
              ),
              child: Text(
                _selectedDateTo != null
                    ? _dateFormat.format(_selectedDateTo!)
                    : 'Date fin',
                style: TextStyle(
                  color: _selectedDateTo != null
                      ? AppColors.industrialText
                      : AppColors.industrialTextLight,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

        // Filtre Type de machine
        SizedBox(
          width: 250,
          child: DropdownButtonFormField<String>(
            value: _selectedMachineType,
            isExpanded: true,
            style: const TextStyle(color: AppColors.industrialText),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Type de frais...',
              prefixIcon: Icons.precision_manufacturing,
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Tous', style: TextStyle(color: AppColors.industrialTextLight)),
              ),
              ...machineTypes.map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: TextStyle(color: AppColors.industrialText)),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMachineType = value;
              });
              viewModel.filterByMachineType(value);
            },
          ),
        ),

      // Bouton reset filtres
      IconButton(
        onPressed: () {
          setState(() {
            _selectedMachineType = null;
            _selectedDateFrom = null;
            _selectedDateTo = null;
          });
          viewModel.refresh();
        },
        icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
        tooltip: 'Réinitialiser les filtres',
      ),

    
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [...filters, addButton],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: filters,
              ),
            ),
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }

  Widget _buildTotalCostCard(MaintenanceViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.industrialPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_money,
            color: AppColors.industrialPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coût total',
                style: TextStyle(
                  color: AppColors.industrialTextLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${viewModel.totalCost.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  color: AppColors.industrialPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Text(
            '${viewModel.total} dépense${viewModel.total > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppColors.industrialTextLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceList(MaintenanceViewModel viewModel) {
    // Colonnes à afficher
    final columnsToDisplay = <DataTableColumn<dynamic>>[
      DataTableColumn<dynamic>(
        label: 'Date',
        value: (expense) {
          final dynamic date = expense?.maintenanceDate;
          if (date is DateTime) {
            return _dateFormat.format(date);
          }
          return '-';
        },
      ),
      DataTableColumn<dynamic>(
        label: 'Type de machine',
        value: (expense) => expense?.machineType ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Description',
        value: (expense) => expense?.description ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Coût',
        value: (expense) {
          final dynamic cost = expense?.cost;
          final double c = cost is num ? cost.toDouble() : 0.0;
          return '${c.toStringAsFixed(2)} DZD';
        },
      ),
      DataTableColumn<dynamic>(
        label: 'Notes',
        value: (expense) => expense?.notes ?? '-',
      ),
    ];

    return GenericDataTable<dynamic>(
      items: viewModel.maintenanceExpenses,
      columns: columnsToDisplay,
      showActions: true,
      showEditAction: true,
      showDeleteAction: true,
      onEdit: (expense) {
        context.go('/maintenance/${expense.id}/edit', extra: expense);
      },
      onDelete: (expense) async {
        final confirmed = await _showDeleteConfirmation(context);
        if (confirmed == true) {
          final success = await viewModel.deleteMaintenanceExpense(expense.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dépense supprimée avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      },
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasError,
      errorMessage: viewModel.errorMessage,
      emptyMessage: 'Aucune dépense de maintenance trouvée',
      total: viewModel.total,
      currentPage: viewModel.currentPage,
      totalPages: viewModel.totalPages,
      onPreviousPage: viewModel.hasPreviousPage
          ? () => viewModel.previousPage()
          : null,
      onNextPage: viewModel.hasNextPage ? () => viewModel.nextPage() : null,
      enableCustomWindow: false,
      showCustomActionButton: false,
    );
  }

  Future<void> _selectDateFrom(
    BuildContext context,
    MaintenanceViewModel viewModel,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFrom ?? DateTime.now(),
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
      setState(() {
        _selectedDateFrom = picked;
      });
      viewModel.filterByDateRange(picked, _selectedDateTo);
    }
  }

  Future<void> _selectDateTo(
    BuildContext context,
    MaintenanceViewModel viewModel,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTo ?? DateTime.now(),
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
      setState(() {
        _selectedDateTo = picked;
      });
      viewModel.filterByDateRange(_selectedDateFrom, picked);
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette dépense de maintenance ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
