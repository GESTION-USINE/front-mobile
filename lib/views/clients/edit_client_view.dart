import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../providers/user_provider.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../models/entities/client.dart';
import '../../models/request/update_client_request.dart';
import '../widgets/error_message_box.dart';

/// Vue pour modifier un client existant
class EditClientView extends StatefulWidget {
  final int clientId;
  final Client initialClient;

  const EditClientView({
    super.key,
    required this.clientId,
    required this.initialClient,
  });

  @override
  State<EditClientView> createState() => _EditClientViewState();
}

class _EditClientViewState extends State<EditClientView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;
  late final TextEditingController _creditLimitController;

  late bool _canPayByCheck;
  late bool _isActive;

  late final ClientViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientViewModel>();

    // Initialiser les contrôleurs avec les valeurs actuelles
    _nameController = TextEditingController(text: widget.initialClient.name);
    _phoneController = TextEditingController(text: widget.initialClient.phone);
    _emailController = TextEditingController(text: widget.initialClient.email ?? '');
    _notesController = TextEditingController(text: widget.initialClient.notes ?? '');
    _canPayByCheck = widget.initialClient.canPayByCheck;
    _isActive = widget.initialClient.isActive;
    _creditLimitController = TextEditingController(text: widget.initialClient.creditLimit ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _creditLimitController.dispose();
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
            'Modifier client',
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
                          'Modifier les informations du client',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Type: ${widget.initialClient.type == "entreprise" ? "Entreprise" : "Particulier"}',
                          style: AppTheme.subtitleMedium,
                        ),
                        const SizedBox(height: 32),

                        // Afficher l'erreur si présente
                        if (viewModel.hasError) ...[
                          ErrorMessageBox(message: viewModel.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Nom
                        const Text('Nom *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: widget.initialClient.type == 'entreprise'
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

                        // Limite de crédit
                        const Text('Limite de crédit', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _creditLimitController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: '0.00',
                            prefixIcon: Icons.monetization_on,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            final v = double.tryParse(value.replaceAll(',', '.'));
                            if (v == null) return 'Valeur numérique invalide';
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

                        // Paiement par chèque - Section mise en évidence
                        if (!isEmployee) ...[
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.credit_card,
                                      size: 20,
                                      color: AppColors.industrialPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Autorisation de paiement par chèque',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.industrialText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _canPayByCheck 
                                              ? 'Client autorisé à payer par chèque' 
                                              : 'Client non autorisé à payer par chèque',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _canPayByCheck ? Colors.green : Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.initialClient.type == 'entreprise'
                                              ? 'Recommandé pour les entreprises'
                                              : 'Généralement réservé aux entreprises',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.industrialTextLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _canPayByCheck,
                                      onChanged: (value) {
                                        setState(() {
                                          _canPayByCheck = value;
                                        });
                                      },
                                      activeColor: AppColors.industrialPrimary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Statut (si pas employé)
                        if (!isEmployee) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isActive = !_isActive;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _isActive,
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Client actif',
                                      style: TextStyle(
                                        color: AppColors.industrialText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Les clients inactifs sont masqués pour les employés',
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
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : _updateClient,
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
                                              ? 'Modification...'
                                              : 'Mettre à jour',
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

  Future<void> _updateClient() async {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateClientRequest(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      canPayByCheck: widget.initialClient.type == 'entreprise'
          ? context.read<UserProvider>().currentUser?.role.toLowerCase() == 'employe'
              ? false
              : _canPayByCheck
          : false,
      isActive: _isActive,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      creditLimit: _creditLimitController.text.trim().isEmpty
        ? null
        : double.tryParse(_creditLimitController.text.replaceAll(',', '.')),
    );

    final success = await _viewModel.updateClient(widget.clientId, request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client mis à jour avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/clients');
    }
  }
}
