import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/maintenance_viewmodel.dart';
import '../../models/entities/maintenance_expense.dart';
import '../../models/request/update_maintenance_expense_request.dart';
import '../widgets/error_message_box.dart';
import '../../core/constants/machine_types.dart';

/// Vue pour modifier des frais existants
class EditMaintenanceView extends StatefulWidget {
  final int expenseId;
  final MaintenanceExpense initialExpense;

  const EditMaintenanceView({
    super.key,
    required this.expenseId,
    required this.initialExpense,
  });

  @override
  State<EditMaintenanceView> createState() => _EditMaintenanceViewState();
}

class _EditMaintenanceViewState extends State<EditMaintenanceView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMachineType;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  late final MaintenanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<MaintenanceViewModel>();

    // Initialiser les contrôleurs avec les valeurs actuelles
    _selectedMachineType = widget.initialExpense.machineType;
    _descriptionController = TextEditingController(text: widget.initialExpense.description);
    _costController = TextEditingController(text: widget.initialExpense.cost.toString());
    _notesController = TextEditingController(text: widget.initialExpense.notes ?? '');
    _selectedDate = widget.initialExpense.maintenanceDate;
  }

  @override
  void dispose() {
    // _selectedMachineType is a simple String, no controller to dispose
    _descriptionController.dispose();
    _costController.dispose();
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
            onPressed: () => context.go('/maintenance'),
          ),
          title: const Text(
            'Modifier des frais',
            style: TextStyle(
              color: AppColors.industrialPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<MaintenanceViewModel>(
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
                          'Modifier les informations des frais',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.industrialPrimary,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // const Text(
                        //   'Modifiez les détails des frais de maintenance',
                        //   style: AppTheme.subtitleMedium,
                        // ),
                        const SizedBox(height: 32),

                        // Afficher l'erreur si présente
                        if (viewModel.hasError) ...[
                          ErrorMessageBox(message: viewModel.errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Type de machine (sélection)
                              const Text('Type des frais *', style: AppTheme.fieldLabel),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedMachineType == '' ? null : _selectedMachineType,
                                items: machineTypes
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                decoration: AppTheme.industrialInputDecoration(
                                  hint: 'Sélectionner le type de frais',
                                  prefixIcon: Icons.precision_manufacturing,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMachineType = value;
                                  });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le type de frais est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        const Text('Description *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Décrivez les frais...',
                            prefixIcon: Icons.description,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La description est requise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Coût
                        const Text('Coût (DZD) *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _costController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Montant des frais',
                            prefixIcon: Icons.attach_money,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le coût est requis';
                            }
                            final cost = double.tryParse(value.trim());
                            if (cost == null || cost <= 0) {
                              return 'Le coût doit être un nombre positif';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date des frais
                        const Text('Date des frais *', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: AppTheme.industrialInputDecoration(
                              hint: 'Sélectionner une date',
                              prefixIcon: Icons.calendar_today,
                            ),
                            child: Text(
                              _dateFormat.format(_selectedDate),
                              style: const TextStyle(
                                color: AppColors.industrialText,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        const Text('Notes', style: AppTheme.fieldLabel),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          style: const TextStyle(color: AppColors.industrialText),
                          decoration: AppTheme.industrialInputDecoration(
                            hint: 'Notes supplémentaires...',
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
                                          : () => context.go('/maintenance'),
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
                                          : _updateExpense,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateMaintenanceExpenseRequest(
      machineType: _selectedMachineType?.trim() ?? '',
      description: _descriptionController.text.trim(),
      cost: double.parse(_costController.text.trim()),
      maintenanceDate: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await _viewModel.updateMaintenanceExpense(widget.expenseId, request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Frais mis à jour avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/maintenance');
    }
  }
}
