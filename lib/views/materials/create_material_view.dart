import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/material_viewmodel.dart';
import '../../models/request/create_material_request.dart';
import '../widgets/error_message_box.dart';

/// Vue pour créer un nouveau matériau
class CreateMaterialView extends StatefulWidget {
  const CreateMaterialView({super.key});

  @override
  State<CreateMaterialView> createState() => _CreateMaterialViewState();
}

class _CreateMaterialViewState extends State<CreateMaterialView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final MaterialViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<MaterialViewModel>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
            onPressed: () => context.go('/materials'),
          ),
          title: const Text(
            'Nouveau matériau',
            style: TextStyle(
              color: AppColors.industrialPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<MaterialViewModel>(
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
                          'Informations du matériau',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Remplissez les informations du nouveau matériau',
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
                            hint: 'ex: Fer, Aluminium, Cuivre',
                            prefixIcon: Icons.inventory_2,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Catégorie
                        const Text('Catégorie *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _categoryController.text.isEmpty ? null : _categoryController.text,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.industrialText),
                          dropdownColor: AppColors.white,
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Sélectionnez une catégorie',
                            prefixIcon: Icons.category,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Metaux',
                              child: Text('Métaux', style: TextStyle(color: AppColors.industrialText)),
                            ),
                            DropdownMenuItem(
                              value: 'Plastiques',
                              child: Text('Plastiques', style: TextStyle(color: AppColors.industrialText)),
                            ),
                            DropdownMenuItem(
                              value: 'Carton',
                              child: Text('Carton', style: TextStyle(color: AppColors.industrialText)),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _categoryController.text = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La catégorie est requise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Prix par tonne
                        const Text('Prix par tonne (DZD) *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'ex: 8500.00',
                            prefixIcon: Icons.attach_money,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le prix est requis';
                            }
                            final price = double.tryParse(value.trim());
                            if (price == null || price <= 0) {
                              return 'Le prix doit être un nombre positif';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        const Text('Description', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Détails sur le matériau...',
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
                                          : () => context.go('/materials'),
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
                                          viewModel.isLoading ? null : _createMaterial,
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
                                              : 'Créer le matériau',
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

  Future<void> _createMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateMaterialRequest(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      defaultPricePerTon: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final success = await _viewModel.createMaterial(request);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matériau créé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/materials');
    }
  }
}
