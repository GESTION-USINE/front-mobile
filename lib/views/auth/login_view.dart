import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../di/injection_container.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/error_message_box.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthViewModel _viewModel;

  bool _obscurePassword = true;
  bool _isRemote = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AuthViewModel>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.industrialBackground,
        body: SafeArea(
          child: Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                children: [
                  // Left Panel - Branding
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.industrialGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icon
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.iconContainerDecoration,
                            child: const Icon(
                              Icons.factory_outlined,
                              size: 80,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Title
                          const Text(
                            'Système de Gestion',
                            style: AppTheme.overlayTitle,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Usine de Production',
                            style: AppTheme.overlaySubtitle,
                          ),
                          const SizedBox(height: 48),
                          
                          // Features
                          _buildFeature(
                            Icons.inventory_2_outlined,
                            'Gestion des stocks',
                          ),
                          const SizedBox(height: 16),
                          _buildFeature(
                            Icons.people_outline,
                            'Gestion des utilisateurs',
                          ),
                          const SizedBox(height: 16),
                          _buildFeature(
                            Icons.analytics_outlined,
                            'Rapports et analyses',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Panel - Login Form
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Welcome text
                                const Text(
                                  'Bienvenue',
                                  style: AppTheme.headingLarge,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Connectez-vous à votre compte',
                                  style: AppTheme.subtitleMedium,
                                ),
                                const SizedBox(height: 48),

                                // Username field
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Nom d\'utilisateur',
                                  hint: 'Entrez votre nom d\'utilisateur',
                                  prefixIcon: Icons.person_outline,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 20),

                                // Password field
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Mot de passe',
                                  hint: 'Entrez votre mot de passe',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.grey600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _login(),
                                ),
                                const SizedBox(height: 16),

                                // Remote access checkbox
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _isRemote,
                                        onChanged: (value) {
                                          setState(() {
                                            _isRemote = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Accès distant',
                                      style: AppTheme.subtitleMedium.copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Error message
                                if (viewModel.hasError)
                                  ErrorMessageBox(
                                    message: viewModel.errorMessage!,
                                  ),

                                // Login button
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: viewModel.isLoading ? null : _login,
                                    style: AppTheme.industrialPrimaryButton,
                                    child: viewModel.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                            ),
                                          )
                                        : const Text('Se connecter'),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Footer
                                Center(
                                  child: Text(
                                    '© 2025 Système de Gestion Usine',
                                    style: AppTheme.footerText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: AppTheme.featureIconDecoration,
            child: Icon(
              icon,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: AppTheme.overlayFeature,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.fieldLabel,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: AppTheme.fieldTextStyle(),
          decoration: AppTheme.industrialInputDecoration(
            hint: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            textColor: AppTheme.fieldTextStyle().color,
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    // Validation simple côté client
    if (_usernameController.text.trim().isEmpty) {
      return;
    }

    if (_passwordController.text.isEmpty) {
      return;
    }

    final success = await _viewModel.login(
      _usernameController.text.trim(),
      _passwordController.text,
      isRemote: _isRemote,
    );

    if (success && mounted) {
      context.go(AppRouter.dashboard);
    }
  }
}
