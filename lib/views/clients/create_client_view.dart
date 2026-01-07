import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../providers/user_provider.dart';
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
  final _nisController = TextEditingController();
  final _registreCommerceController = TextEditingController();
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
    _nisController.dispose();
    _registreCommerceController.dispose();
    _notesController.dispose();

    // IMPORTANT:
    // Ne pas faire _viewModel.dispose() ici si:
    // - l'instance vient de getIt (singleton / shared)
    // - et est passée via ChangeNotifierProvider.value
    //
    // Si tu veux gérer le cycle de vie via Provider, utilise plutôt:
    // ChangeNotifierProvider(create: (_) => getIt<ClientViewModel>())
    // et là Provider dispose automatiquement.

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
            final String? role = context.select<UserProvider, String?>(
              (p) => p.currentUser?.role,
            );
            final bool isEmployee = role?.toLowerCase() == 'employe';

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
                          'Remplissez le formulaire ci-dessous',
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
                                    groupValue: _selectedType,
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
                                    groupValue: _selectedType,
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
                            final phone = value.trim();
                            final regex = RegExp(r'^0\d{9}$');
                            if (!regex.hasMatch(phone)) {
                              return 'Doit contenir 10 chiffres et commencer par 0';
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
                        const Text('Adresse *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Adresse complète',
                            prefixIcon: Icons.location_on,
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'L\'adresse est requise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Champs entreprise obligatoires
                        if (_selectedType == 'entreprise') ...[
                          const Text(
                            'Numéro d\'identification fiscale (NIF) *',
                            style: AppTheme.fieldLabel,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _taxIdController,
                            style: const TextStyle(color: AppColors.industrialText),
                            decoration: AppTheme.industrialInputDecoration(
                              hint: 'NIF-XXXXX',
                              prefixIcon: Icons.numbers,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le NIF est requis pour une entreprise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Numéro d\'identification statistique (NIS) *',
                            style: AppTheme.fieldLabel,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nisController,
                            style: const TextStyle(color: AppColors.industrialText),
                            decoration: AppTheme.industrialInputDecoration(
                              hint: 'NIS-XXXXX',
                              prefixIcon: Icons.numbers,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le NIS est requis pour une entreprise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Registre du commerce *',
                            style: AppTheme.fieldLabel,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _registreCommerceController,
                            style: const TextStyle(color: AppColors.industrialText),
                            decoration: AppTheme.industrialInputDecoration(
                              hint: 'RC-XXXXX',
                              prefixIcon: Icons.business_center,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le registre du commerce est requis pour une entreprise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Paiement par chèque (si entreprise et pas employé)
                        if (_selectedType == 'entreprise' && !isEmployee) ...[
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

                        // Boutons (UPDATED)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 520;

                            return Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 16,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: isSmall ? constraints.maxWidth : null,
                                    child: OutlinedButton(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => context.go('/clients'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text('Annuler'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isSmall ? constraints.maxWidth : null,
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          viewModel.isLoading ? null : _createClient,
                                      style: AppTheme.industrialPrimaryButton,
                                      icon: viewModel.isLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.white,
                                              ),
                                            )
                                          : const Icon(Icons.save),
                                      label: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          viewModel.isLoading
                                              ? 'Création...'
                                              : 'Créer le client',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
    if (!_formKey.currentState!.validate()) return;

    final request = CreateClientRequest(
      name: _nameController.text.trim(),
      type: _selectedType,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address:
          _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      taxId: _taxIdController.text.trim().isEmpty ? null : _taxIdController.text.trim(),
      nis: _nisController.text.trim().isEmpty ? null : _nisController.text.trim(),
      registreCommerce: _registreCommerceController.text.trim().isEmpty ? null : _registreCommerceController.text.trim(),
      canPayByCheck: _selectedType == 'entreprise'
        ? context.read<UserProvider>().currentUser?.role.toLowerCase() == 'employe'
          ? false
          : _canPayByCheck
        : false,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final success = await _viewModel.createClient(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client créé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/clients');
    }
  }
}
