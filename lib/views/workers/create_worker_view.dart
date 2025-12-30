import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/request/create_worker_request.dart';
import '../../viewmodels/worker_viewmodel.dart';

class CreateWorkerView extends StatefulWidget {
  const CreateWorkerView({super.key});

  @override
  State<CreateWorkerView> createState() => _CreateWorkerViewState();
}

class _CreateWorkerViewState extends State<CreateWorkerView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _jobPositionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedHireDate;
  bool _isActive = true;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  late final WorkerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<WorkerViewModel>();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _jobPositionController.dispose();
    _salaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectHireDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedHireDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.industrialText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedHireDate) {
      setState(() {
        _selectedHireDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date d\'embauche'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final request = CreateWorkerRequest(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      hireDate: _selectedHireDate!,
      jobPosition: _jobPositionController.text.trim(),
      monthlySalary: double.parse(_salaryController.text.trim()),
      isActive: _isActive,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await _viewModel.createWorker(request);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Travailleur créé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/workers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Erreur lors de la création'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Nouveau travailleur'),
          backgroundColor: AppColors.industrialPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/workers'),
          ),
        ),
        body: Consumer<WorkerViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const Text(
                        'Informations du travailleur',
                        style: AppTheme.headingLarge,
                      ),
                      const SizedBox(height: 20),

                      // Nom complet
                      TextFormField(
                        controller: _fullNameController,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Nom complet *',
                          prefixIcon: Icons.person,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom complet est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Téléphone
                      TextFormField(
                        controller: _phoneController,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Téléphone *',
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

                      // Adresse
                      TextFormField(
                        controller: _addressController,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Adresse *',
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

                      // Date d'embauche
                      TextFormField(
                        readOnly: true,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Date d\'embauche *',
                          prefixIcon: Icons.calendar_today,
                        ).copyWith(
                          hintText: _selectedHireDate != null
                              ? _dateFormat.format(_selectedHireDate!)
                              : 'Sélectionner une date',
                        ),
                        onTap: _selectHireDate,
                        validator: (value) {
                          if (_selectedHireDate == null) {
                            return 'La date d\'embauche est requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Poste
                      TextFormField(
                        controller: _jobPositionController,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Poste *',
                          prefixIcon: Icons.work,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le poste est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Salaire mensuel
                      TextFormField(
                        controller: _salaryController,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Salaire mensuel (DZD) *',
                          prefixIcon: Icons.attach_money,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le salaire mensuel est requis';
                          }
                          final double? salary = double.tryParse(value.trim());
                          if (salary == null) {
                            return 'Veuillez entrer un montant valide';
                          }
                          if (salary <= 0) {
                            return 'Le salaire doit être supérieur à 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Statut actif
                      Row(
                        children: [
                          Checkbox(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value ?? true;
                              });
                            },
                            activeColor: AppColors.industrialPrimary,
                          ),
                          const Text(
                            'Travailleur actif',
                            style: TextStyle(color: AppColors.industrialText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: AppTheme.industrialInputDecoration(
                          hint: 'Notes',
                          prefixIcon: Icons.note,
                        ),
                        maxLines: 4,
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
                                        : () => context.go('/workers'),
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
                                        : _handleSubmit,
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
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        viewModel.isLoading
                                            ? 'Création...'
                                            : 'Créer le travailleur',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                   ] ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
