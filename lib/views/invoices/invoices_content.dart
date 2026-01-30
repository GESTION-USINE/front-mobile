import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/invoice_viewmodel.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../widgets/generic_data_table.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_router.dart';
import '../../models/entities/invoice.dart';
import '../../models/entities/client.dart';

/// Contenu de la gestion des factures (sans wrapper MainLayout)
class InvoicesContent extends StatefulWidget {
  const InvoicesContent({super.key});

  @override
  State<InvoicesContent> createState() => _InvoicesContentState();
}

class _InvoicesContentState extends State<InvoicesContent> {
  late final InvoiceViewModel _viewModel;
  late final ClientViewModel _clientViewModel;
  final _searchController = TextEditingController();

  List<Client> _clients = [];
  int? _selectedClientId;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<InvoiceViewModel>();
    _clientViewModel = getIt<ClientViewModel>();
    // Charger les factures en utilisant le cache si disponible
    _viewModel.loadInvoices();
    _loadClients();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientViewModel.getAllActiveClients();
      setState(() {
        _clients = clients;
      });
    } catch (e) {
      // Ignorer les erreurs de chargement des clients
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final userRole = user == null ? null : user.role.toLowerCase();
    final bool canCreate = userRole == 'super_admin' || userRole == 'associe' || (user?.canModifyInvoices ?? false);
    final bool canDelete = userRole == 'super_admin' || userRole == 'associe' || (user?.canModifyInvoices ?? false);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<InvoiceViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(vm, canCreate),
                const SizedBox(height: 12),
                _buildStats(vm),
                const SizedBox(height: 12),
                _buildTotalAmounts(vm),
                const SizedBox(height: 12),
                _buildTable(vm, canCreate, canDelete),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(InvoiceViewModel vm) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard('Total factures :', vm.items.length, Icons.receipt_long),
        _statCard('Factures payées :', vm.fullyPaidInvoicesCount, Icons.check_circle_outline),
        _statCard('Factures en cours :', vm.pendingInvoicesCount, Icons.pending_outlined),
      ],
    );
  }

  Widget _buildTotalAmounts(InvoiceViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          _amountInfo('Montant total :', vm.totalAmount, AppColors.industrialPrimary),
          _amountInfo('Total payé :', vm.totalPaidAmount, AppColors.success),
          _amountInfo('Reste à payer :', vm.totalRemainingCredit, AppColors.errorText),
        ],
      ),
    );
  }

  Widget _amountInfo(String label, double amount, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.industrialText,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${amount.toStringAsFixed(2)} DA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.industrialText,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(InvoiceViewModel vm, bool canCreate) {
    final Widget addButton = canCreate
        ? SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRouter.invoicesCreate),
              style: AppTheme.industrialPrimaryButton.copyWith(
                minimumSize: WidgetStateProperty.all(const Size(130, 44)),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nouvelle facture'),
            ),
          )
        : const SizedBox.shrink();

    final List<Widget> filters = [
      // Recherche
      SizedBox(
        width: 230,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.industrialText),
          decoration: AppTheme.industrialInputDecoration(
            hint: 'Rechercher par N° facture, client...',
            prefixIcon: Icons.search,
          ).copyWith(
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.industrialText),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                      vm.searchInvoices('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            vm.searchInvoices(value);
          },
        ),
      ),
      // Filtre par client
      SizedBox(
        width: 200,
        child: DropdownButtonFormField<int?>(
          isExpanded: true,
          value: _selectedClientId,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            hintText: 'Tous les clients',
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tous les clients'),
            ),
            ..._clients.map((client) => DropdownMenuItem<int>(
                  value: client.id,
                  child: Text(
                    client.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedClientId = value;
            });
            vm.filterByClient(value);
          },
        ),
      ),
      // Date filter
      SizedBox(
        width: 130,
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
                    vm.dateFromFilter ?? 'Date',
                    style: const TextStyle(fontSize: 14, color: AppColors.industrialText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Bouton refresh
      IconButton(
        onPressed: () {
          _searchController.clear();
          setState(() {
            _selectedClientId = null;
          });
          vm.refresh();
        },
        iconSize: 25,
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

  Widget _buildTable(InvoiceViewModel vm, bool canEdit, bool canDelete) {
    final columns = <DataTableColumn<Invoice>>[
      DataTableColumn<Invoice>(
        label: 'N° Facture',
        value: (e) => e.invoiceNumber,
      ),
      DataTableColumn<Invoice>(
        label: 'Client',
        value: (e) => e.clientName ?? 'Client #${e.clientId}',
      ),
      DataTableColumn<Invoice>(
        label: 'Montant',
        value: (e) => '${e.totalAmount.toStringAsFixed(2)} DA',
      ),
      DataTableColumn<Invoice>(
        label: 'Payé',
        value: (e) => '${e.totalPaid.toStringAsFixed(2)} DA',
        hideOnMobile: true,
      ),
      DataTableColumn<Invoice>(
        label: 'Reste',
        isWidget: true,
        value: (e) => Text(
          '${e.remainingCredit.toStringAsFixed(2)} DA',
          style: TextStyle(
            color: e.remainingCredit > 0 ? AppColors.errorText : AppColors.success,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      DataTableColumn<Invoice>(
        label: 'Bons',
        value: (e) => '${e.weighingSlipsCount}',
      ),
      DataTableColumn<Invoice>(
        label: 'Statut',
        isWidget: true,
        value: (e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: e.isFullyPaid
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            e.isFullyPaid ? 'Payée' : 'En cours',
            style: TextStyle(
              color: e.isFullyPaid ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
      DataTableColumn<Invoice>(
        label: 'Date',
        value: (e) => e.createdAt.toIso8601String().substring(0, 10),
        hideOnMobile: true,
      ),
    ];

    return GenericDataTable<Invoice>(
      items: vm.items,
      columns: columns,
      showActions: true,
      showEditAction: canEdit,
      showDeleteAction: canDelete,
      onEdit: (e) {
        if (canEdit) {
          context.go('/invoices/${e.id}/edit', extra: e);
        }
      },
      onDelete: (e) => _confirmDelete(context, vm, e),
      isLoading: vm.isLoading,
      hasError: false,
      errorMessage: null,
      emptyMessage: 'Aucune facture trouvée',
      total: vm.total,
      currentPage: vm.currentPage,
      totalPages: vm.totalPages,
      onPreviousPage: vm.hasPreviousPage ? vm.previousPage : null,
      onNextPage: vm.hasNextPage ? vm.nextPage : null,
      enableCustomWindow: false,
      showCustomActionButton: true,
      customActionIcon: Icons.visibility_outlined,
      customActionTooltip: 'Voir les détails',
      onCustomAction: (e) {
        context.go('/invoices/${e.id}', extra: e);
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, InvoiceViewModel vm, Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la facture ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('N° ${invoice.invoiceNumber}'),
            const SizedBox(height: 8),
            Text('Client : ${invoice.clientName ?? 'Client #${invoice.clientId}'}'),
            const SizedBox(height: 8),
            Text('Bons détachés : ${invoice.weighingSlipsCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorText),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await vm.deleteInvoice(invoice.id);

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Facture supprimée et bons détachés'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Suppression impossible'),
          backgroundColor: AppColors.errorText,
        ),
      );
    }
  }
}
