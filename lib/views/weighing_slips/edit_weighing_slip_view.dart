import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/entities/client.dart';
import '../../models/entities/material.dart' as mat;
import '../../models/entities/weighing_slip.dart';
import '../../models/request/update_weighing_slip_request.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../viewmodels/material_viewmodel.dart';
import '../../viewmodels/weighing_slip_viewmodel.dart';

class EditWeighingSlipView extends StatefulWidget {
  final int slipId;
  final WeighingSlip initialSlip;

  const EditWeighingSlipView({
    super.key,
    required this.slipId,
    required this.initialSlip,
  });

  @override
  State<EditWeighingSlipView> createState() => _EditWeighingSlipViewState();
}

class _EditWeighingSlipViewState extends State<EditWeighingSlipView> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  late final WeighingSlipViewModel _slipViewModel;
  late final ClientViewModel _clientViewModel;
  late final MaterialViewModel _materialViewModel;

  int? _selectedClientId;
  int? _selectedMaterialId;
  List<Client> _clients = [];
  List<mat.Material> _materials = [];
  bool _isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _slipViewModel = getIt<WeighingSlipViewModel>();
    _clientViewModel = getIt<ClientViewModel>();
    _materialViewModel = getIt<MaterialViewModel>();

    _selectedClientId = widget.initialSlip.clientId;
    _selectedMaterialId = widget.initialSlip.materialId;
    _weightController.text = widget.initialSlip.weightTons.toStringAsFixed(3);

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final clients = await _clientViewModel.getAllActiveClients();
      await _materialViewModel.loadMaterials();
      setState(() {
        _clients = clients;
        _materials = _materialViewModel.materials.where((m) => m.isActive).toList();
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      setState(() { _isLoadingDropdowns = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement données: $e')),
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double? _calculateTotalAmount() {
    if (_selectedMaterialId == null || _weightController.text.isEmpty) return null;
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) return null;
    final material = _materials.firstWhere((m) => m.id == _selectedMaterialId, orElse: () => _materials.first);
    final pricePerTon = material.defaultPricePerTon; // Le serveur appliquera le prix personnalisé si besoin
    return weight * pricePerTon;
  }

  Future<void> _updateSlip() async {
    if (!_formKey.currentState!.validate()) return;

    final req = UpdateWeighingSlipRequest(
      clientId: _selectedClientId,
      materialId: _selectedMaterialId,
      weightTons: double.parse(_weightController.text),
    );

    final ok = await _slipViewModel.updateSlip(widget.slipId, req);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bon de pesée mis à jour'), backgroundColor: AppColors.success),
      );
      context.go('/weighing-slips');
    } else if (!ok && mounted && _slipViewModel.hasError) {
      // Check for specific error code
      final errorMsg = _slipViewModel.errorMessage ?? '';
      if (errorMsg.contains('AMOUNT_LESS_THAN_PAID') || 
          errorMsg.contains('inférieur au montant déjà payé')) {
        _showAmountLessThanPaidDialog();
      } else {
        _showErrorDialog(errorMsg);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppColors.errorText, size: 28),
            SizedBox(width: 12),
            Text('Erreur'),
          ],
        ),
        content: Text(
          message.isNotEmpty ? message : 'Une erreur est survenue lors de la mise à jour',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAmountLessThanPaidDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Text('Modification impossible'),
          ],
        ),
        content: const Text(
          'Le nouveau montant ne peut pas être inférieur au montant déjà payé pour ce bon de pesée.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _slipViewModel,
      child: Scaffold(
        backgroundColor: AppColors.industrialBackground,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.industrialPrimary),
            onPressed: () => context.go('/weighing-slips'),
          ),
          title: Text(
            'Modifier bon ${widget.initialSlip.slipNumber}',
            style: const TextStyle(
              color: AppColors.industrialPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoadingDropdowns
            ? const Center(child: CircularProgressIndicator())
            : Consumer<WeighingSlipViewModel>(
                builder: (context, vm, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          boxShadow: const [
                            BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Informations du bon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),

                              _buildClientAutocomplete(),
                              const SizedBox(height: 16),
                              _buildMaterialDropdown(),
                              const SizedBox(height: 16),
                              _buildWeightField(),
                              const SizedBox(height: 16),
                              _buildTotalAmountDisplay(),
                              const SizedBox(height: 32),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    OutlinedButton(
                                      onPressed: vm.isLoading ? null : () => context.go('/weighing-slips'),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: vm.isLoading ? null : _updateSlip,
                                      style: AppTheme.industrialPrimaryButton,
                                      icon: vm.isLoading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Icon(Icons.save),
                                      label: Text(vm.isLoading ? 'Modification...' : 'Mettre à jour'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildClientAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Client *', style: AppTheme.fieldLabel),
        const SizedBox(height: 8),
        Autocomplete<Client>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) return _clients;
            return _clients.where((c) {
              final q = textEditingValue.text.toLowerCase();
              return c.name.toLowerCase().contains(q) || c.phone.contains(textEditingValue.text);
            });
          },
          displayStringForOption: (Client c) => '${c.name} - ${c.phone}',
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            if (_selectedClientId != null) {
              final c = _clients.firstWhere((e) => e.id == _selectedClientId, orElse: () => _clients.first);
              textController.text = '${c.name} - ${c.phone}';
            }
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              style: const TextStyle(color: AppColors.industrialText),
              decoration: AppTheme.industrialInputDecoration(
                hint: 'Sélectionner ou rechercher un client',
                prefixIcon: Icons.person,
              ).copyWith(
                suffixIcon: _selectedClientId != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.industrialText),
                        onPressed: () {
                          setState(() { _selectedClientId = null; textController.clear(); });
                        },
                      )
                    : null,
              ),
              validator: (value) {
                if (_selectedClientId == null) return 'Veuillez sélectionner un client';
                return null;
              },
            );
          },
          onSelected: (Client c) { setState(() { _selectedClientId = c.id; }); },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  width: MediaQuery.of(context).size.width - 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.3)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final c = options.elementAt(index);
                      return InkWell(
                        onTap: () { onSelected(c); },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.industrialText)),
                              const SizedBox(height: 4),
                              Text(c.phone, style: TextStyle(fontSize: 14, color: AppColors.industrialText.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMaterialDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMaterialId,
      isExpanded: true,
      decoration: AppTheme.industrialInputDecoration(
        hint: 'Sélectionner un matériau',
        prefixIcon: Icons.category,
      ),
      items: _materials.map((m) => DropdownMenuItem<int>(value: m.id, child: Text('${m.name}'))).toList(),
      onChanged: (value) { setState(() { _selectedMaterialId = value; }); },
      validator: (value) { if (value == null) return 'Veuillez sélectionner un matériau'; return null; },
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}'))],
      style: const TextStyle(color: AppColors.industrialText),
      decoration: AppTheme.industrialInputDecoration(
        hint: 'Poids (tonnes) - Ex: 25.5',
        prefixIcon: Icons.scale,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez entrer le poids';
        final w = double.tryParse(value);
        if (w == null || w <= 0) return 'Veuillez entrer un poids valide';
        return null;
      },
      onChanged: (_) { setState(() {}); },
    );
  }

  Widget _buildTotalAmountDisplay() {
    final total = _calculateTotalAmount();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.industrialPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, color: AppColors.industrialPrimary),
              SizedBox(width: 8),
              Text('Montant Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.industrialText)),
            ],
          ),
          Text(
            total == null ? '-' : '${total.toStringAsFixed(2)} DZD',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.industrialPrimary),
          ),
        ],
      ),
    );
  }
}
