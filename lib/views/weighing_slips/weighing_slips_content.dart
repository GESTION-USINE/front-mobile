import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/weighing_slip_viewmodel.dart';
import '../widgets/generic_data_table.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_router.dart';
import '../../models/entities/weighing_slip.dart';

class WeighingSlipsContent extends StatefulWidget {
  const WeighingSlipsContent({super.key});

  @override
  State<WeighingSlipsContent> createState() => _WeighingSlipsContentState();
}

class _WeighingSlipsContentState extends State<WeighingSlipsContent> {
  late final WeighingSlipViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<WeighingSlipViewModel>();
    _viewModel.loadSlips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final userRole = user == null ? null : user.role.toLowerCase();
    final bool isEmployee = userRole == 'employe';
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<WeighingSlipViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gestion des bons de pesée', style: AppTheme.headingLarge),
                const SizedBox(height: 8),
                const Text('Suivi des opérations de pesée', style: AppTheme.subtitleMedium),
                const SizedBox(height: 10),

                // Bouton Nouveau bon
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRouter.slipsCreate),
                  style: AppTheme.industrialPrimaryButton,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nouveau bon'),
                ),
                const SizedBox(height: 12),

                _buildStats(vm),
                const SizedBox(height: 12),

                _buildFilters(vm),
                const SizedBox(height: 12),

                _buildTable(vm, isEmployee),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(WeighingSlipViewModel vm) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard('Bons du jour', vm.todayTotalCount, Icons.today),
        _statCard('Bons avec crédit', vm.todayCreditCount, Icons.credit_card),
        _statCard('Bons payés', vm.todayPaidCount, Icons.payments_outlined),
      ],
    );
  }

  Widget _statCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.industrialPrimary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.industrialText)),
              Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(WeighingSlipViewModel vm) {
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
              hint: 'Rechercher par N° bon, client, matériau...',
              prefixIcon: Icons.search,
            ).copyWith(
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.industrialText),
                      onPressed: () {
                        setState(() { _searchController.clear(); });
                        vm.searchSlips('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
              vm.searchSlips(value);
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<bool?>(
            isExpanded: true,
            value: vm.isFullyPaidFilter,
            items: const [
              DropdownMenuItem(value: null, child: Text('Tous')),
              DropdownMenuItem(value: true, child: Text('Payé')), 
              DropdownMenuItem(value: false, child: Text('Crédit')), 
            ],
            onChanged: vm.filterByFullyPaid,
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<bool?>(
            isExpanded: true,
            value: vm.isInvoicedFilter,
            items: const [
              DropdownMenuItem(value: null, child: Text('Tous')),
              DropdownMenuItem(value: true, child: Text('Facturé')), 
              DropdownMenuItem(value: false, child: Text('Non facturé')), 
            ],
            onChanged: vm.filterByInvoiced,
          ),
        ),
        IconButton(
          onPressed: () {
            _searchController.clear();
            vm.resetFilters();
          },
          icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
          tooltip: 'Réinitialiser',
        ),
      ],
    );
  }

  Widget _buildTable(WeighingSlipViewModel vm, bool isEmployee) {
    final columns = <DataTableColumn<WeighingSlip>>[
      DataTableColumn<WeighingSlip>(label: 'N° Bon', value: (e) => e.slipNumber ?? '-'),
      DataTableColumn<WeighingSlip>(label: 'Client', value: (e) => e.clientName ?? e.clientId.toString()),
      DataTableColumn<WeighingSlip>(label: 'Matériau', value: (e) => e.materialName ?? e.materialId.toString()),
      DataTableColumn<WeighingSlip>(label: 'Tonnes', value: (e) => e.weightTons.toStringAsFixed(1)),
      DataTableColumn<WeighingSlip>(label: 'Montant', value: (e) => e.totalAmount.toStringAsFixed(2)),
      DataTableColumn<WeighingSlip>(label: 'Payé', value: (e) => (e.totalPaid ?? 0).toStringAsFixed(2), hideOnMobile: true),
      DataTableColumn<WeighingSlip>(label: 'Reste', value: (e) => (e.remainingCredit ?? 0).toStringAsFixed(2)),
      DataTableColumn<WeighingSlip>(label: 'Statut', value: (e) => e.isFullyPaid ? 'Payé' : 'Crédit'),
      DataTableColumn<WeighingSlip>(label: 'Date', value: (e) => e.createdAt.toIso8601String().substring(0,10),hideOnMobile: true),
    ];

    return GenericDataTable<WeighingSlip>(
      items: vm.items,
      columns: columns,
      showActions: true,
      showEditAction: !isEmployee,
      showDeleteAction: !isEmployee,
      onEdit: (e) {
        if (!isEmployee) {
          context.go('/weighing-slips/${e.id}/edit', extra: e);
        }
      },
      onDelete: (e) {
        if (!isEmployee) {
          vm.deleteSlip(e.id);
        }
      },
      isLoading: vm.isLoading,
      hasError: vm.hasError,
      errorMessage: vm.errorMessage,
      emptyMessage: 'Aucun bon trouvé',
      total: vm.total,
      currentPage: vm.currentPage,
      totalPages: vm.totalPages,
      onPreviousPage: vm.hasPreviousPage ? vm.previousPage : null,
      onNextPage: vm.hasNextPage ? vm.nextPage : null,
      enableCustomWindow: false,
      showCustomActionButton: true,
      customActionIcon: Icons.info_outline,
      customActionTooltip: 'Voir les détails',
      onCustomAction: (e) {
        context.go('/weighing-slips/${e.id}', extra: e);
      },
    );
  }
}