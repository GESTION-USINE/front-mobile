import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/entities/client.dart';
import '../../models/entities/weighing_slip.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../viewmodels/invoice_viewmodel.dart';
import '../../routes/app_router.dart';

class CreateInvoiceView extends StatefulWidget {
  const CreateInvoiceView({super.key});

  @override
  State<CreateInvoiceView> createState() => _CreateInvoiceViewState();
}

class _CreateInvoiceViewState extends State<CreateInvoiceView> {
  late final InvoiceViewModel _invoiceViewModel;
  late final ClientViewModel _clientViewModel;

  List<Client> _clients = [];
  int? _selectedClientId;
  bool _isLoadingClients = true;
  bool _isLoadingSlips = false;
  bool _isCreating = false;

  // Bons sélectionnés pour la facture
  final Set<int> _selectedSlipIds = {};

  @override
  void initState() {
    super.initState();
    _invoiceViewModel = getIt<InvoiceViewModel>();
    _clientViewModel = getIt<ClientViewModel>();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientViewModel.getAllActiveClients();
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingClients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des clients: $e'),
            backgroundColor: AppColors.errorText,
          ),
        );
      }
    }
  }

  Future<void> _loadUninvoicedSlips(int clientId) async {
    setState(() {
      _isLoadingSlips = true;
      _selectedSlipIds.clear();
    });

    await _invoiceViewModel.loadUninvoicedSlips(clientId: clientId);

    setState(() {
      _isLoadingSlips = false;
    });
  }

  void _toggleSlipSelection(int slipId) {
    setState(() {
      if (_selectedSlipIds.contains(slipId)) {
        _selectedSlipIds.remove(slipId);
      } else {
        _selectedSlipIds.add(slipId);
      }
    });
  }

  void _selectAllSlips() {
    setState(() {
      if (_selectedSlipIds.length == _invoiceViewModel.uninvoicedSlips.length) {
        _selectedSlipIds.clear();
      } else {
        _selectedSlipIds.clear();
        _selectedSlipIds.addAll(_invoiceViewModel.uninvoicedSlips.map((s) => s.id));
      }
    });
  }

  double get _selectedTotal {
    return _invoiceViewModel.uninvoicedSlips
        .where((s) => _selectedSlipIds.contains(s.id))
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  Future<void> _createInvoice() async {
    if (_selectedSlipIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un bon de pesée'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.industrialPrimary),
            SizedBox(width: 12),
            Text('Confirmer la création'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Créer une facture avec ${_selectedSlipIds.length} bon(s) de pesée ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.industrialPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Montant total :',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_selectedTotal.toStringAsFixed(2)} DA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.industrialPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: AppTheme.industrialPrimaryButton,
            child: const Text('Créer la facture'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final invoice = await _invoiceViewModel.createInvoice(_selectedSlipIds.toList());

      if (mounted) {
        if (invoice != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Facture ${invoice.invoiceNumber} créée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRouter.invoices);
        } else if (_invoiceViewModel.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_invoiceViewModel.errorMessage ?? 'Erreur lors de la création'),
              backgroundColor: AppColors.errorText,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.industrialBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.industrialText),
          onPressed: () => context.go(AppRouter.invoices),
        ),
        title: const Text(
          'Nouvelle facture',
          style: TextStyle(
            color: AppColors.industrialText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedSlipIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.industrialPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedSlipIds.length} sélectionné(s)',
                    style: const TextStyle(
                      color: AppColors.industrialPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: _invoiceViewModel,
        child: Consumer<InvoiceViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                // Sélection du client
                _buildClientSelector(),
                
                // Liste des bons non facturés
                Expanded(
                  child: _buildSlipsList(vm),
                ),

                // Footer avec le total et le bouton de création
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildClientSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionner un client',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.industrialText,
            ),
          ),
          const SizedBox(height: 12),
          _isLoadingClients
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  value: _selectedClientId,
                  decoration: AppTheme.industrialInputDecoration(
                    hint: 'Choisir un client',
                    prefixIcon: Icons.person_outline,
                  ),
                  items: _clients.map((client) {
                    return DropdownMenuItem<int>(
                      value: client.id,
                      child: Text(
                        '${client.name} (${client.phone})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedClientId = value;
                      });
                      _loadUninvoicedSlips(value);
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSlipsList(InvoiceViewModel vm) {
    if (_selectedClientId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sélectionnez un client pour voir ses bons non facturés',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isLoadingSlips || vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.uninvoicedSlips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun bon non facturé pour ce client',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header avec sélection tout
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.grey100,
          child: Row(
            children: [
              Checkbox(
                value: _selectedSlipIds.length == vm.uninvoicedSlips.length &&
                    vm.uninvoicedSlips.isNotEmpty,
                tristate: _selectedSlipIds.isNotEmpty &&
                    _selectedSlipIds.length < vm.uninvoicedSlips.length,
                onChanged: (_) => _selectAllSlips(),
                activeColor: AppColors.industrialPrimary,
              ),
              const Text(
                'Sélectionner tout',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.industrialText,
                ),
              ),
              const Spacer(),
              Text(
                '${vm.uninvoicedSlips.length} bon(s) disponible(s)',
                style: const TextStyle(
                  color: AppColors.grey600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.uninvoicedSlips.length,
            itemBuilder: (context, index) {
              final slip = vm.uninvoicedSlips[index];
              final isSelected = _selectedSlipIds.contains(slip.id);
              return _buildSlipCard(slip, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlipCard(WeighingSlip slip, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.industrialPrimary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSlipSelection(slip.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSlipSelection(slip.id),
                activeColor: AppColors.industrialPrimary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          slip.slipNumber ?? 'Bon #${slip.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${slip.totalAmount.toStringAsFixed(2)} DA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.scale, size: 14, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(
                          slip.materialName ?? 'Matériau #${slip.materialId}',
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${slip.weightTons.toStringAsFixed(2)} T',
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(
                          slip.createdAt.toIso8601String().substring(0, 10),
                          style: const TextStyle(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: slip.isFullyPaid
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            slip.isFullyPaid ? 'Payé' : 'Crédit',
                            style: TextStyle(
                              color: slip.isFullyPaid
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total sélectionné',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${_selectedTotal.toStringAsFixed(2)} DA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.industrialPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ElevatedButton.icon(
                onPressed: _selectedSlipIds.isEmpty || _isCreating
                    ? null
                    : _createInvoice,
                style: AppTheme.industrialPrimaryButton,
                icon: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(_isCreating ? 'Création...' : 'Créer la facture'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
