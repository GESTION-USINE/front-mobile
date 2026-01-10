import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/worker_viewmodel.dart';
import '../widgets/generic_data_table.dart';

/// Contenu de la liste des travailleurs (sans wrapper)
class WorkersContent extends StatefulWidget {
  const WorkersContent({super.key});

  @override
  State<WorkersContent> createState() => _WorkersContentState();
}

class _WorkersContentState extends State<WorkersContent> {
  late final WorkerViewModel _viewModel;
  final _searchController = TextEditingController();
  bool? _selectedIsActive;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<WorkerViewModel>();
    _viewModel.loadWorkers();
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
      child: Consumer<WorkerViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtres
                _buildFilters(viewModel),
                const SizedBox(height: 12),

                // Liste des travailleurs
                _buildWorkersList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(WorkerViewModel viewModel) {
    final Widget addButton = SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/workers/create'),
        style: AppTheme.industrialPrimaryButton.copyWith(
          minimumSize: MaterialStateProperty.all(const Size(190, 44)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Nouveau travailleur'),
      ),
    );

    final List<Widget> filters = [
      // Recherche
      SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.industrialText),
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Rechercher...',
              prefixIcon: Icons.search,
            ).copyWith(
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.searchWorkers('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => viewModel.searchWorkers(value),
          ),
        ),

        // Filtre Statut actif
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<bool?>(
            value: _selectedIsActive,
            isExpanded: true,
            style: const TextStyle(color: AppColors.industrialText),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Statut',
              prefixIcon: Icons.check_circle_outline,
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text('Tous', style: TextStyle(color: AppColors.industrialText)),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Actif', style: TextStyle(color: AppColors.industrialText)),
              ),
              DropdownMenuItem(
                value: false,
                child: Text('Inactif', style: TextStyle(color: AppColors.industrialText)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedIsActive = value;
              });
              viewModel.filterByIsActive(value);
            },
          ),
        ),

      // Bouton reset filtres
      IconButton(
        onPressed: () {
          setState(() {
            _searchController.clear();
            _selectedIsActive = null;
          });
          viewModel.refresh();
        },
        icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
        tooltip: 'Réinitialiser les filtres',
      ),

      // Bouton refresh (force fetch backend)
  
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

  Widget _buildWorkersList(WorkerViewModel viewModel) {
    final columnsToDisplay = <DataTableColumn<dynamic>>[
      DataTableColumn<dynamic>(
        label: 'Nom complet',
        value: (worker) => worker?.fullName ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Téléphone',
        value: (worker) => worker?.phone ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Poste',
        value: (worker) => worker?.jobPosition ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Date d\'embauche',
        value: (worker) {
          final dynamic date = worker?.hireDate;
          if (date is DateTime) {
            return _dateFormat.format(date);
          }
          return '-';
        },
      ),
      DataTableColumn<dynamic>(
        label: 'Salaire (DZD)',
        value: (worker) {
          final dynamic salary = worker?.monthlySalary;
          final double s = salary is num ? salary.toDouble() : 0.0;
          return s.toStringAsFixed(2);
        },
      ),
      DataTableColumn<dynamic>(
        label: 'Statut',
        value: (worker) {
          final bool isActive = worker?.isActive ?? false;
          return isActive ? 'Actif' : 'Inactif';
        },
      ),
    ];

    return GenericDataTable<dynamic>(
      items: viewModel.workers,
      columns: columnsToDisplay,
      showActions: true,
      showEditAction: true,
      showDeleteAction: false,
      showCustomActionButton: false,
      customActionIcon: Icons.payments,
      customActionTooltip: 'Paiements',
      onEdit: (worker) {
        context.go('/workers/${worker.id}/edit', extra: worker);
      },
      onDelete: (_) {},
      onCustomAction: (worker) {
        context.go('/workers/${worker.id}/salary-payments', extra: worker);
      },
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasError,
      errorMessage: viewModel.errorMessage,
      emptyMessage: 'Aucun travailleur trouvé',
      total: viewModel.total,
      currentPage: viewModel.currentPage,
      totalPages: viewModel.totalPages,
      onPreviousPage: viewModel.hasPreviousPage
          ? () => viewModel.previousPage()
          : null,
      onNextPage: viewModel.hasNextPage ? () => viewModel.nextPage() : null,
      enableCustomWindow: false,
    );
  }
}
