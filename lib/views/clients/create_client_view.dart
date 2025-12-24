import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../models/request/create_client_request.dart';
import '../widgets/error_message_box.dart';

/// Vue pour créer un nouveau client
class CreateClientView extends StatefulWidget {
  const CreateClientView({super.key});

  @override
  State<CreateClientView> createState() => _CreateClientViewState();
}

class _CreateClientViewState extends State<CreateClientView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'particulier';
  bool _canPayByCheck = false;

  late final ClientViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientViewModel>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.industrialBackground,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.industrialPrimary),
            onPressed: () => context.go('/clients'),
          ),
          title: const Text(
            'Nouveau client',
            style: TextStyle(
              color: AppColors.industrialPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<ClientViewModel>(
          builder: (context, viewModel, child) {
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
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        const Text(
                          'Informations du client',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Remplissez les informations du nouveau client',
                          style: AppTheme.subtitleMedium,
                        ),
                        const SizedBox(height: 32),

                        // Afficher l'erreur si présente
                        if (viewModel.hasError) ...[
                          ErrorMessageBox(message: viewModel.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Type de client
                        const Text('Type de client *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedType = 'particulier';
                                  _canPayByCheck = false;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: 'particulier',
                                    // ignore: deprecated_member_use
                                    groupValue: _selectedType,
                                    // ignore: deprecated_member_use
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedType = value!;
                                        _canPayByCheck = false;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Particulier',
                                    style: TextStyle(color: AppColors.industrialText),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedType = 'entreprise';
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: 'entreprise',
                                    // ignore: deprecated_member_use
                                    groupValue: _selectedType,
                                    // ignore: deprecated_member_use
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedType = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Entreprise',
                                    style: TextStyle(color: AppColors.industrialText),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Nom
                        const Text('Nom *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: _selectedType == 'entreprise'
                                ? 'Nom de l\'entreprise'
                                : 'Nom complet',
                            prefixIcon: Icons.business,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Téléphone
                        const Text('Téléphone *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: '0550000000',
                            prefixIcon: Icons.phone,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le téléphone est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        const Text('Email', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'email@example.com',
                            prefixIcon: Icons.email,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Email invalide';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Adresse
                        const Text('Adresse', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Adresse complète',
                            prefixIcon: Icons.location_on,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // NIF (si entreprise)
                        if (_selectedType == 'entreprise') ...[
                          const Text('Numéro d\'identification fiscale (NIF)', style: AppTheme.fieldLabel),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _taxIdController,
                            style: const TextStyle(color: AppColors.industrialText),
                            decoration: AppTheme.industrialInputDecoration(
                              hint: 'NIF-XXXXX',
                              prefixIcon: Icons.numbers,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Paiement par chèque (si entreprise)
                        if (_selectedType == 'entreprise') ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _canPayByCheck = !_canPayByCheck;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _canPayByCheck,
                                  onChanged: (value) {
                                    setState(() {
                                      _canPayByCheck = value ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Autorisé à payer par chèque',
                                      style: TextStyle(
                                        color: AppColors.industrialText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Disponible uniquement pour les entreprises',
                                      style: TextStyle(
                                        color: AppColors.industrialTextLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Notes
                        const Text('Notes', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Notes sur le client...',
                            prefixIcon: Icons.note,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),

                        // Boutons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () => context.go('/clients'),
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : _createClient,
                              style: AppTheme.industrialPrimaryButton,
                              icon: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(viewModel.isLoading ? 'Création...' : 'Créer le client'),
                            ),
                          ],
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

  Future<void> _createClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = CreateClientRequest(
      name: _nameController.text.trim(),
      type: _selectedType,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      taxId: _taxIdController.text.trim().isEmpty
          ? null
          : _taxIdController.text.trim(),
      canPayByCheck: _canPayByCheck,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await _viewModel.createClient(request);

    if (success && mounted) {
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client créé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      // Retourner à la liste
      context.go('/clients');
    }
  }
}
