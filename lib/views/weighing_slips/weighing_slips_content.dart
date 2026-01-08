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
    _searchController.addListener(() {
      setState(() {});
    });
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
                _buildFilters(vm),
                const SizedBox(height: 12),

                     _buildStats(vm),
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
        _statCard('Bons du jour :', vm.todayTotalCount, Icons.today),
        _statCard('Bons avec crédit :', vm.todayCreditCount, Icons.credit_card),
        _statCard('Bons payés :', vm.todayPaidCount, Icons.payments_outlined),
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ,color: AppColors.industrialText)),
          const SizedBox(width: 16),
           Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilters(WeighingSlipViewModel vm) {
    final Widget addButton = SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRouter.slipsCreate),
        style: AppTheme.industrialPrimaryButton.copyWith(
          minimumSize: MaterialStateProperty.all(const Size(170, 44)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Nouveau bon'),
      ),
    );

    final List<Widget> filters = [
      // Recherche
      SizedBox(
        width: 280,
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
      // Date filter
      SizedBox(
        width: 140,
        child: GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: vm.dateFromFilter != null 
                  ? DateTime.parse(vm.dateFromFilter!) 
                  : DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              final dateStr = picked.toIso8601String().substring(0, 10);
              vm.filterByDateRange(dateStr, dateStr);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.grey600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.dateFromFilter ?? DateTime.now().toIso8601String().substring(0, 10),
                    style: const TextStyle(fontSize: 14, color: AppColors.industrialText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(
        width: 140,
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