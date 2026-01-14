import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/entities/invoice.dart';
import '../../models/entities/weighing_slip.dart';
import '../../viewmodels/invoice_viewmodel.dart';
import '../../routes/app_router.dart';

class EditInvoiceView extends StatefulWidget {
  final int invoiceId;
  final Invoice? initialInvoice;

  const EditInvoiceView({
    super.key,
    required this.invoiceId,
    this.initialInvoice,
  });

  @override
  State<EditInvoiceView> createState() => _EditInvoiceViewState();
}

class _EditInvoiceViewState extends State<EditInvoiceView> {
  late final InvoiceViewModel _viewModel;

  Invoice? _invoice;
  bool _isLoading = true;
  bool _isLoadingSlips = false;
  bool _isSaving = false;

  // Bons à ajouter (sélectionnés parmi les non facturés)
  final Set<int> _slipsToAdd = {};
  // Bons à retirer (désélectionnés parmi les existants)
  final Set<int> _slipsToRemove = {};

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<InvoiceViewModel>();
    _invoice = widget.initialInvoice;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Charger les détails de la facture
    final invoice = await _viewModel.loadInvoiceDetails(widget.invoiceId);

    if (mounted && invoice != null) {
      setState(() {
        _invoice = invoice;
        _isLoading = false;
      });

      // Charger les bons non facturés pour le même client
      _loadUninvoicedSlips();
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUninvoicedSlips() async {
    if (_invoice == null) return;

    setState(() {
      _isLoadingSlips = true;
    });

    await _viewModel.loadUninvoicedSlips(clientId: _invoice!.clientId);

    setState(() {
      _isLoadingSlips = false;
    });
  }

  void _toggleAddSlip(int slipId) {
    setState(() {
      if (_slipsToAdd.contains(slipId)) {
        _slipsToAdd.remove(slipId);
      } else {
        _slipsToAdd.add(slipId);
      }
    });
  }

  void _toggleRemoveSlip(int slipId) {
    setState(() {
      if (_slipsToRemove.contains(slipId)) {
        _slipsToRemove.remove(slipId);
      } else {
        // Vérifier qu'on ne retire pas tous les bons
        final currentSlips = _invoice!.weighingSlips ?? [];
        final remainingCount = currentSlips.length - _slipsToRemove.length - 1 + _slipsToAdd.length;
        if (remainingCount >= 1) {
          _slipsToRemove.add(slipId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Une facture doit contenir au moins un bon de pesée'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    });
  }

  bool get _hasChanges => _slipsToAdd.isNotEmpty || _slipsToRemove.isNotEmpty;

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;

    // Confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppColors.industrialPrimary),
            SizedBox(width: 12),
            Text('Confirmer les modifications'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_slipsToAdd.isNotEmpty)
              Text('• ${_slipsToAdd.length} bon(s) à ajouter'),
            if (_slipsToRemove.isNotEmpty)
              Text('• ${_slipsToRemove.length} bon(s) à retirer'),
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
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = await _viewModel.updateInvoice(
        widget.invoiceId,
        addSlipIds: _slipsToAdd.isNotEmpty ? _slipsToAdd.toList() : null,
        removeSlipIds: _slipsToRemove.isNotEmpty ? _slipsToRemove.toList() : null,
      );

      if (mounted) {
        if (updated != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facture modifiée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRouter.invoices);
        } else if (_viewModel.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.errorMessage ?? 'Erreur lors de la modification'),
              backgroundColor: AppColors.errorText,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
        title: Text(
          'Modifier ${_invoice?.invoiceNumber ?? 'la facture'}',
          style: const TextStyle(
            color: AppColors.industrialText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoice == null
              ? _buildNotFound()
              : Column(
                  children: [
                    // Info résumé
                    _buildSummaryHeader(),
                    Expanded(child: _buildSelectionList()),
                    if (_hasChanges) _buildSaveFooter(),
                  ],
                ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Facture non trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRouter.invoices),
            style: AppTheme.industrialPrimaryButton,
            child: const Text('Retour aux factures'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final currentSlips = _invoice!.weighingSlips ?? [];
    final newSlipsCount = currentSlips.length - _slipsToRemove.length + _slipsToAdd.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _invoice!.clientName ?? 'Client #${_invoice!.clientId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$newSlipsCount bon(s) • ${_invoice!.totalAmount.toStringAsFixed(2)} DA',
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Non sauvegardé',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionList() {
    final currentSlips = _invoice!.weighingSlips ?? [];
    final uninvoicedSlips = _viewModel.uninvoicedSlips;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          title: 'Bons déjà dans la facture',
          subtitle: '${currentSlips.length - _slipsToRemove.length} sélectionné(s)',
        ),
        if (currentSlips.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Aucun bon pour cette facture',
              style: TextStyle(color: AppColors.grey500),
            ),
          )
        else
          ...currentSlips.map((slip) {
            final isSelected = !_slipsToRemove.contains(slip.id);
            return _buildCurrentSlipTile(slip, isSelected);
          }),

        const SizedBox(height: 16),
        _buildSectionHeader(
          title: 'Autres bons disponibles',
          subtitle: _isLoadingSlips
              ? 'Chargement...'
              : '${uninvoicedSlips.length} disponible(s)',
        ),
        if (_isLoadingSlips)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (uninvoicedSlips.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Aucun autre bon non facturé',
              style: TextStyle(color: AppColors.grey500),
            ),
          )
        else
          ...uninvoicedSlips.map((slip) {
            final isSelected = _slipsToAdd.contains(slip.id);
            return _buildAvailableSlipTile(slip, isSelected);
          }),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSlipTile(InvoiceWeighingSlip slip, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.errorText,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleRemoveSlip(slip.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleRemoveSlip(slip.id),
                activeColor: AppColors.industrialPrimary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          slip.slipNumber ?? 'Bon #${slip.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration:
                                isSelected ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slip.materialName ?? 'Matériau'} • ${slip.weightTons.toStringAsFixed(2)} T',
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${slip.totalAmount.toStringAsFixed(2)} DA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration:
                          isSelected ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSlipTile(WeighingSlip slip, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.success : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleAddSlip(slip.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleAddSlip(slip.id),
                activeColor: AppColors.success,
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
                    Text(
                      '${slip.materialName ?? 'Matériau #${slip.materialId}'} • ${slip.weightTons.toStringAsFixed(2)} T',
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slip.createdAt.toIso8601String().substring(0, 10),
                      style: const TextStyle(
                        color: AppColors.grey500,
                        fontSize: 12,
                      ),
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

  Widget _buildSaveFooter() {
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
                    'Modifications en attente',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      if (_slipsToAdd.isNotEmpty)
                        Text(
                          '+${_slipsToAdd.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      if (_slipsToAdd.isNotEmpty && _slipsToRemove.isNotEmpty)
                        const Text(' / '),
                      if (_slipsToRemove.isNotEmpty)
                        Text(
                          '-${_slipsToRemove.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.errorText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _slipsToAdd.clear();
                  _slipsToRemove.clear();
                });
              },
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              width: 170,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                style: AppTheme.industrialPrimaryButton,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
