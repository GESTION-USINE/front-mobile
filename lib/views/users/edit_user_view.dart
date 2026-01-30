import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/user.dart';
import '../widgets/error_message_box.dart';

/// Vue pour modifier un utilisateur existant
class EditUserView extends StatefulWidget {
  final int userId;
  final User initialUser;

  const EditUserView({
    super.key,
    required this.userId,
    required this.initialUser,
  });

  @override
  State<EditUserView> createState() => _EditUserViewState();
}

class _EditUserViewState extends State<EditUserView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late bool _canModifyInvoices;
  late bool _canAccessFullTraceability;
  late bool _canAccessRemotely;

  late final UserViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<UserViewModel>();

    // Initialiser les contrôleurs avec les valeurs actuelles
    _emailController = TextEditingController(text: widget.initialUser.email ?? '');
    _phoneController = TextEditingController(text: widget.initialUser.phone ?? '');
    _creditLimitController = TextEditingController(
        text: widget.initialUser.creditLimit.toString());
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    _canModifyInvoices = widget.initialUser.canModifyInvoices;
    _canAccessFullTraceability = widget.initialUser.canAccessFullTraceability;
    _canAccessRemotely = widget.initialUser.canAccessRemotely;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _creditLimitController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            onPressed: () => context.go('/users'),
          ),
          title: const Text(
            'Modifier utilisateur',
            style: TextStyle(
              color: AppColors.industrialPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<UserViewModel>(
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
                          'Modifier les informations de l\'utilisateur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Utilisateur: ${widget.initialUser.username}',
                          style: AppTheme.subtitleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rôle: ${_formatRole(widget.initialUser.role)}',
                          style: AppTheme.subtitleMedium,
                        ),
                        const SizedBox(height: 32),

                        // Afficher l'erreur si présente
                        if (viewModel.hasError) ...[
                          ErrorMessageBox(message: viewModel.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        const Text('Email', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'ex: j.dupont@entreprise.com',
                            prefixIcon: Icons.email,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Email invalide';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Téléphone
                        const Text('Téléphone', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'ex: 0555123456',
                            prefixIcon: Icons.phone,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Limite de crédit (pour associé)
                        const Text('Limite de crédit (DZD)', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _creditLimitController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'ex: 10000.00',
                            prefixIcon: Icons.credit_card,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final limit = double.tryParse(value.trim());
                              if (limit == null || limit < 0) {
                                return 'La limite doit être un nombre positif';
                              }
                              // Vérifier que la limite n'est pas inférieure au crédit utilisé
                              if (limit < widget.initialUser.currentCreditUsed) {
                                return 'La limite ne peut pas être inférieure au crédit utilisé (${widget.initialUser.currentCreditUsed.toStringAsFixed(2)} DZD)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crédit actuellement utilisé: ${widget.initialUser.currentCreditUsed.toStringAsFixed(2)} DZD',
                          style: const TextStyle(
                            color: AppColors.industrialTextLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mot de passe (optionnel)
                        const Text('Mot de passe (optionnel)', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Laisser vide pour conserver le mot de passe actuel',
                            prefixIcon: Icons.lock,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              if (value != _confirmPasswordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirmation mot de passe
                        const Text('Confirmer le mot de passe', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Confirmer le nouveau mot de passe',
                            prefixIcon: Icons.lock_outline,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (_passwordController.text.isNotEmpty) {
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Permissions
                        const Text('Permissions', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.industrialText,
                        )),
                        const SizedBox(height: 12),

                        // Peut modifier les factures
                        InkWell(
                          onTap: () {
                            setState(() {
                              _canModifyInvoices = !_canModifyInvoices;
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: _canModifyInvoices,
                                onChanged: (value) {
                                  setState(() {
                                    _canModifyInvoices = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Peut modifier les factures',
                                      style: TextStyle(
                                        color: AppColors.industrialText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Autoriser la modification des factures',
                                      style: TextStyle(
                                        color: AppColors.industrialTextLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Accès complet à la traçabilité
                        InkWell(
                          onTap: () {
                            setState(() {
                              _canAccessFullTraceability = !_canAccessFullTraceability;
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: _canAccessFullTraceability,
                                onChanged: (value) {
                                  setState(() {
                                    _canAccessFullTraceability = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Accès complet à la traçabilité',
                                      style: TextStyle(
                                        color: AppColors.industrialText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Accès à toutes les informations de traçabilité',
                                      style: TextStyle(
                                        color: AppColors.industrialTextLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Accès à distance
                        InkWell(
                          onTap: () {
                            setState(() {
                              _canAccessRemotely = !_canAccessRemotely;
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: _canAccessRemotely,
                                onChanged: (value) {
                                  setState(() {
                                    _canAccessRemotely = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Accès à distance',
                                      style: TextStyle(
                                        color: AppColors.industrialText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Autoriser la connexion à distance',
                                      style: TextStyle(
                                        color: AppColors.industrialTextLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                          : () => context.go('/users'),
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
                                          : _updateUser,
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

  String _formatRole(String role) {
    if (role == 'super_admin') return 'Super Admin';
    if (role == 'associe') return 'Associé';
    if (role == 'employe') return 'Employé';
    return role;
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    // Clear any previous error state so stale errors don't block navigation
    _viewModel.clearError();

    final request = UpdateUserRequest(
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      canModifyInvoices: _canModifyInvoices,
      canAccessFullTraceability: _canAccessFullTraceability,
      canAccessRemotely: _canAccessRemotely,
      creditLimit: double.tryParse(_creditLimitController.text.trim()),
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
    );

    await _viewModel.updateUser(widget.userId, request);

    if (_viewModel.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur mis à jour avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/users');
    }
  }
}
