import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/material_viewmodel.dart';
import '../../models/entities/material.dart' as material_entity;
import '../../models/request/update_material_request.dart';
import '../widgets/error_message_box.dart';

/// Vue pour modifier un matériau existant
class EditMaterialView extends StatefulWidget {
  final int materialId;
  final material_entity.Material initialMaterial;

  const EditMaterialView({
    super.key,
    required this.materialId,
    required this.initialMaterial,
  });

  @override
  State<EditMaterialView> createState() => _EditMaterialViewState();
}

class _EditMaterialViewState extends State<EditMaterialView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  late bool _isActive;

  late final MaterialViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<MaterialViewModel>();

    // Normaliser la catégorie pour correspondre aux valeurs du dropdown
    String normalizedCategory = widget.initialMaterial.category;
    if (normalizedCategory == 'Métaux') {
      normalizedCategory = 'Metaux';
    }

    // Initialiser les contrôleurs avec les valeurs actuelles
    _nameController = TextEditingController(text: widget.initialMaterial.name);
    _categoryController = TextEditingController(text: normalizedCategory);
    _priceController =
        TextEditingController(text: widget.initialMaterial.defaultPricePerTon.toString());
    _descriptionController =
        TextEditingController(text: widget.initialMaterial.description ?? '');
    _isActive = widget.initialMaterial.isActive;
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
            'Modifier matériau',
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
                          'Modifier les informations du matériau',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Catégorie: ${widget.initialMaterial.category}',
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
                            hint: 'Nom du matériau',
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
                            hint: 'Catégorie',
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
                            hint: 'Prix par tonne',
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
                        const SizedBox(height: 16),

                        // Statut (Actif/Inactif)
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
                                    'Matériau actif',
                                    style: TextStyle(
                                      color: AppColors.industrialText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Les matériaux inactifs ne peuvent pas être utilisés',
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
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : _updateMaterial,
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

  Future<void> _updateMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateMaterialRequest(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      defaultPricePerTon: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isActive: _isActive,
    );

    final success = await _viewModel.updateMaterial(widget.materialId, request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matériau mis à jour avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/materials');
    }
  }
}
