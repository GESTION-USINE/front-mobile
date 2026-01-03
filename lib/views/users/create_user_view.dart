import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/user.dart';
import '../widgets/error_message_box.dart';

/// Vue pour créer un nouvel utilisateur
class CreateUserView extends StatefulWidget {
  const CreateUserView({super.key});

  @override
  State<CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<CreateUserView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  final _creditLimitController = TextEditingController(text: '0');

  bool _canModifyInvoices = false;
  bool _canAccessFullTraceability = false;
  bool _canAccessRemotely = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late final UserViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<UserViewModel>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
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
            onPressed: () => context.go('/users'),
          ),
          title: const Text(
            'Nouvel utilisateur',
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
                          'Informations de l\'utilisateur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Remplissez les informations du nouvel utilisateur',
                          style: AppTheme.subtitleMedium,
                        ),
                        const SizedBox(height: 32),

                        // Afficher l'erreur si présente
                        if (viewModel.hasError) ...[
                          ErrorMessageBox(message: viewModel.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Nom d'utilisateur
                        const Text('Nom d\'utilisateur *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'ex: jdupont',
                            prefixIcon: Icons.person,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom d\'utilisateur est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Mot de passe
                        const Text('Mot de passe *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Mot de passe',
                            prefixIcon: Icons.lock,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.industrialTextLight,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le mot de passe est requis';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirmation mot de passe
                        const Text('Confirmer le mot de passe *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Confirmer le mot de passe',
                            prefixIcon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.industrialTextLight,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La confirmation est requise';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
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

                        // Rôle
                        const Text('Rôle *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _roleController.text.isEmpty ? null : _roleController.text,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.industrialText),
                          dropdownColor: AppColors.white,
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Sélectionnez un rôle',
                            prefixIcon: Icons.admin_panel_settings,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'super_admin',
                              child: Text('Super Admin', style: TextStyle(color: AppColors.industrialText)),
                            ),
                            DropdownMenuItem(
                              value: 'associe',
                              child: Text('Associé', style: TextStyle(color: AppColors.industrialText)),
                            ),
                            DropdownMenuItem(
                              value: 'employe',
                              child: Text('Employé', style: TextStyle(color: AppColors.industrialText)),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _roleController.text = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le rôle est requis';
                            }
                            return null;
                          },
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
                                      onPressed:
                                          viewModel.isLoading ? null : _createUser,
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
                                              : 'Créer l\'utilisateur',
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

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateUserRequest(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      role: _roleController.text.trim(),
      canModifyInvoices: _canModifyInvoices,
      canAccessFullTraceability: _canAccessFullTraceability,
      canAccessRemotely: _canAccessRemotely,
      creditLimit: double.tryParse(_creditLimitController.text.trim()) ?? 0,
    );

    await _viewModel.createUser(request);
    
    if (!_viewModel.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur créé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/users');
    }
  }
}
