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
import '../../models/request/create_weighing_slip_request.dart';
import '../../services/weighing_slip_service.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../viewmodels/material_viewmodel.dart';
import '../../viewmodels/weighing_slip_viewmodel.dart';

class CreateWeighingSlipView extends StatefulWidget {
  const CreateWeighingSlipView({super.key});

  @override
  State<CreateWeighingSlipView> createState() => _CreateWeighingSlipViewState();
}

class _CreateWeighingSlipViewState extends State<CreateWeighingSlipView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _emptyWeightController;
  TextEditingController? _fullWeightController;
  TextEditingController? _paymentAmountController;
  TextEditingController? _checkNumberController;
  TextEditingController? _checkBankController;
  TextEditingController? _notesController;

  late final WeighingSlipViewModel _slipViewModel;
  late final ClientViewModel _clientViewModel;
  late final MaterialViewModel _materialViewModel;
  late final WeighingSlipService _slipService;

  int? _selectedClientId;
  int? _selectedMaterialId;
  bool _includePayment = false;
  String _paymentType = 'cash';
  DateTime _paymentDate = DateTime.now();
  DateTime? _checkDate;
  String _checkStatus = 'cleared';

  List<Client> _clients = [];
  List<mat.Material> _materials = [];
  bool _isLoadingDropdowns = true;
  
  // État du flux de création
  WeighingSlip? _createdSlip; // Bon créé avec montant total
  bool _isCreatingSlip = false;
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  FocusNode? _checkNumberFocusNode;
  FocusNode? _checkBankFocusNode;

  @override
  void initState() {
    super.initState();
    _emptyWeightController = TextEditingController();
    _fullWeightController = TextEditingController();
    _paymentAmountController = TextEditingController();
    _checkNumberController = TextEditingController();
    _checkBankController = TextEditingController();
    _notesController = TextEditingController();
    _checkNumberFocusNode = FocusNode();
    _checkBankFocusNode = FocusNode();
    
    _slipViewModel = getIt<WeighingSlipViewModel>();
    _clientViewModel = getIt<ClientViewModel>();
    _materialViewModel = getIt<MaterialViewModel>();
    _slipService = getIt<WeighingSlipService>();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      // Load all active clients without pagination
      final clients = await _clientViewModel.getAllActiveClients();
      
      // Load all active materials
      await _materialViewModel.loadMaterials();
      
      setState(() {
        _clients = clients;
        _materials = _materialViewModel.materials.where((m) => m.isActive).toList();
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDropdowns = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emptyWeightController?.dispose();
    _fullWeightController?.dispose();
    _paymentAmountController?.dispose();
    _checkNumberController?.dispose();
    _checkBankController?.dispose();
    _notesController?.dispose();
    _checkNumberFocusNode?.dispose();
    _checkBankFocusNode?.dispose();
    super.dispose();
  }

  /// Affiche un popup de confirmation avant de créer le bon
  Future<void> _createSlip() async {
    if (!_formKey.currentState!.validate()) return;

    final emptyWeight = double.parse(_emptyWeightController!.text);
    final fullWeight = double.parse(_fullWeightController!.text);
    final netWeight = fullWeight - emptyWeight;

    if (netWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le poids complet doit être supérieur au poids vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Récupérer les infos du client et matériau sélectionnés
    final selectedClient = _clients.firstWhere(
      (c) => c.id == _selectedClientId,
      orElse: () => _clients.first,
    );
    final selectedMaterial = _materials.firstWhere(
      (m) => m.id == _selectedMaterialId,
      orElse: () => _materials.first,
    );

    // Charger les prix spéciaux du client pour ce matériau
    await _materialViewModel.loadClientMaterialPrices(clientId: _selectedClientId!);
    
    // Trouver le prix spécial du client pour ce matériau
    final clientMaterialPrices = _materialViewModel.materialPrices
        .where((p) => p.materialId == _selectedMaterialId)
        .toList();
    
    final specialPrice = clientMaterialPrices.isNotEmpty 
        ? (clientMaterialPrices.first.customPricePerTon ?? clientMaterialPrices.first.defaultPricePerTon)
        : selectedMaterial.defaultPricePerTon;
    
    // Calculer le montant estimé avec le prix spécial
    final estimatedAmount = netWeight * specialPrice;

    // Afficher le popup de confirmation
    _showCreateConfirmationDialog(
      selectedClient,
      selectedMaterial,
      netWeight,
      estimatedAmount,
      specialPrice,
      selectedMaterial.defaultPricePerTon,
    );
  }

  /// Affiche un popup avec les infos du bon à créer
  void _showCreateConfirmationDialog(
    Client client,
    mat.Material material,
    double netWeight,
    double estimatedAmount,
    double specialPrice,
    double defaultPrice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la création du bon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.industrialPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.industrialPrimary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationRow('Client:', client.name),
                  const SizedBox(height: 12),
                  _buildConfirmationRow('Téléphone:', client.phone),
                  const SizedBox(height: 12),
                  _buildConfirmationRow('Matériau:', material.name),
                  const SizedBox(height: 12),
                  // Afficher les prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prix/Tonne:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.industrialText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (specialPrice != defaultPrice) ...[
                            Text(
                              '${specialPrice.toStringAsFixed(2)} DZD',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.industrialPrimary,
                              ),
                            ),
                            Text(
                              '(défaut: ${defaultPrice.toStringAsFixed(2)} DZD)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey600,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ] else
                            Text(
                              '${defaultPrice.toStringAsFixed(2)} DZD',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.industrialText,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildConfirmationRow(
                    'Poids vide:',
                    '${_emptyWeightController!.text} T',
                    isGrey: true,
                  ),
                  const SizedBox(height: 8),
                  _buildConfirmationRow(
                    'Poids complet:',
                    '${_fullWeightController!.text} T',
                    isGrey: true,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.industrialPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Poids net:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${netWeight.toStringAsFixed(3)} T',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Montant total:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${estimatedAmount.toStringAsFixed(2)} DZD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.industrialPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.industrialPrimary,
            ),
            onPressed: () {
              Navigator.pop(context);
              _submitCreateSlip();
            },
            child: const Text(
              'Confirmer et créer',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper pour afficher une ligne de confirmation
  Widget _buildConfirmationRow(
    String label,
    String value, {
    bool isGrey = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isGrey ? AppColors.grey600 : AppColors.industrialText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isGrey ? AppColors.grey700 : AppColors.industrialText,
          ),
        ),
      ],
    );
  }

  /// Crée le bon de pesée SANS paiement (après confirmation)
  Future<void> _submitCreateSlip() async {
    setState(() => _isCreatingSlip = true);

    try {
      final emptyWeight = double.parse(_emptyWeightController!.text);
      final fullWeight = double.parse(_fullWeightController!.text);
      final netWeight = fullWeight - emptyWeight;

      final request = CreateWeighingSlipRequest(
        clientId: _selectedClientId!,
        materialId: _selectedMaterialId!,
        weightTons: netWeight,
      );

      final slip = await _slipService.createSlip(request);
      
      setState(() {
        _createdSlip = slip;
        _isCreatingSlip = false;
        // Remplir automatiquement le montant payé avec le montant total
        _paymentAmountController?.text = slip.totalAmount.toStringAsFixed(2);
      });

      // Afficher le montant total
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bon créé! Montant total: ${slip.totalAmount} DZD'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isCreatingSlip = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitPayment(double amount) async {
    setState(() => _isCreatingSlip = true);

    try {
      final paymentRequest = CreatePaymentRequest(
        weighingSlipId: _createdSlip!.id,
        paymentType: _paymentType,
        amountPaid: amount,
        paymentDate: _paymentDate.toIso8601String().substring(0, 10),
        checkNumber: _paymentType != 'cash' ? _checkNumberController?.text : null,
        checkDate: _paymentType != 'cash'
            ? (_checkDate ?? DateTime.now()).toIso8601String().substring(0, 10)
            : null,
        checkBank: _paymentType != 'cash' ? _checkBankController?.text : null,
        checkStatus: _paymentType != 'cash' ? _checkStatus : null,
        notes: (_notesController?.text.isNotEmpty ?? false) ? _notesController?.text : null,
      );

      await _slipService.createPayment(paymentRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement enregistré avec succès')),
        );
        context.go('/weighing-slips');
      }
    } catch (e) {
      setState(() => _isCreatingSlip = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur paiement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Crée un paiement pour le bon existant
  Future<void> _createPayment() async {
    if (_createdSlip == null) return;

    final amount = double.tryParse(_paymentAmountController?.text ?? '');
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    if (amount > _createdSlip!.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant dépasse le total')),
      );
      return;
    }

    // Valider le formulaire de paiement et focaliser le premier champ invalide
    if (_paymentType != 'cash') {
      final valid = _paymentFormKey.currentState?.validate() ?? true;
      if (!valid) {
        final checkNumber = _checkNumberController?.text ?? '';
        final bank = _checkBankController?.text ?? '';
        
        if (checkNumber.isEmpty || checkNumber.length != 20) {
          _checkNumberFocusNode?.requestFocus();
        } else if (bank.isEmpty) {
          _checkBankFocusNode?.requestFocus();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Afficher popup de confirmation
    _showPaymentConfirmationDialog(amount);
  }

  /// Affiche un popup avec les infos du paiement
  void _showPaymentConfirmationDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.industrialPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.industrialPrimary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Numéro du bon
                  Row(
                    children: [
                      const Icon(Icons.receipt, size: 20, color: AppColors.industrialPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Numéro du bon:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              _createdSlip!.slipNumber ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.industrialText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Montant total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Montant total:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.industrialText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_createdSlip!.totalAmount.toStringAsFixed(2)} DZD',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.industrialPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Montant payé
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.industrialPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Montant payé:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialText,
                          ),
                        ),
                        Text(
                          '${amount.toStringAsFixed(2)} DZD',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reste
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reste:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.industrialText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(_createdSlip!.totalAmount - amount).toStringAsFixed(2)} DZD',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (_createdSlip!.totalAmount - amount) > 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Type de paiement
                  Row(
                    children: [
                      const Icon(Icons.payment, size: 20, color: AppColors.industrialText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Type de paiement:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              _paymentType == 'cash'
                                  ? 'Espèces'
                                  : _paymentType == 'check'
                                      ? 'Chèque'
                                      : 'Chèque de garantie',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.industrialText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Date de paiement
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.industrialText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date de paiement:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                            Text(
                              _paymentDate.toIso8601String().substring(0, 10),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.industrialText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Détails du chèque si applicable
                  if (_paymentType != 'cash') ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        const Icon(Icons.numbers, size: 20, color: AppColors.industrialText),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Numéro de chèque:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                              Text(
                                _checkNumberController?.text ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.industrialText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if ((_checkBankController?.text.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.account_balance, size: 20, color: AppColors.industrialText),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Banque:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey600,
                                  ),
                                ),
                                Text(
                                  _checkBankController?.text ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.industrialText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  
                  // Notes si présentes
                  if ((_notesController?.text.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 20, color: AppColors.industrialText),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                              Text(
                                _notesController?.text ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.industrialText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.industrialPrimary,
            ),
            onPressed: () {
              Navigator.pop(context);
              _submitPayment(amount);
            },
            child: const Text(
              'Confirmer',
              style: TextStyle(color: AppColors.white),
            ),
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
            _createdSlip == null ? 'Nouveau bon de pesée' : 'Paiement du bon',
            style: const TextStyle(
              color: AppColors.industrialPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoadingDropdowns
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<WeighingSlipViewModel>(
                builder: (context, viewModel, child) {
                  // Si le bon n'est pas créé, afficher le formulaire de création
                  if (_createdSlip == null) {
                    return _buildCreateSlipForm();
                  }
                  // Si le bon est créé, afficher le formulaire de paiement
                  return _buildPaymentForm();
                },
              ),
      ),
    );
  }

  /// Formulaire de création du bon (étape 1)
  Widget _buildCreateSlipForm() {
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
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations du bon',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _buildClientAutocomplete(),
                const SizedBox(height: 16),

                _buildMaterialDropdown(),
                const SizedBox(height: 16),

                _buildWeightField(),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/weighing-slips'),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _isCreatingSlip ? null : _createSlip,
                        style: AppTheme.industrialPrimaryButton,
                        icon: _isCreatingSlip
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.add),
                        label: Text(_isCreatingSlip
                            ? 'Création...'
                            : 'Créer le bon'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formulaire de paiement (étape 2)
  Widget _buildPaymentForm() {
    // Récupérer les noms depuis les listes locales
    final selectedClient = _clients.firstWhere(
      (c) => c.id == _selectedClientId,
      orElse: () => _clients.first,
    );
    final selectedMaterial = _materials.firstWhere(
      (m) => m.id == _selectedMaterialId,
      orElse: () => _materials.first,
    );
    
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
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter un paiement (optionnel)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Affichage du bon créé avec infos détaillées
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.industrialPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bon: ${_createdSlip!.slipNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.industrialPrimary,
                        )),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Informations du client
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person, size: 20, color: AppColors.industrialText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Client:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(selectedClient.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Informations du matériau
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.category, size: 20, color: AppColors.industrialText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Matériau:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(selectedMaterial.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Informations du poids
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.scale, size: 20, color: AppColors.industrialText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Poids:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('${_createdSlip!.weightTons} tonnes',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('${_createdSlip!.totalAmount} DZD',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.industrialPrimary,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              Form(
                key: _paymentFormKey,
                child: _buildPaymentSection(),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.go('/weighing-slips'),
                    child: const Text('Terminer'),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _includePayment ? _createPayment : () => context.go('/weighing-slips'),
                      style: AppTheme.industrialPrimaryButton,
                      icon: _isCreatingSlip
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isCreatingSlip
                          ? 'Traitement...'
                          : (_includePayment ? 'Evectuer Paiement' : 'Terminer')),
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

  Widget _buildClientAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Client *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.industrialText,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<Client>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _clients;
            }
            return _clients.where((Client client) {
              final searchLower = textEditingValue.text.toLowerCase();
              return client.name.toLowerCase().contains(searchLower) ||
                  client.phone.contains(textEditingValue.text);
            });
          },
          displayStringForOption: (Client client) => '${client.name} - ${client.phone}',
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            // Si un client est sélectionné, afficher ses informations
            if (_selectedClientId != null) {
              final selectedClient = _clients.firstWhere(
                (c) => c.id == _selectedClientId,
                orElse: () => _clients.first,
              );
              textEditingController.text = '${selectedClient.name} - ${selectedClient.phone}';
            }
            
            return TextFormField(
              controller: textEditingController,
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
                          setState(() {
                            _selectedClientId = null;
                            textEditingController.clear();
                          });
                        },
                      )
                    : null,
              ),
              validator: (value) {
                if (_selectedClientId == null) {
                  return 'Veuillez sélectionner un client';
                }
                return null;
              },
            );
          },
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
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final client = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(client);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.industrialPrimary.withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.industrialText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                client.phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.industrialText.withOpacity(0.7),
                                ),
                              ),
                              if (client.type.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.industrialPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    client.type,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.industrialPrimary,
                                    ),
                                  ),
                                ),
                              ],
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
          onSelected: (Client client) {
            setState(() {
              _selectedClientId = client.id;
            });
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
      items: _materials.map((material) {
        return DropdownMenuItem<int>(
          value: material.id,
          child: Text('${material.name} (${material.defaultPricePerTon} DZD/T)'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMaterialId = value;
        });
      },
      validator: (value) {
        if (value == null) return 'Veuillez sélectionner un matériau';
        return null;
      },
    );
  }

  Widget _buildWeightField() {
    // Protection contre les hot reloads
    if (_emptyWeightController == null || _fullWeightController == null) {
      return const SizedBox.shrink();
    }
    
    final emptyWeight = double.tryParse(_emptyWeightController!.text) ?? 0;
    final fullWeight = double.tryParse(_fullWeightController!.text) ?? 0;
    final netWeight = fullWeight - emptyWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Les deux champs côte à côte
        Row(
          children: [
            // Poids vide
            Expanded(
              child: TextFormField(
                controller: _emptyWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                ],
                style: const TextStyle(color: AppColors.industrialText),
                decoration: AppTheme.industrialInputDecoration(
                  hint: 'Poids vide (tonnes)',
                  prefixIcon: Icons.scale,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 0) {
                    return 'Invalide';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Update net weight and total amount display
                },
              ),
            ),
            const SizedBox(width: 16),

            // Poids complet
            Expanded(
              child: TextFormField(
                controller: _fullWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                ],
                style: const TextStyle(color: AppColors.industrialText),
                decoration: AppTheme.industrialInputDecoration(
                  hint: 'Poids complet (tonnes)',
                  prefixIcon: Icons.scale,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Invalide';
                  }
                  final empty = double.tryParse(_emptyWeightController?.text ?? '') ?? 0;
                  if (weight <= empty) {
                    return 'Doit être > poids vide';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Update net weight and total amount display
                },
              ),
            ),
          ],
        ),
        
        // Affichage du poids net calculé
        if (netWeight > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.industrialPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.industrialPrimary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate,
                  color: AppColors.industrialPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Poids net: ${netWeight.toStringAsFixed(3)} tonnes',
                  style: const TextStyle(
                    color: AppColors.industrialPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _includePayment,
              onChanged: (value) {
                setState(() {
                  _includePayment = value ?? false;
                });
              },
            ),
            const Text(
              'Ajouter un paiement initial',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (_includePayment) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _paymentAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: const TextStyle(color: AppColors.industrialText),
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Montant payé (DZD)',
              prefixIcon: Icons.payments,
            ),
            validator: _includePayment
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le montant';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Veuillez entrer un montant valide';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _paymentType,
            isExpanded: true,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Type de paiement',
              prefixIcon: Icons.payment,
            ),
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Espèces')),
              DropdownMenuItem(value: 'check', child: Text('Chèque')),
            ],
            onChanged: (value) {
              setState(() {
                _paymentType = value ?? 'cash';
                if (_paymentType == 'cash') {
                  _checkNumberController?.clear();
                  _checkBankController?.clear();
                  _checkDate = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
                    // Check fields (visible only if payment type is not cash)
          if (_paymentType != 'cash') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _checkNumberController,
              focusNode: _checkNumberFocusNode,
              style: const TextStyle(color: AppColors.industrialText),
              decoration: AppTheme.industrialInputDecoration(
                hint: 'Numéro de chèque (20 chiffres) *',
                prefixIcon: Icons.numbers,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(20),
              ],
              keyboardType: TextInputType.number,
              validator: _paymentType != 'cash'
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro de chèque';
                      }
                      if (value.length != 20) {
                        return 'Le numéro doit contenir exactement 20 chiffres';
                      }
                      return null;
                    }
                  : null,
            ),
           const SizedBox(height: 16),
            TextFormField(
              controller: _checkBankController,
              focusNode: _checkBankFocusNode,
              style: const TextStyle(color: AppColors.industrialText),
              decoration: AppTheme.industrialInputDecoration(
                hint: 'Banque *',
                prefixIcon: Icons.account_balance,
              ),
              validator: _paymentType != 'cash'
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la banque';
                      }
                      return null;
                    }
                  : null,
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.industrialText),
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Notes (optionnel)',
              prefixIcon: Icons.note,
            ),
          ),
        ],
      ],
    );
  }
}
